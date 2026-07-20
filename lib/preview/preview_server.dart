import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/markdown/render_repository.dart';
import 'package:pluto/preview/preview_assets.dart';
import 'package:pluto/preview/preview_index.dart';
import 'package:pluto/preview/preview_page.dart';

/// The current state of the course on disk: either an index ready to serve or
/// the failure that stopped it being built.
sealed class PreviewSnapshot {
  const PreviewSnapshot();
}

class PreviewReady extends PreviewSnapshot {
  final PreviewIndex index;

  const PreviewReady(this.index);
}

class PreviewFailed extends PreviewSnapshot {
  final Object error;

  const PreviewFailed(this.error);
}

/// Serves a course as a browsable, self-reloading local site.
///
/// The rendered course is held in memory and rebuilt on source changes; nothing
/// is written to disk.
class PreviewServer {
  /// Coalesces the burst of events macOS emits for a single save.
  static const _debounce = Duration(milliseconds: 150);

  final String courseDir;
  final int port;

  final SourceRepository _sourceRepository = const SourceRepository();
  final RenderRepository _renderRepository = const RenderRepository();
  final PreviewPage _page = const PreviewPage();

  final List<HttpResponse> _listeners = [];

  PreviewSnapshot _snapshot = const PreviewFailed('not built yet');
  HttpServer? _server;
  StreamSubscription<FileSystemEvent>? _watcher;
  Timer? _debounceTimer;

  PreviewServer({required this.courseDir, required this.port});

  String get _sourceDir => join(courseDir, 'source');

  Future<Uri> start() async {
    await _rebuild();

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server = server;
    unawaited(server.forEach(_handle));

    _watch();

    return Uri.parse('http://${server.address.host}:${server.port}/');
  }

  Future<void> stop() async {
    _debounceTimer?.cancel();
    await _watcher?.cancel();
    for (final listener in _listeners) {
      await listener.close().catchError((_) {});
    }
    await _server?.close(force: true);
  }

  void _watch() {
    final dir = Directory(_sourceDir);
    if (!dir.existsSync()) return;

    _watcher = dir.watch(recursive: true).listen((_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounce, () async {
        await _rebuild();
        _notify();
      });
    });
  }

  Future<void> _rebuild() async {
    try {
      final source = await _sourceRepository.readCourseSource(courseDir);
      final rendered = _renderRepository.render(source.course);
      _snapshot = PreviewReady(PreviewIndex.build(rendered));
    } catch (e) {
      // A half-saved file is a normal intermediate state while editing, so a
      // failed rebuild becomes a page you can read, not a dead server.
      _snapshot = PreviewFailed(e);
      stderr.writeln('preview: rebuild failed: $e');
    }
  }

  void _notify() {
    for (final listener in [..._listeners]) {
      try {
        listener.write('event: rebuild\ndata: 1\n\n');
      } catch (_) {
        _listeners.remove(listener);
      }
    }
  }

  Future<void> _handle(HttpRequest request) async {
    final segments = request.uri.pathSegments;

    return switch (segments) {
      ['__reload'] => _serveEvents(request),
      ['assets', 'preview.css'] => _serveCss(request),
      [] => _serveEntry(request),
      ['lesson', final lessonId, 'step', final step] => _serveStep(
        request,
        lessonId,
        step,
      ),
      _ => _serveNotFound(request),
    };
  }

  Future<void> _serveEvents(HttpRequest request) async {
    final response = request.response
      ..bufferOutput = false
      ..headers.set(HttpHeaders.contentTypeHeader, 'text/event-stream')
      ..headers.set(HttpHeaders.cacheControlHeader, 'no-cache')
      ..headers.set(HttpHeaders.connectionHeader, 'keep-alive')
      ..write(': connected\n\n');

    _listeners.add(response);
    unawaited(
      response.done
          .whenComplete(() => _listeners.remove(response))
          .catchError(
            (_) => _listeners.remove(response),
          ),
    );
  }

  Future<void> _serveCss(HttpRequest request) async {
    await _send(request, PreviewAssets.css, contentType: 'text/css');
  }

  Future<void> _serveEntry(HttpRequest request) async {
    switch (_snapshot) {
      case PreviewFailed(:final error):
        await _send(request, _page.errorPage(error));
      case PreviewReady(:final index):
        final entry = index.entryUrl;
        if (entry == null) {
          await _send(request, _page.emptyPage());
        } else {
          await request.response.redirect(
            Uri.parse(entry),
            status: HttpStatus.found,
          );
        }
    }
  }

  Future<void> _serveStep(
    HttpRequest request,
    String rawLessonId,
    String rawStep,
  ) async {
    if (_snapshot case PreviewFailed(:final error)) {
      await _send(request, _page.errorPage(error));
      return;
    }

    final index = (_snapshot as PreviewReady).index;

    final lessonId = int.tryParse(rawLessonId);
    final stepNumber = int.tryParse(rawStep);
    final unitId = int.tryParse(request.uri.queryParameters['unit'] ?? '');

    final lesson = lessonId == null
        ? null
        : index.resolve(lessonId, unitId: unitId);

    if (lesson == null ||
        stepNumber == null ||
        stepNumber < 1 ||
        stepNumber > lesson.steps.length) {
      await _serveNotFound(request);
      return;
    }

    await _send(request, _page.stepPage(index, lesson, stepNumber));
  }

  Future<void> _serveNotFound(HttpRequest request) async {
    final body = switch (_snapshot) {
      PreviewReady(:final index) => _page.notFoundPage(index),
      PreviewFailed(:final error) => _page.errorPage(error),
    };
    await _send(request, body, status: HttpStatus.notFound);
  }

  Future<void> _send(
    HttpRequest request,
    String body, {
    String contentType = 'text/html',
    int status = HttpStatus.ok,
  }) async {
    final response = request.response
      ..statusCode = status
      ..headers.set(
        HttpHeaders.contentTypeHeader,
        '$contentType; charset=utf-8',
      )
      // The page is rebuilt in memory on every change; a cached copy would
      // defeat the reload.
      ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
      ..write(body);
    await response.close();
  }
}

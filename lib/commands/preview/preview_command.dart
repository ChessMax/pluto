import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pluto/preview/preview_server.dart';

class PreviewCommand extends Command<void> {
  @override
  String get name => 'preview';

  @override
  String get description =>
      'Serves the course locally and reloads it as the source changes';

  PreviewCommand() {
    argParser
      ..addOption(
        'port',
        abbr: 'p',
        defaultsTo: '8080',
        help: 'Port to serve on.',
      )
      ..addFlag(
        'open',
        defaultsTo: true,
        help: 'Open the preview in the default browser on start.',
      );
  }

  @override
  Future<void> run() async {
    final results = argResults!;

    final courseDir = results.rest.isNotEmpty
        ? results.rest[0]
        : Directory.current.path;

    final port = int.tryParse(results.option('port') ?? '');
    if (port == null) {
      throw UsageException('Port must be a number.', usage);
    }

    if (!Directory(courseDir).existsSync()) {
      throw UsageException('No such directory: $courseDir', usage);
    }

    final server = PreviewServer(courseDir: courseDir, port: port);

    final Uri url;
    try {
      url = await server.start();
    } on SocketException catch (e) {
      throw UsageException(
        'Could not bind port $port: ${e.osError?.message}',
        usage,
      );
    }

    print('Previewing $courseDir');
    print('Serving $url — press Ctrl-C to stop');

    if (results.flag('open')) {
      unawaited(Process.run('open', [url.toString()]));
    }

    // The server keeps the isolate alive; this waits for Ctrl-C so the watcher
    // and open connections get closed rather than dropped.
    final done = Completer<void>();
    late final StreamSubscription<ProcessSignal> signals;
    signals = ProcessSignal.sigint.watch().listen((_) async {
      await signals.cancel();
      await server.stop();
      if (!done.isCompleted) done.complete();
    });

    await done.future;
    print('\nPreview stopped.');
  }
}

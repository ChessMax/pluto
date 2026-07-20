import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/markdown/render_repository.dart';
import 'package:pluto/domain/stepik_repository.dart';
import 'package:pluto/domain/validation_repository.dart';

class PushCourseCommand extends Command<void> {
  @override
  String get name => 'course';

  @override
  String get description => 'Pushes course to server';

  PushCourseCommand() {
    argParser.addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help:
          'Push despite blocking markers (FIXME). Content still has to pass '
          'validation.',
    );
  }

  @override
  Future<void> run() async {
    // TODO: use current dir by default?
    final courseDir = argResults!.rest[0];
    final force = argResults!.flag('force');
    const sourceRepository = SourceRepository();

    final source = await sourceRepository.readCourseSource(courseDir);
    final courseId = source.course.id;

    final rawApi = (await initializeStepikClient()).rawApi;
    final stepikRepository = StepikRepository(rawApi);

    final remoteCourse = courseId != null
        ? await stepikRepository.readCourse(courseId)
        : null;

    // Publication state comes from the remote course only — see
    // [Course.isPublic]. Used here to decide how loudly `--force` warns.
    final isPublic = remoteCourse?.course.isPublic ?? false;
    final localCourseSource = source.course.copyWith(isPublic: isPublic);

    // Duplicate ids are checked ahead of the diff rather than with the rest of
    // validation below: the diff consumes a remote entity per local id, so a
    // repeated id makes it fail on the second claim before we ever get there.
    final duplicateIds = const ValidationRepository().validateIds(
      localCourseSource,
    );
    if (duplicateIds.isNotEmpty) {
      stderr.writeln('${duplicateIds.length} duplicate id(s) found:');
      for (final duplicate in duplicateIds) {
        stderr.writeln('  - $duplicate');
      }
      stderr.writeln(
        'Push aborted: clear the id of every copy but one, so those steps are '
        'created fresh.',
      );
      exit(1);
    }

    // Diffs are computed before rendering: they only compare ids and structure,
    // and the content phase reads its payload back out of the rendered course.
    final diffs = Diff.create(remoteCourse, localCourseSource).toList();

    // Markers (TODO/FIXME) with precise file:line:column locations, scanned
    // from the raw source, so they can abort before anything is sent. Warnings
    // (TODO) are reported but don't block; errors (FIXME) abort the push unless
    // --force says to accept unfinished content. Every marker is reported
    // either way, so a forced push never reads as a clean one.
    final markers = const ValidationRepository()
        .validate(localCourseSource, sources: source.files)
        .markers;
    if (markers.isNotEmpty) {
      stderr.writeln('${markers.length} marker(s) found:');
      for (final marker in markers) {
        stderr.writeln('  $marker');
      }

      final blocking = markers
          .where((marker) => marker.severity == .error)
          .length;
      if (blocking > 0) {
        if (!force) {
          stderr.writeln(
            'Push aborted: unresolved marker(s) must be resolved. '
            'Use --force to push anyway.',
          );
          exit(1);
        }

        stderr.writeln(
          isPublic
              ? '--force: pushing $blocking unresolved marker(s) into a '
                    'PUBLISHED course — students will see this content.'
              : '--force: pushing past $blocking unresolved marker(s).',
        );
      }
    }

    // Structure first: this is what mints the lesson ids that `ref:` links in
    // step text resolve against.
    var course = await stepikRepository.applyDiff(
      localCourseSource,
      diffs.where((diff) => diff.phase == .structure).toList(),
    );

    // Persisted before the content phase so an abort below can't lose the ids
    // just created — without this a re-run would create duplicates.
    await sourceRepository.writeCourse(course, courseDir);

    // Synthetic ids are refused here: every target exists remotely by now, and
    // a stand-in id would publish a link into somebody else's lesson.
    final links = LinkIndex.build(course);
    course = const RenderRepository().render(course, links: links);

    final validation = const ValidationRepository().validate(
      course,
      links: links,
    );
    if (!validation.isValid) {
      stderr.writeln(
        'Course validation failed (${validation.violations.length} issue(s)):',
      );
      for (final violation in validation.violations) {
        stderr.writeln('  - $violation');
      }
      exit(1);
    }

    course = await stepikRepository.applyDiff(
      course,
      diffs
          .where((diff) => diff.phase == .content || diff.phase == .removal)
          .toList(),
    );

    // saving in case ids added.
    await sourceRepository.writeCourse(course, courseDir);

    diffs.dump();

    print(
      '--> Course created/updated. Check https://stepik.org/course/${course.id}',
    );
  }
}

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/markdown/render_repository.dart';
import 'package:pluto/domain/stepik_repository.dart';
import 'package:pluto/domain/validation_repository.dart';

class PushCourseCommand extends Command<void> {
  @override
  String get name => 'course';

  @override
  String get description => 'Pushes course to server';

  PushCourseCommand();

  @override
  Future<void> run() async {
    // TODO: use current dir by default?
    final courseDir = argResults!.rest[0];
    const sourceRepository = SourceRepository();

    final source = await sourceRepository.readCourseSource(courseDir);
    final localCourseSource = source.course;
    final courseId = localCourseSource.id;

    final localCourse = const RenderRepository().render(localCourseSource);

    final rawApi = (await initializeStepikClient()).rawApi;
    final stepikRepository = StepikRepository(rawApi);

    final remoteCourse = courseId != null
        ? await stepikRepository.readCourse(courseId)
        : null;

    final diffs = Diff.create(remoteCourse, localCourse).toList();

    final validation = const ValidationRepository().validate(
      localCourse,
      sources: source.files,
    );

    // Markers (TODO/FIXME) with precise file:line:column locations. Warnings
    // (TODO) are reported but don't block; errors (FIXME) abort the push.
    final markers = validation.markers;
    if (markers.isNotEmpty) {
      stderr.writeln('${markers.length} marker(s) found:');
      for (final marker in markers) {
        stderr.writeln('  $marker');
      }
    }
    if (validation.hasBlockingMarkers) {
      stderr.writeln('Push aborted: unresolved marker(s) must be resolved.');
      exit(1);
    }

    if (!validation.isValid) {
      stderr.writeln(
        'Course HTML validation failed (${validation.violations.length} issue(s)):',
      );
      for (final violation in validation.violations) {
        stderr.writeln('  - $violation');
      }
      exit(1);
    }

    // creating / updating course on stepik.
    final course = await stepikRepository.applyDiff(localCourse, diffs);

    // saving in case ids added.
    await sourceRepository.writeCourse(course, courseDir);

    diffs.dump();

    print(
      '--> Course created/updated. Check https://stepik.org/course/${course.id}',
    );
  }
}

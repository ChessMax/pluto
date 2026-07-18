import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/markdown/render_repository.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step_source.dart';
import 'package:pluto/domain/stepik_repository.dart';
import 'package:pluto/domain/unit.dart';
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

    final localCourseSource = await sourceRepository.readCourse(courseDir);
    final courseId = localCourseSource.id;

    final localCourse = const RenderRepository().render(localCourseSource);

    final rawApi = (await initializeStepikClient()).rawApi;
    final stepikRepository = StepikRepository(rawApi);

    final remoteCourse = courseId != null
        ? await stepikRepository.readCourse(courseId)
        : null;

    final diffs = Diff.create(remoteCourse, localCourse).toList();

    final validation = const ValidationRepository().validate(localCourse);

    // TODO: put somewhere else to reuse code. Extension or validation result.
    // TODOs are author reminders: warn, but don't block the push.
    if (validation.todos.isNotEmpty) {
      stderr.writeln('Warning: ${validation.todos.length} unresolved TODO(s):');
      for (final todo in validation.todos) {
        stderr.writeln('  - $todo');
      }
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

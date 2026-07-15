import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/render_repository.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step_source.dart';
import 'package:pluto/domain/stepik_repository.dart';
import 'package:pluto/domain/unit.dart';

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

    final remoteCourse = courseId != null ? await stepikRepository.readCourse(courseId) : null;

    final diffs = Diff.create(remoteCourse, localCourse).toList();

    // creating / updating course on stepik.
    final course = await stepikRepository.applyDiff(localCourse, diffs);

    // saving in case ids added.
    await sourceRepository.writeCourse(course, courseDir);

    diffs.dump();

    print('--> Course created/updated. Check https://stepik.org/course/${course.id}');
  }
}

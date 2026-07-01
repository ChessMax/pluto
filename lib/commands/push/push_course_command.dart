import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/lesson.dart';
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
    //
    // final filePath = './my_other_course/source/section_01/unit_01/step_03.md';
    // final content = await File(filePath).readMdFile();
    //
    // return;

    final localCourse = await sourceRepository.readCourse(courseDir);
    final courseId = localCourse.id;

    final rawApi = (await initializeStepikClient()).rawApi;
    final stepikRepository = StepikRepository(rawApi);

    final remoteCourse = courseId != null ? await stepikRepository.readCourse(courseId) : null;

    final diffs = Diff.create(remoteCourse, localCourse).toList();

    final course = await stepikRepository.applyDiff(localCourse, diffs);

    // saving in case ids added.
    await sourceRepository.writeCourse(course, courseDir);

    print('--> Course created/updated. Check https://stepik.org/course/${course.id}');

    diffs.dump();

    // updating
    if (courseId != null) {
      final remoteCourse = await stepikRepository.readCourse(courseId);
      final course = await stepikRepository.updateCourse(remoteCourse, localCourse);

      await sourceRepository.writeCourse(course, courseDir);

      print('--> Course updated. Check https://stepik.org/course/$courseId');
    } else {
      // creating new course
      final course = await stepikRepository.writeCourse(localCourse);
      print('--> Course created. Check https://stepik.org/course/${course.id}');
    }
  }
}

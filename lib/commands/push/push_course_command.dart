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
    final courseDir = argResults!.rest[0];

    const sourceRepository = SourceRepository();
    final localCourse = await sourceRepository.readCourse(courseDir);
    final courseId = localCourse.id;

    final rawApi = (await initializeStepikClient()).rawApi;

    // final section = await rawApi.section.fetchById(715026);
    //
    // section?.title += ' updated';
    //
    // await rawApi.section.update(section!.id, {
    //   'title': section.title,
    //   'course': section.course,
    //   'position': section.position,
    // });
    //
    // await Future<void>.delayed(const Duration(seconds: 5000));
    //
    // return;

    final stepikRepository = StepikRepository(rawApi);

    final remoteCourse = courseId != null ? await stepikRepository.readCourse(courseId) : null;

    final diffs = Diff.create(remoteCourse, localCourse).toList();

    final course = await stepikRepository.applyDiff(localCourse, diffs);
    await sourceRepository.writeCourse(course, courseDir);



    print('--> Course created/updated. Check https://stepik.org/course/${course.id}');

    // diff.dump();

    // updating
    // if (courseId != null) {
    //   final remoteCourse = await stepikRepository.readCourse(courseId);
    //   final course = await stepikRepository.updateCourse(remoteCourse, localCourse);
    //
    //   await sourceRepository.writeCourse(course, courseDir);
    //
    //   print('--> Course updated. Check https://stepik.org/course/$courseId');
    // } else {
    //   // creating new course
    //   final course = await stepikRepository.writeCourse(localCourse);
    //   print('--> Course created. Check https://stepik.org/course/${course.id}');
    // }
  }
}

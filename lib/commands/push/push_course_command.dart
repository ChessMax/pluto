import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
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

    final localCourse = await const SourceRepository().readCourse(courseDir);
    final courseId = localCourse.id;

    final rawApi = (await initializeStepikClient()).rawApi;
    final stepikRepository = StepikRepository(rawApi);

    // updating
    if (courseId != null) {
      final remoteCourse = await stepikRepository.readCourse(courseId);
    } else {
      // creating new course
      final course = await stepikRepository.writeCourse(localCourse);
      print('--> Course created. Check https://stepik.org/course/${course.id}');
    }
  }
}

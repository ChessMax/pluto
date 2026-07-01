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

class StatusCommand extends Command<void> {
  @override
  String get name => 'status';

  @override
  String get description => 'Shows course status';

  StatusCommand();

  @override
  Future<void> run() async {
    final courseDir = argResults!.rest.isNotEmpty ? argResults!.rest[0] : Directory.current.path;

    print('Evaluating course status: $courseDir');

    const sourceRepository = SourceRepository();

    final localCourse = await sourceRepository.readCourse(courseDir);
    final courseId = localCourse.id;

    final rawApi = (await initializeStepikClient()).rawApi;
    final stepikRepository = StepikRepository(rawApi);

    final remoteCourse = courseId != null ? await stepikRepository.readCourse(courseId) : null;

    final diffs = Diff.create(remoteCourse, localCourse).toList();

    print('Course diff: ');
    diffs.dump();
  }
}

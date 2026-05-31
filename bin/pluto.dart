import 'dart:io';

import 'package:analyzer/dart/ast/token.dart';
import 'package:args/command_runner.dart' as args;
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:pluto/assets/templates/asset_templates.dart';
import 'package:pluto/commands/command.dart';
import 'package:pluto/commands/copy_command.dart';
import 'package:pluto/commands/export_course_command.dart';
import 'package:pluto/commands/init/init_course_command.dart';
import 'package:pluto/commands/stepik/stepik_command.dart';
import 'package:pluto/commands/stepik/stepik_list_command.dart';
import 'package:pluto/commands/version_command.dart';
import 'package:pluto/data/client.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/interceptors/bearer_interceptor.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/env.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';
import 'package:pluto/stepik_api/stepik_api.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source.dart';



const _commands = <Command>[
  VersionCommand(),

  // InitCourseCommand(),
];

void main(List<String> arguments) async {
  final runner = args.CommandRunner<void>("pluto", "Static course generator for stepik.org.")
    ..addCommand(CopyCommand())
    ..addCommand(InitCourseCommand())
    ..addCommand(StepikCommand());
  await runner.run(arguments);

  return;
  final c = await const SourceRepository().readCourse(join('.', 'my_second_course'));
  print('Course.id: ${c.id}');
  print('Course.title: ${c.title}');
  print('Course.desc: ${c.description}');

  await const SourceRepository().writeCourse(c, join('.', 'my_third_course'));

  return;
  //
  final commandName = arguments.first;
  for (final command in _commands) {
    if (command.name == commandName) {
      if (command is InitCourseCommand) {
        // await command.execute(arguments[1]);
      } else if (command is VersionCommand) {
        await command.execute();
      }
    }
  }

  return;

  final r = await initializeStepikClient();

  final api = r.api;
  final rawApi = r.rawApi;

  // final courseTemplate = await AssetTemplates.course;
  // print(await courseTemplate.render({'id': '1234', 'title': 'Практический курс \'\'\'Dart\'\'\'', 'title_en':'Practical course'}));
  // print(courseTemplate);
  //
  // return;

  await ExportCourseCommand(api: rawApi, format: .md).execute(134733);
  return;

  // await ListCommand(api: api).execute();
  // return ;

  // final cid = 134733;
  // final c = (await api.course.fetchById(cid));
  //
  // print(c);

  // await api.course.delete(283597);
  // await api.course.delete(283596);
  // await api.course.delete(283595);
  // await api.course.delete(283594);

  // final courses = await api.course.fetch();
  //
  // for (final course in courses!) {
  //   print('[${course.id}] ${course.title}');
  // }
  //
  // return;

  final lesson = await api.lesson.create({
    'lesson': {'title': 'My Lesson'},
  });

  final lessonId = lesson!.id;

  final stepResult = await api.stepSource.create({
    'stepSource': {
      'block': {'name': 'text', 'text': 'Hello World!'},
      'lesson': lessonId,
      'position': 1,
    },
  });

  final stepId = stepResult!.id;
  print('StepId: $stepId');
  // return;

  final updatedStep = await api.stepSource.update(
    stepId,
    {
      'stepSource': {
        'block': {
          'name': 'text',
          'text': 'Hi World!', //# <-- changed here :)
        },
        'lesson': lessonId,
        'position': 1,
      },
    },
  );

  print('Step updated: ${updatedStep!.id}');

  final multiChoiceStep = await api.stepSource.create({
    'stepSource': {
      'block': {
        'name': 'choice',
        'text': 'Pick one!',
        'source': {
          'options': [
            {'is_correct': false, 'text': '2+2=3', 'feedback': ''},
            {'is_correct': true, 'text': '2+2=4', 'feedback': ''},
            {'is_correct': false, 'text': '2+2=5', 'feedback': ''},
          ],
          'is_always_correct': false,
          'is_html_enabled': true,
          'sample_size': 3,
          'is_multiple_choice': false,
          'preserve_order': false,
          'is_options_feedback': false,
        },
      },
      'lesson': lessonId,
      'position': 2,
    },
  });

  print(multiChoiceStep);
  print('--> Check https://stepik.org/lesson/$lessonId');

  final course = await api.course.create({
    'course': {
      'title': 'Test course. Please, ignore it',
      'is_public': false,
      'is_enabled': false,
    },
  });
  final courseId = course!.id;
  print('Course ID: $courseId');
  print('');

  final section = await api.section.create({
    'section': {'title': 'My Section', 'course': courseId, 'position': 1},
  });
  final sectionId = section!.id;
  print('Section ID: $sectionId');

  // Add your existing lesson to this section (it is called unit)
  final createUnitResult = await api.unit.create({
    'unit': {'section': sectionId, 'lesson': lessonId, 'position': 1},
  });

  final unitId = createUnitResult!.id;
  print('Unit ID: $unitId');

  print('--> Check https://stepik.org/course/$courseId');
  // print(tokenResult);
}

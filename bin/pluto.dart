import 'package:dio/dio.dart';
import 'package:pluto/commands/export_course_command.dart';
import 'package:pluto/commands/list_command.dart';
import 'package:pluto/data/client.dart';
import 'package:pluto/data/interceptors/bearer_interceptor.dart';
import 'package:pluto/env.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';
import 'package:pluto/stepik_api/stepik_api.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

const _stepikApiUrl = 'https://stepik.org';

void main(List<String> arguments) async {
  final stepikDio = Dio(
    BaseOptions(
      baseUrl: _stepikApiUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
  stepikDio.interceptors.add(
    TalkerDioLogger(
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: true,
        // printResponseHeaders: true,
        printResponseMessage: true,
      ),
    ),
  );
  final client = StepikClient(stepikDio);
  final tokenResult = await client.getToken(
    Env.stepikClientId,
    Env.stepikClientSecret,
  );

  final token = tokenResult.toNullable();
  if (token == null) {
    throw 'Failed to get token';
  }

  stepikDio.interceptors.add(BearerInterceptor(token.accessToken));

  final api = StepikApi(stepikDio);
  final rawApi = RawStepikApi(stepikDio);
  
  await ExportCourseCommand(api: rawApi).execute(134733);
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
            {'is_correct': true,  'text': '2+2=4', 'feedback': ''},
            {'is_correct': false, 'text': '2+2=5', 'feedback': ''},
          ],
          'is_always_correct': false,
          'is_html_enabled': true,
          'sample_size': 3,
          'is_multiple_choice': false,
          'preserve_order': false,
          'is_options_feedback': false
        }
      },
      'lesson': lessonId,
      'position': 2
    }
  });

  print(multiChoiceStep);
  print('--> Check https://stepik.org/lesson/$lessonId');

  final course = await api.course.create({
    'course': {
      'title': 'Test course. Please, ignore it',
      'is_public': false,
      'is_enabled': false,
    }
  });
  final courseId = course!.id;
  print('Course ID: $courseId');
  print('');

  final section = await api.section.create({
    'section': {
      'title': 'My Section',
      'course': courseId,
      'position': 1
    }
  });
  final sectionId = section!.id;
  print('Section ID: $sectionId');

  // Add your existing lesson to this section (it is called unit)
  final createUnitResult = await api.unit.create({
    'unit': {
      'section': sectionId,
      'lesson': lessonId,
      'position': 1
    }
  });

  final unitId = createUnitResult!.id;
  print('Unit ID: $unitId');

  print('--> Check https://stepik.org/course/$courseId');
  // print(tokenResult);
}

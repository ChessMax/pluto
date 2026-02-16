import 'package:dio/dio.dart';
import 'package:pluto/data/client.dart';
import 'package:pluto/data/interceptors/bearer_interceptor.dart';
import 'package:pluto/env.dart';
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

  final lessonResult = await client.createLesson({
    'lesson': {'title': 'My Lesson'},
  });

  final lessonId = lessonResult.toNullable()!.lessons[0].id;

  final stepResult = await client.createStep({
    'stepSource': {
      'block': {'name': 'text', 'text': 'Hello World!'},
      'lesson': lessonId,
      'position': 1,
    },
  });

  final stepId = stepResult.toNullable()!.stepSources[0].id;
  print('StepId: $stepId');
  // return;

  final updateResult = await client.updateStep(
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

  print('Step updated: ${updateResult.toNullable()!.stepSources.first.id}');

  final multiChoiceStepResult = await client.createStep({
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

  print(multiChoiceStepResult);
  print('--> Check https://stepik.org/lesson/$lessonId');

  final courseResult = await client.createCourse({
    'course': {
      'title': 'My Course',
      'is_public': false,
    }
  });
  final courseId = courseResult.toNullable()!.courses[0].id;
  print('Course ID: $courseId');
  print('');

  final createSectionResult = await client.createSection({
    'section': {
      'title': 'My Section',
      'course': courseId,
      'position': 1
    }
  });
  final sectionId = createSectionResult.toNullable()!.sections[0].id;
  print('Section ID: $sectionId');


  // Add your existing lesson to this section (it is called unit)
  final createUnitResult = await client.createUnit({
    'unit': {
      'section': sectionId,
      'lesson': lessonId,
      'position': 1
    }
  });

  final unitId = createUnitResult.toNullable()!.units[0].id;
  print('Unit ID: $unitId');

  print('--> Check https://stepik.org/course/$courseId');
  // print(tokenResult);
}

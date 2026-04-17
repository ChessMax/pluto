import 'dart:convert';
import 'dart:io';

import 'package:pluto/stepik_api/raw_stepik_api.dart';

class ExportCourseCommand {
  final RawStepikApi _api;

  ExportCourseCommand({required RawStepikApi api}) : _api = api;

  String getValidFileName(String value) {
    final RegExp expression = RegExp(r'[^\w\s.-]', unicode: true);
    return value.replaceAll(expression, '').trim();
  }

  Future<void> execute(int courseId) async {
    final course = (await _api.course.fetchById(courseId))!;
    print(course);

    final sections = (await _api.section.fetchByIds(course.sections))!;
    print(sections);
    assert(sections.length == course.sections.length);

    for (final section in sections) {
      final unitIds = section.units;
      final units = (await _api.unit.fetchByIds(unitIds))!;
      assert(units.length == unitIds.length);

      for (final unit in units) {
        final lessonId = unit.lesson;
        final lesson = (await _api.lesson.fetchById(lessonId))!;

        final stepIds = lesson.steps;
        final steps = (await _api.step.fetchByIds(stepIds))!;
        assert(steps.length == stepIds.length);

        for (final step in steps) {
          final stepSource = (await _api.stepSource.fetchById(step.id))!;

          var path = [
            '${course['id'].toString().padLeft(2, '0')} ${getValidFileName(course.title)}',
            '${section['position'].toString().padLeft(2, '0')} ${getValidFileName(section.title)}',
            '${unit['position'].toString().padLeft(2, '0')} ${getValidFileName(lesson.title)}',
            '${lesson['id']}_${step['position'].toString().padLeft(2, '0')}_${step['block']['name']}.step'
          ];

          try {
            Directory(path.take(path.length - 1).join(Platform.pathSeparator))
                .createSync(recursive: true);
          } catch (e) {
            print(e);
            // Handle exceptions if any
          }

          var filename = path.join(Platform.pathSeparator);
          var file = File(filename);
          var data = {
            'block': stepSource['block'],
            'id': step.id.toString(),
            'time': DateTime.now().toIso8601String(),
          };

          file.writeAsStringSync(jsonEncode(data));
          print(filename);
        }
      }
    }
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';

enum ExportFormat { json, md }

class ExportCourseCommand {
  static final _encoder = JsonEncoder.withIndent('  ');

  final RawStepikApi _api;
  final ExportFormat _format;

  ExportCourseCommand({required RawStepikApi api, required ExportFormat format})
    : _api = api,
      _format = format;

  String getValidFileName(String value) {
    final expression = RegExp(r'[^\w\s.-]', unicode: true);
    return value.replaceAll(expression, '').trim();
  }

  Future<void> execute(int courseId) async {
    final exportDir = 'export';
    final exportTime = DateFormat('yyyyMMddHHmm').format(DateTime.now());

    final course = (await _api.course.fetchById(courseId))!;
    // print(course);

    // save course
    _writeJson([exportDir, '${courseId}_$exportTime', 'course.json'], course);

    final sections = (await _api.section.fetchByIds(course.sections))!;
    assert(sections.length == course.sections.length);

    for (final section in sections) {
      final paddedSectionPosition = (section.position.toString().padLeft(
        2,
        '0',
      ));
      _writeJson([
        exportDir,
        '${courseId}_$exportTime',
        paddedSectionPosition,
        'section_$paddedSectionPosition.json',
      ], section);

      // return;

      final unitIds = section.units;
      final units = (await _api.unit.fetchByIds(unitIds))!;
      assert(units.length == unitIds.length);

      for (final unit in units) {
        // save unit
        final paddedUnitPosition = (unit.position.toString().padLeft(2, '0'));
        _writeJson([
          exportDir,
          '${courseId}_$exportTime',
          paddedSectionPosition,
          paddedUnitPosition,
          'unit_$paddedUnitPosition.json',
        ], unit);

        final lessonId = unit.lesson;
        final lesson = (await _api.lesson.fetchById(lessonId))!;

        // save lesson
        _writeJson([
          exportDir,
          '${courseId}_$exportTime',
          paddedSectionPosition,
          paddedUnitPosition,
          'lesson.json',
        ], lesson);

        final stepIds = lesson.steps;
        final steps = (await _api.step.fetchByIds(stepIds))!;
        assert(steps.length == stepIds.length);

        for (final step in steps) {
          final stepSource = (await _api.stepSource.fetchById(step.id))!;

          // save step source
          _writeJson([
            exportDir,
            '${courseId}_$exportTime',
            paddedSectionPosition,
            paddedUnitPosition,
            'step-source_${lessonId}_${stepSource.position}.json',
          ], stepSource);

          // final dirPath = './export/$courseId/';
          //
          // var path = [
          //   'export',
          //   '$courseId',
          //   // '${course['id'].toString().padLeft(2, '0')} ${getValidFileName(course.title)}',
          //   '${section['position'].toString().padLeft(2, '0')} ${getValidFileName(section.title)}',
          //   '${unit['position'].toString().padLeft(2, '0')} ${getValidFileName(lesson.title)}',
          //   '${lesson['id']}_${step['position'].toString().padLeft(2, '0')}_${step['block']['name']}.step'
          // ];
          //
          // try {
          //   Directory(path.take(path.length - 1).join(Platform.pathSeparator))
          //       .createSync(recursive: true);
          // } catch (e) {
          //   print(e);
          //   // Handle exceptions if any
          // }
          //
          // var filename = path.join(Platform.pathSeparator);
          // var file = File(filename);
          // var data = {
          //   'block': stepSource['block'],
          //   'id': step.id.toString(),
          //   'time': DateTime.now().toIso8601String(),
          // };
          //
          // file.writeAsStringSync(jsonEncode(data));
          // print(filename);
        }
      }
    }
  }

  void _writeJson(List<String> path, JsonObject data) {
    try {
      final filePath = joinAll(path);
      final dir = dirname(filePath);
      Directory(dir).createSync(recursive: true);
      final file = File(filePath);
      file.writeAsStringSync(_encoder.convert(data));
    } catch (e) {
      print('Failed to write file ($path) with error: $e');
    }
  }
}

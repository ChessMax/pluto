import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:yaml/yaml.dart';

class SourceRepository {
  static final _sectionDirRegExp = RegExp(r'^section_(\d+)$');
  static final _unitDirRegExp = RegExp(r'^unit_(\d+)$');
  static final _stepFileRegExp = RegExp(r'^step_(\d+).md$');

  const SourceRepository();

  Future<List<T>> _readEntities<T>(
    String dirPath,
    RegExp nameMatcher,
    Future<T> Function(String path, int position) readEntity,
  ) async {
    final dir = Directory(dirPath);
    final entities = <T>[];

    await for (var file in dir.list()) {
      final position = nameMatcher.validateAndParsePosition(file.path);
      if (position != null) {
        final entity = await readEntity(file.path, int.parse(position));
        entities.add(entity);
      }
    }

    return entities;
  }

  Future<Step> readStep(String filePath, int position) async {
    final (frontMatter, content) = await File(filePath).readMd();

    final step = Step(
      id: frontMatter['id'] as int?,
      position: position,
      block: StepBlock(
        name: .parse(frontMatter['block']['name'] as String),
        text: frontMatter['block']['text'] as String,
      ),
    );

    return step;
  }

  Future<Lesson> readLesson(String dirPath, int position) async {
    final steps = await _readEntities(dirPath, _stepFileRegExp, readStep);

    final position = _unitDirRegExp.validateAndParsePosition(dirPath);
    final (frontMatter, content) = await File(
      join(dirPath, 'lesson_$position.md'),
    ).readMd();

    final lesson = Lesson(
      steps: steps,
      id: frontMatter['id'] as int?,
      title: frontMatter['title'] as String,
    );

    return lesson;
  }

  Future<Unit> readUnit(String dirPath, int position) async {
    final lesson = await readLesson(dirPath, position);

    final (frontMatter, content) = await File(
      join(dirPath, '${basename(dirPath)}.md'),
    ).readMd();

    final unit = Unit(
      id: frontMatter['id'] as int?,
      position: position,
      lesson: lesson,
    );
    return unit;
  }

  Future<Section> readSection(String dirPath, int position) async {
    final units = await _readEntities(dirPath, _unitDirRegExp, readUnit);

    final (frontMatter, content) = await File(
      join(dirPath, '${basename(dirPath)}.md'),
    ).readMd();

    final section = Section(
      id: frontMatter['id'] as int?,
      units: units,
      position: position,
      title: frontMatter['title'] as String,
      description: frontMatter['description'] as String? ?? '',
    );
    return section;
  }

  Future<Course> readCourse(String dirPath) async {
    final sections = await _readEntities(
      dirPath,
      _sectionDirRegExp,
      readSection,
    );

    final (frontMatter, content) = await File(
      join(dirPath, 'course.md'),
    ).readMd();

    final course = Course(
      id: frontMatter['id'] as int?,
      title: frontMatter['title'] as String,
      // TODO: other fields,
      titleEn: frontMatter['titleEn'] as String?,
      sections: sections,
      // summary: frontMatter['summary'] as String?,
      // acquiredAssets: frontMatter['acquiredAssets'] as String?,
      // description: frontMatter['description'] as String?,
      // targetAudience: frontMatter['targetAudience'] as String?,
      // requirements: frontMatter['requirements'] as String?,
      // learningFormat: frontMatter['learningFormat'] as String?,
      // acquiredSkills: frontMatter['acquiredSkills'] as String?,
    );

    return course;
  }
}

extension FileExtension on File {
  Future<(dynamic frontMatter, String content)> readMd() async {
    final content = await File(path).readAsString();

    if (content.startsWith('---')) {
      final frontMatterEndIndex = content.indexOf('---', 3);
      if (frontMatterEndIndex != -1) {
        final frontMatter = loadYaml(content.substring(3, frontMatterEndIndex));
        return (frontMatter, content.substring(frontMatterEndIndex + 3));
      }
    }

    return (null, content);
  }
}

extension on RegExp {
  String? validateAndParsePosition(String filePath) {
    final match = firstMatch(basename(filePath));
    if (match != null) {
      final position = match.group(1)!;
      return position;
    }
    return null;
  }
}
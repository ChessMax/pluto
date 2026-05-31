import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/assets/templates/asset_templates.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/template/template.dart';
import 'package:yaml/yaml.dart';
import 'package:markdown/markdown.dart' as md;

class SourceRepository {
  static final _sectionDirRegExp = RegExp(r'^section_(\d+)$');
  static final _unitDirRegExp = RegExp(r'^unit_(\d+)$');
  static final _stepFileRegExp = RegExp(r'^step_(\d+).md$');

  const SourceRepository();

  Map<String, String?> _readFields(String content) {
    final result = <String, String?>{};

    final document = md.Document();
    final blocks = document.parse(content);

    for (final element in blocks) {
      if (element is md.Element && element.tag == 'pre') {
        final codeElement = element.children?.firstOrNull as md.Element?;
        if (codeElement != null && codeElement.tag == 'code') {
          final classAttribute = codeElement.attributes['class'];
          if (classAttribute != null &&
              classAttribute.startsWith('language-')) {
            final field = classAttribute.substring(
              classAttribute.indexOf('language-') + 9,
            );
            final textElement = codeElement.children?.firstOrNull as md.Text;
            if (field.isNotEmpty) {
              result[field] = textElement.text;
            }
          }
        }
      }
    }

    return result;
  }

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

    final blockFields = _readFields(content);

    final step = Step(
      id: frontMatter['id'] as int?,
      position: position,
      block: StepBlock(
        name: .parse(frontMatter['block']['name'] as String),
        text: blockFields['block.text'] ?? '',
      ),
    );

    return step;
  }

  Future<Lesson> readLesson(String dirPath, int position) async {
    final steps = await _readEntities(dirPath, _stepFileRegExp, readStep)
      ..sort((a, b) => a.position.compareTo(b.position));
    ;

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
    final units = await _readEntities(dirPath, _unitDirRegExp, readUnit)
      ..sort((a, b) => a.position.compareTo(b.position));

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
    dirPath = join(dirPath, 'source');

    final sections =
        await _readEntities(
            dirPath,
            _sectionDirRegExp,
            readSection,
          )
          ..sort((a, b) => a.position.compareTo(b.position));

    final (frontMatter, content) = await File(
      join(dirPath, 'course.md'),
    ).readMd();

    final blockFields = _readFields(content);

    final course = Course(
      id: frontMatter['id'] as int?,
      title: frontMatter['title'] as String,
      titleEn: frontMatter['title_en'] as String?,
      sections: sections,
      summary: blockFields['summary'],
      acquiredAssets: blockFields['acquired_assets'],
      description: blockFields['description'],
      targetAudience: blockFields['target_audience'],
      requirements: blockFields['requirements'],
      learningFormat: blockFields['learning_format'],
      acquiredSkills: blockFields['acquired_skills'],
    );

    return course;
  }

  Future<void> _writeEntities<T>(
    String dirPath,
    List<T> entities,
    Future<void> Function(T entity, String dirPath) writeEntity,
  ) async {
    for (final entity in entities) {
      await writeEntity(entity, dirPath);
    }
  }

  Future<void> writeStep(Step step, String dirPath) async {
    final stepName = 'step_${step.position.toString().padLeft(2, '0')}';
    final stepPath = join(dirPath, '$stepName.md');
    final model = step.toJson();

    await renderToFile(
      stepPath,
      AssetTemplates.step,
      model,
    );
  }

  Future<void> writeLesson(Lesson lesson, String dirPath, int position) async {
    await _writeEntities(dirPath, lesson.steps, writeStep);

    await renderToFile(
      join(dirPath, 'lesson_${position.toString().padLeft(2, '0')}.md'),
      AssetTemplates.lesson,
      lesson.toJson(),
    );
  }

  Future<void> writeUnit(Unit unit, String sectionDirPath) async {
    final unitName = 'unit_${unit.position.toString().padLeft(2, '0')}';

    final unitDirPath = join(sectionDirPath, unitName);
    await writeLesson(unit.lesson, unitDirPath, unit.position);

    await renderToFile(
      join(unitDirPath, '$unitName.md'),
      AssetTemplates.unit,
      unit.toJson(),
    );
  }

  Future<void> writeSection(Section section, String dirPath) async {
    final sectionName =
        'section_${section.position.toString().padLeft(2, '0')}';
    final sectionDirPath = join(dirPath, sectionName);
    await _writeEntities(sectionDirPath, section.units, writeUnit);

    await renderToFile(
      join(sectionDirPath, '$sectionName.md'),
      AssetTemplates.section,
      section.toJson(),
    );
  }

  Future<void> writeCourse(Course course, String dirPath) async {
    final sourceDirPath = join(dirPath, 'source');

    await _writeEntities(sourceDirPath, course.sections, writeSection);

    final coursePath = join(sourceDirPath, 'course.md');
    final model = course.toJson();

    await renderToFile(coursePath, AssetTemplates.course, model);
  }

  Future<void> renderToFile(
    String path,
    Future<Template> template,
    dynamic model,
  ) async {
    print('Creating `$path` ...');
    await template.renderToFile(path, model);
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

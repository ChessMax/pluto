import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/source_file.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/md/abbreviations_format.dart';
import 'package:pluto/md/course_format.dart';
import 'package:pluto/md/lesson_format.dart';
import 'package:pluto/md/md_document.dart';
import 'package:pluto/md/section_format.dart';
import 'package:pluto/md/step_format.dart';
import 'package:pluto/md/unit_format.dart';

/// A course together with the source files it was read from.
class CourseSource {
  final Course course;
  final List<SourceFile> files;

  const CourseSource({required this.course, required this.files});
}

/// Reads and writes a course as a directory tree.
///
/// This layer owns only the tree: which file holds what, how entities are
/// ordered, and when a file should not exist. What goes *inside* a file belongs
/// to the formats in `lib/md/`, so a rewrite preserves whatever an author put
/// there that the model does not describe.
class SourceRepository {
  static final _sectionDirRegExp = RegExp(r'^section_(\d+)$');
  static final _unitDirRegExp = RegExp(r'^unit_(\d+)$');
  static final _stepFileRegExp = RegExp(r'^step_(\d+).md$');

  const SourceRepository();

  /// Reads [path]'s full raw text and records it as a [SourceFile], so callers
  /// know exactly which files the course read (and can locate findings in them).
  ///
  /// The recorded path is absolute: IDE consoles (IntelliJ, VS Code) only turn
  /// `path:line:column` output into a clickable link when the path is absolute
  /// or resolvable against their own base dir, which is not the cwd `pluto` ran
  /// from.
  Future<String> _readAndRecord(String path, List<SourceFile> sources) async {
    final content = await File(path).readAsString();
    sources.add(SourceFile(path: normalize(absolute(path)), content: content));
    return content;
  }

  Future<MdDocument> _readDocument(
    String path,
    List<SourceFile> sources,
  ) async {
    return MdDocument.parse(await _readAndRecord(path, sources));
  }

  /// The file as it stands, so a write can put back what it does not change.
  /// A file that does not exist yet contributes nothing to preserve.
  Future<MdDocument> _base(String path) async {
    final file = File(path);
    if (!file.existsSync()) return MdDocument.empty;
    return MdDocument.parse(await file.readAsString());
  }

  Future<void> _write(String path, String content) async {
    print('Creating `$path` ...');
    Directory(dirname(path)).createSync(recursive: true);
    await File(path).writeAsString(content);
  }

  /// Removes [path] if it exists. An empty value leaves no file rather than an
  /// empty one, which is what the reader treats as absent anyway.
  void _deleteIfExists(String path) {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }

  Future<List<T>> _readEntities<T>(
    String dirPath,
    RegExp nameMatcher,
    Future<T> Function(String path, int position) readEntity,
  ) async {
    final dir = Directory(dirPath);
    final entities = <T>[];

    final filesWithPosition = <(String, String)>[];

    await for (var file in dir.list()) {
      final position = nameMatcher.validateAndParsePosition(file.path);
      if (position != null) {
        filesWithPosition.add((file.path, position));
      }
    }

    filesWithPosition.sort((a, b) {
      return int.parse(a.$2).compareTo(int.parse(b.$2));
    });

    for (final (filePath, position) in filesWithPosition) {
      final entity = await readEntity(filePath, int.parse(position));
      entities.add(entity);
    }

    return entities;
  }

  Future<Step> readStep(
    String filePath,
    int position,
    List<SourceFile> sources,
  ) async {
    final raw = await _readAndRecord(filePath, sources);
    try {
      return const StepFormat().read(raw, position: position);
    } catch (e) {
      print('Failed to parse file `$filePath` with error: \n$e');
      rethrow;
    }
  }

  Future<Lesson> readLesson(
    String dirPath,
    int position,
    List<SourceFile> sources,
  ) async {
    final steps =
        await _readEntities(
            dirPath,
            _stepFileRegExp,
            (path, pos) => readStep(path, pos, sources),
          )
          ..sort((a, b) => a.position.compareTo(b.position));

    final document = await _readDocument(
      join(dirPath, 'lesson_${position.toString().padLeft(2, '0')}.md'),
      sources,
    );

    return const LessonFormat().read(document, steps: steps);
  }

  Future<Unit> readUnit(
    String dirPath,
    int position,
    List<SourceFile> sources,
  ) async {
    final lesson = await readLesson(dirPath, position, sources);
    final document = await _readDocument(
      join(dirPath, '${basename(dirPath)}.md'),
      sources,
    );

    return const UnitFormat().read(
      document,
      position: position,
      lesson: lesson,
    );
  }

  Future<Section> readSection(
    String dirPath,
    int position,
    List<SourceFile> sources,
  ) async {
    final units =
        await _readEntities(
            dirPath,
            _unitDirRegExp,
            (path, pos) => readUnit(path, pos, sources),
          )
          ..sort((a, b) => a.position.compareTo(b.position));

    final document = await _readDocument(
      join(dirPath, '${basename(dirPath)}.md'),
      sources,
    );

    return const SectionFormat().read(
      document,
      position: position,
      units: units,
    );
  }

  /// Reads a course and the raw source files it was read from.
  Future<CourseSource> readCourseSource(String dirPath) async {
    final sources = <SourceFile>[];
    final course = await _readCourse(dirPath, sources);
    return CourseSource(course: course, files: sources);
  }

  Future<Course> readCourse(String dirPath) async {
    return _readCourse(dirPath, <SourceFile>[]);
  }

  Future<Course> _readCourse(String dirPath, List<SourceFile> sources) async {
    dirPath = join(dirPath, 'source');

    final sections =
        await _readEntities(
            dirPath,
            _sectionDirRegExp,
            (path, pos) => readSection(path, pos, sources),
          )
          ..sort((a, b) => a.position.compareTo(b.position));

    final document = await _readDocument(join(dirPath, 'course.md'), sources);

    // TODO: validate? check position and other things
    return const CourseFormat().read(
      document,
      sections: sections,
      prose: await _readProse(dirPath, sources),
      abbreviations: await _readAbbreviations(dirPath, sources),
    );
  }

  /// Reads the course's prose fields from `source/<field>.md`.
  Future<Map<String, String?>> _readProse(
    String dirPath,
    List<SourceFile> sources,
  ) async {
    final fields = <String, String?>{};

    for (final field in CourseFormat.proseFields) {
      final path = join(dirPath, '$field.md');
      if (File(path).existsSync()) {
        fields[field] = (await _readAndRecord(path, sources)).trim();
      }
    }

    return fields;
  }

  /// Reads `source/abbreviations.md`, a file of front matter only. It is
  /// optional: a course that declares no acronyms simply has no such file.
  Future<Abbreviations> _readAbbreviations(
    String dirPath,
    List<SourceFile> sources,
  ) async {
    final path = join(dirPath, 'abbreviations.md');
    if (!File(path).existsSync()) return Abbreviations.empty;

    return const AbbreviationsFormat().read(
      await _readDocument(path, sources),
    );
  }

  Future<void> writeStep(Step step, String dirPath) async {
    final stepName = 'step_${step.position.toString().padLeft(2, '0')}';
    final path = join(dirPath, '$stepName.md');

    await _write(path, const StepFormat().write(step, base: await _base(path)));
  }

  Future<void> writeLesson(Lesson lesson, String dirPath, int position) async {
    for (final step in lesson.steps) {
      await writeStep(step, dirPath);
    }

    final path = join(
      dirPath,
      'lesson_${position.toString().padLeft(2, '0')}.md',
    );

    await _write(
      path,
      const LessonFormat().write(lesson, base: await _base(path)),
    );
  }

  Future<void> writeUnit(Unit unit, String sectionDirPath) async {
    final unitName = 'unit_${unit.position.toString().padLeft(2, '0')}';
    final unitDirPath = join(sectionDirPath, unitName);

    await writeLesson(unit.lesson, unitDirPath, unit.position);

    final path = join(unitDirPath, '$unitName.md');
    await _write(path, const UnitFormat().write(unit, base: await _base(path)));
  }

  Future<void> writeSection(Section section, String dirPath) async {
    final sectionName =
        'section_${section.position.toString().padLeft(2, '0')}';
    final sectionDirPath = join(dirPath, sectionName);

    for (final unit in section.units) {
      await writeUnit(unit, sectionDirPath);
    }

    final path = join(sectionDirPath, '$sectionName.md');
    await _write(
      path,
      const SectionFormat().write(section, base: await _base(path)),
    );
  }

  // TODO: difficult to understand structure
  // maybe should be more visible something like this
  // [./source/section_%sectionPosition%/unit_%unitPosition%/lesson_%unitPosition%]
  // or something like that:
  // [
  // ./source/section_%sectionPosition%/
  // unit_%unitPosition%/
  // unit_%unitPosition%.md
  // ]
  Future<void> writeCourse(Course course, String dirPath) async {
    final sourceDirPath = join(dirPath, 'source');

    for (final section in course.sections) {
      await writeSection(section, sourceDirPath);
    }

    final path = join(sourceDirPath, 'course.md');
    await _write(
      path,
      const CourseFormat().write(course, base: await _base(path)),
    );

    await _writeProse(course, sourceDirPath);

    // `abbreviations.md` is deliberately not written back. Acronyms are a local
    // render-time concern with no counterpart on Stepik, so nothing a command
    // does can change them: rewriting the file could only ever reproduce what
    // is already on disk, or damage it.
  }

  /// Writes each prose field to its own `source/<field>.md`.
  ///
  /// The value is written alone, with no heading or hint comment around it: a
  /// hint an author keeps lives *inside* the file and so comes back as part of
  /// the value, and re-decorating on write would duplicate it on every push.
  Future<void> _writeProse(Course course, String sourceDirPath) async {
    for (final field in CourseFormat.proseFields) {
      final path = join(sourceDirPath, '$field.md');
      final value = CourseFormat.prose(course, field);

      if (value == null || value.isEmpty) {
        _deleteIfExists(path);
        continue;
      }

      await _write(path, '$value\n');
    }
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

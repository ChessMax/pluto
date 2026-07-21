import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/source_file.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/md/step_format.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('pluto_source_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  Future<Step> readStep(String source) async {
    final path = join(dir.path, 'step_01.md');
    File(path).writeAsStringSync(source);
    return const SourceRepository().readStep(path, 1, <SourceFile>[]);
  }

  Future<Course> readCourse({
    required String courseMd,
    Map<String, String> fields = const {},
  }) async {
    final source = Directory(join(dir.path, 'source'))..createSync();
    File(join(source.path, 'course.md')).writeAsStringSync(courseMd);

    for (final MapEntry(:key, :value) in fields.entries) {
      File(join(source.path, '$key.md')).writeAsStringSync(value);
    }

    return const SourceRepository().readCourse(dir.path);
  }

  group('Course prose fields', () {
    const frontMatter = '---\nid: null\ntitle: Test\n---\n';

    test('Should read fields from their own files', () async {
      final course = await readCourse(
        courseMd: frontMatter,
        fields: {
          'summary': 'A *summary*.\n',
          'description': 'A description.\n',
        },
      );

      expect(course.summary, 'A *summary*.');
      expect(course.description, 'A description.');
    });

    test('Should leave absent fields null', () async {
      final course = await readCourse(courseMd: frontMatter);
      expect(course.summary, isNull);
      expect(course.requirements, isNull);
    });

    test('Should ignore a fenced field left in course.md', () async {
      final course = await readCourse(
        courseMd: '$frontMatter\n```summary\nFrom the fence.\n```\n',
      );
      expect(course.summary, isNull);
    });

    test('Should read the file when a course has both', () async {
      final course = await readCourse(
        courseMd: '$frontMatter\n```summary\nFrom the fence.\n```\n',
        fields: {'summary': 'From the file.\n'},
      );
      expect(course.summary, 'From the file.');
    });
  });

  group('Course round trip', () {
    Future<Course> writeThenRead(Course course) async {
      await const SourceRepository().writeCourse(course, dir.path);
      return const SourceRepository().readCourse(dir.path);
    }

    String sourceFile(String name) =>
        File(join(dir.path, 'source', name)).readAsStringSync();

    test('Should keep prose fields across a write', () async {
      final course = Course(
        id: 1,
        title: 'Test',
        summary: 'A *summary*.',
        description: 'A description.',
        acquiredSkills: 'One\nTwo',
      );

      final read = await writeThenRead(course);

      expect(read.summary, 'A *summary*.');
      expect(read.description, 'A description.');
      expect(read.acquiredSkills, 'One\nTwo');
    });

    test('Should write prose to its own file, not into course.md', () async {
      await writeThenRead(Course(id: 1, title: 'Test', summary: 'A summary.'));

      expect(sourceFile('summary.md'), 'A summary.\n');
      expect(sourceFile('course.md'), isNot(contains('```')));
      expect(sourceFile('course.md'), isNot(contains('A summary.')));
    });

    test('Should not duplicate a hint comment kept in the value', () async {
      final course = Course(
        id: 1,
        title: 'Test',
        summary: '<!-- keep me -->\nA summary.',
      );

      final read = await writeThenRead(course);
      final again = await writeThenRead(read);

      expect(again.summary, '<!-- keep me -->\nA summary.');
      expect('\n'.allMatches(sourceFile('summary.md')).length, 2);
    });

    test('Should be idempotent', () async {
      final course = Course(
        id: 1,
        title: 'Test',
        summary: 'A summary.',
        requirements: 'Some requirements.',
        abbreviations: const Abbreviations({'PL': 'Programming Language'}),
      );

      final first = await writeThenRead(course);
      final firstCourseMd = sourceFile('course.md');
      final firstSummary = sourceFile('summary.md');

      await writeThenRead(first);

      expect(sourceFile('course.md'), firstCourseMd);
      expect(sourceFile('summary.md'), firstSummary);
    });

    test('Should leave no file for an absent field', () async {
      await writeThenRead(Course(id: 1, title: 'Test', summary: 'A summary.'));

      expect(
        File(join(dir.path, 'source', 'description.md')).existsSync(),
        isFalse,
      );
    });

    test('Should read abbreviations of any script', () async {
      final course = await readCourse(
        courseMd: '---\nid: 1\ntitle: Test\n---\n',
        fields: {
          'abbreviations':
              "---\nPL: Programming Language\nЯП: Язык программирования\n"
              "RTFM: 'Read: the manual'\n---\n",
        },
      );

      expect(course.abbreviations.resolve('PL'), 'Programming Language');
      expect(course.abbreviations.resolve('ЯП'), 'Язык программирования');
      expect(course.abbreviations.resolve('RTFM'), 'Read: the manual');
    });

    /// Acronyms are local-only, so no command can change them and the file is
    /// never rewritten — a `push` that touched it could only ever damage it.
    test('Should leave abbreviations.md untouched on write', () async {
      const written =
          '---\n# hand-written\nЯП: Язык программирования\nHTTP/2: v2\n---\n';
      final course = await readCourse(
        courseMd: '---\nid: 1\ntitle: Test\n---\n',
        fields: {'abbreviations': written},
      );

      await const SourceRepository().writeCourse(course, dir.path);

      expect(sourceFile('abbreviations.md'), written);
    });

    test('Should leave no abbreviations file when none are declared', () async {
      await writeThenRead(Course(id: 1, title: 'Test'));

      expect(
        File(join(dir.path, 'source', 'abbreviations.md')).existsSync(),
        isFalse,
      );
    });
  });

  group('Choice options', () {
    test('Should read the checkbox section', () async {
      final step =
          await readStep('''
---
id: null
type: single_choice
---

Which is the capital?

## options

- [x] The capital is **Paris**
  > Right — capital since 987.
- [ ] Lyon
  > No, the third-largest city.
''')
              as ChoiceStep;

      expect(step.options.map((o) => o.isCorrect), [true, false]);
      expect(step.options.first.text, 'The capital is **Paris**');
      expect(step.options.first.feedback, 'Right — capital since 987.');
    });

    test('Should keep options out of the step text', () async {
      final step =
          await readStep('''
---
id: null
type: single_choice
---

Which is the capital?

## options

- [x] Paris
''')
              as ChoiceStep;

      expect(step.text, 'Which is the capital?');
    });

    test('Should survive a codec round-trip', () async {
      const original = ChoiceStep(
        id: null,
        position: 1,
        text: 'Which compile?',
        isMultipleChoice: true,
        isAlwaysCorrect: false,
        preserveOrder: false,
        isHtmlEnabled: true,
        options: [
          ChoiceOption(
            text: 'The capital is **Paris**',
            feedback: 'Right — capital since 987.',
            isCorrect: true,
          ),
          ChoiceOption(text: 'Lyon', feedback: '', isCorrect: false),
        ],
      );

      final step =
          await readStep(const StepFormat().write(original)) as ChoiceStep;

      expect(step.text, original.text);
      expect(step.options.length, original.options.length);
      for (final (i, option) in step.options.indexed) {
        expect(option.text, original.options[i].text);
        expect(option.feedback, original.options[i].feedback);
        expect(option.isCorrect, original.options[i].isCorrect);
      }
    });
  });
}

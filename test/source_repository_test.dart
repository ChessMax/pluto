import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/source_file.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/step_codec.dart';
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

    test('Should still read legacy fenced fields', () async {
      final course = await readCourse(
        courseMd: '$frontMatter\n```summary\nFrom the fence.\n```\n',
      );
      expect(course.summary, 'From the fence.\n');
    });

    test('Should prefer the file when a course has both', () async {
      final course = await readCourse(
        courseMd: '$frontMatter\n```summary\nFrom the fence.\n```\n',
        fields: {'summary': 'From the file.\n'},
      );
      expect(course.summary, 'From the file.');
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

    test('Should still read the legacy options fence', () async {
      final step =
          await readStep('''
---
id: null
type: single_choice
---

Which is the capital?

```options
true
Paris
Capital since 987.
false
Lyon

```
''')
              as ChoiceStep;

      expect(step.options.map((o) => o.isCorrect), [true, false]);
      expect(step.options.first.text, 'Paris');
      expect(step.options.first.feedback, 'Capital since 987.');
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

      final step = await readStep(const StepCodec().write(original))
          as ChoiceStep;

      expect(step.text, original.text);
      expect(step.options.length, original.options.length);
      for (final (i, option) in step.options.indexed) {
        expect(option.text, original.options[i].text);
        expect(option.feedback, original.options[i].feedback);
        expect(option.isCorrect, original.options[i].isCorrect);
      }
    });

    test('Should prefer the section when a file has both', () async {
      final step =
          await readStep('''
---
id: null
type: single_choice
---

## options

- [x] From the section

```options
true
From the fence

```
''')
              as ChoiceStep;

      expect(step.options.single.text, 'From the section');
    });
  });
}

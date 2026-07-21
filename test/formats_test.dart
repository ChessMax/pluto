import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/md/abbreviations_format.dart';
import 'package:pluto/md/course_format.dart';
import 'package:pluto/md/lesson_format.dart';
import 'package:pluto/md/md_document.dart';
import 'package:pluto/md/section_format.dart';
import 'package:pluto/md/step_format.dart';
import 'package:pluto/md/unit_format.dart';
import 'package:test/test.dart';

void main() {
  group('StepFormat', () {
    Step roundTrip(Step step) {
      return const StepFormat().read(
        const StepFormat().write(step),
        position: step.position,
      );
    }

    /// A step written twice running through the same file must not drift, or a
    /// `push` would show a diff against a course nobody edited.
    void expectStable(Step step) {
      const format = StepFormat();
      final once = format.write(step);
      final twice = format.write(format.read(once, position: step.position));

      expect(twice, once);
    }

    test('Should round trip a text step', () {
      const step = TextStep(
        id: 7,
        position: 1,
        text: 'Hello, **world**.',
        label: 'intro',
      );

      final read = roundTrip(step) as TextStep;

      expect(read.id, 7);
      expect(read.text, 'Hello, **world**.');
      expect(read.label, 'intro');
      expectStable(step);
    });

    test('Should round trip a choice step', () {
      const step = ChoiceStep(
        id: null,
        position: 2,
        text: 'Which compile?',
        isMultipleChoice: true,
        isAlwaysCorrect: false,
        preserveOrder: true,
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

      final read = roundTrip(step) as ChoiceStep;

      expect(read.isMultipleChoice, isTrue);
      expect(read.preserveOrder, isTrue);
      expect(read.text, 'Which compile?');
      expect(read.options.map((o) => o.text), [
        'The capital is **Paris**',
        'Lyon',
      ]);
      expect(read.options.map((o) => o.isCorrect), [true, false]);
      expect(read.options.first.feedback, 'Right — capital since 987.');
      expectStable(step);
    });

    test('Should round trip a code step', () {
      const step = CodeStep(
        id: 3,
        position: 1,
        text: 'Write a program.',
        code: "void main() {\n  print('hi');\n}",
        tests: [TestCase(input: '2 3', output: '5')],
        samples: [TestCase(input: '1 2', output: '3')],
        samplesCount: 1,
      );

      final read = roundTrip(step) as CodeStep;

      expect(read.code, "void main() {\n  print('hi');\n}");
      expect(read.tests.single.input, '2 3');
      expect(read.samples.single.output, '3');
      expectStable(step);
    });

    test('Should round trip a free answer step', () {
      const step = FreeAnswerStep(
        id: null,
        position: 1,
        text: 'Tell us why.',
        manualScoring: true,
        isAttachmentsEnabled: true,
        isHtmlEnabled: false,
      );

      final read = roundTrip(step) as FreeAnswerStep;

      expect(read.manualScoring, isTrue);
      expect(read.isAttachmentsEnabled, isTrue);
      expect(read.isHtmlEnabled, isFalse);
      expectStable(step);
    });

    test('Should keep a body with no text from growing blank lines', () {
      const step = TextStep(id: null, position: 1, text: '');

      expectStable(step);
      expect(const StepFormat().write(step), '---\nid:\ntype: text\n---\n\n');
    });

    test('Should drop a flag that no longer applies to the type', () {
      const choice = ChoiceStep(
        id: null,
        position: 1,
        text: 'Q',
        isMultipleChoice: false,
        isAlwaysCorrect: false,
        preserveOrder: false,
        isHtmlEnabled: true,
        options: [],
      );
      final asChoice = const StepFormat().write(choice);

      const text = TextStep(id: null, position: 1, text: 'Q');
      final rewritten = const StepFormat().write(
        text,
        base: MdDocument.parse(asChoice),
      );

      expect(asChoice, contains('preserve_order'));
      expect(rewritten, isNot(contains('preserve_order')));
      expect(rewritten, contains('type: text'));
    });

    test('Should keep a comment an author left in front matter', () {
      const base =
          '---\n# the id comes from Stepik\nid: 5\ntype: text\n---\n\nHi.\n';

      final rewritten = const StepFormat().write(
        const TextStep(id: 5, position: 1, text: 'Bye.'),
        base: MdDocument.parse(base),
      );

      expect(rewritten, contains('# the id comes from Stepik'));
      expect(rewritten, contains('Bye.'));
      expect(rewritten, isNot(contains('Hi.')));
    });
  });

  group('SectionFormat', () {
    test('Should round trip, description included', () {
      final section = Section(
        id: 4,
        position: 2,
        units: const [],
        title: 'Basics',
        description: 'What we cover.',
      );

      final written = const SectionFormat().write(section);
      final read = const SectionFormat().read(
        MdDocument.parse(written),
        position: 2,
        units: const [],
      );

      expect(read.id, 4);
      expect(read.title, 'Basics');
      expect(read.description, 'What we cover.');
    });

    test('Should write no description when there is none', () {
      final written = const SectionFormat().write(
        Section(
          id: null,
          position: 1,
          units: const [],
          title: 'Basics',
          description: '',
        ),
      );

      expect(written, isNot(contains('description')));
    });
  });

  group('UnitFormat and LessonFormat', () {
    test('Should round trip a unit', () {
      final lesson = Lesson(id: null, title: 'L', steps: const []);
      final written = const UnitFormat().write(
        Unit(id: 9, position: 3, lesson: lesson),
      );

      final read = const UnitFormat().read(
        MdDocument.parse(written),
        position: 3,
        lesson: lesson,
      );

      expect(read.id, 9);
      expect(read.position, 3);
    });

    test('Should round trip a lesson', () {
      final written = const LessonFormat().write(
        Lesson(id: 11, title: 'Getting started', steps: const []),
      );

      final read = const LessonFormat().read(
        MdDocument.parse(written),
        steps: const [],
      );

      expect(read.id, 11);
      expect(read.title, 'Getting started');
    });
  });

  group('CourseFormat', () {
    Course read(String source) => const CourseFormat().read(
      MdDocument.parse(source),
      sections: const [],
      prose: const {},
      abbreviations: Abbreviations.empty,
    );

    test('Should round trip front matter and config', () {
      final course = Course(
        id: 42,
        title: 'Dart',
        titleEn: 'Dart course',
        config: const CourseConfig({'support_email': 'help@example.com'}),
      );

      final result = read(const CourseFormat().write(course));

      expect(result.id, 42);
      expect(result.title, 'Dart');
      expect(result.titleEn, 'Dart course');
      expect(result.config.resolve('support_email'), 'help@example.com');
    });

    test('Should keep the body and comments below the front matter', () {
      const base =
          '---\n'
          '# title max 64 chars\n'
          'id: 1\n'
          'title: Old\n'
          '---\n'
          '\n'
          '<!-- a note the author keeps -->\n';

      final written = const CourseFormat().write(
        Course(id: 1, title: 'New'),
        base: MdDocument.parse(base),
      );

      expect(written, contains('# title max 64 chars'));
      expect(written, contains('<!-- a note the author keeps -->'));
      expect(written, contains('title: New'));
    });
  });

  group('AbbreviationsFormat', () {
    test('Should round trip terms of any script', () {
      const abbreviations = Abbreviations({
        'PL': 'Programming Language',
        'ЯП': 'Язык программирования',
        'RTFM': 'Read: the manual',
      });

      final written = const AbbreviationsFormat().write(abbreviations);
      final read = const AbbreviationsFormat().read(MdDocument.parse(written));

      expect(read.values, abbreviations.values);
    });

    test('Should write nothing when none are declared', () {
      expect(const AbbreviationsFormat().write(Abbreviations.empty), isEmpty);
    });

    test('Should drop a term that is no longer declared', () {
      final base = MdDocument.parse(
        '---\nPL: Programming Language\nOS: System\n---\n',
      );

      final written = const AbbreviationsFormat().write(
        const Abbreviations({'PL': 'Programming Language'}),
        base: base,
      );

      expect(written, contains('PL:'));
      expect(written, isNot(contains('OS:')));
    });
  });
}

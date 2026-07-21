import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/domain/validation_repository.dart';
import 'package:pluto/markdown/diagnostic_styles.dart';
import 'package:pluto/markdown/stepik_markdown_renderer.dart';
import 'package:pluto/md/course_format.dart';
import 'package:pluto/md/md_document.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  const config = CourseConfig({
    'support_email': 'help@example.com',
    'chat': 'https://example.com/chat',
    'team': 'Pluto Team',
  });

  const renderer = StepikMarkdownRenderer(config: config);

  /// Text content of [html], with element tags dropped but entities kept.
  ///
  /// `AutoItalicTransformer` wraps prose in `<em>` — splitting on `@` and `_` —
  /// so substituted text is rarely contiguous in the markup even though it is
  /// intact on the page.
  String textOf(String html) =>
      html.replaceAll(RegExp(r'</?[a-zA-Z][^>]*>'), '');

  group('CourseConfig.fromYaml', () {
    CourseConfig parse(String yaml) =>
        CourseConfig.fromYaml(loadYaml(yaml)['config']);

    test('reads scalar values', () {
      final result = parse('config:\n  support_email: help@example.com\n');
      expect(result.resolve('support_email'), 'help@example.com');
    });

    test('stringifies non-string scalars so they need no quoting', () {
      final result = parse('config:\n  year: 2026\n  beta: true\n');
      expect(result.resolve('year'), '2026');
      expect(result.resolve('beta'), 'true');
    });

    test('a null value is dropped rather than rendered as "null"', () {
      final result = parse('config:\n  empty:\n');
      expect(result.resolve('empty'), isNull);
      expect(result.isEmpty, isTrue);
    });

    test('missing config block yields an empty config', () {
      expect(CourseConfig.fromYaml(null).isEmpty, isTrue);
    });

    test('rejects a non-scalar value', () {
      expect(() => parse('config:\n  nested:\n    a: 1\n'), throwsA(anything));
      expect(() => parse('config:\n  list:\n    - a\n'), throwsA(anything));
    });

    test('rejects an invalid key', () {
      expect(() => parse('config:\n  1bad: x\n'), throwsA(anything));
      expect(() => parse('config:\n  has-dash: x\n'), throwsA(anything));
    });
  });

  group('front matter round-trip', () {
    Course read(String courseMd) => const CourseFormat().read(
      MdDocument.parse(courseMd),
      sections: const [],
      prose: const {},
      abbreviations: Abbreviations.empty,
    );

    test('block is re-readable as the same config', () {
      final written = const CourseFormat().write(
        Course(id: 1, title: 'Test', config: config),
      );

      expect(read(written).config.values, config.values);
    });

    test('an empty config writes nothing', () {
      final written = const CourseFormat().write(
        Course(id: 1, title: 'Test'),
      );

      expect(written, isNot(contains('config')));
    });
  });

  group('rendering', () {
    test('expands a reference in text', () {
      final html = renderer.render('Greetings from {{config.team}}.');
      expect(html, contains('Pluto Team'));
      expect(html, isNot(contains('{{')));
    });

    test('tolerates surrounding whitespace', () {
      expect(renderer.render('{{ config.team }}'), contains('Pluto Team'));
    });

    /// A destination is percent-encoded before transformers run, so this only
    /// works because [substituteConfigInUrl] matches the encoded spelling too.
    test('expands inside a link destination', () {
      final html = renderer.render(
        '[write us](mailto:{{config.support_email}})',
      );
      expect(html, contains('href="mailto:help@example.com"'));
    });

    /// The Markdown parser does not treat a destination containing spaces as a
    /// link at all, so inside `(...)` the reference must be written tight.
    test('a spaced reference in a destination is not a link', () {
      final html = renderer.render('[u](mailto:{{ config.support_email }})');
      expect(html, isNot(contains('href="mailto:help@example.com"')));
    });

    test('expands inside an image source', () {
      final html = renderer.render('![c]({{config.chat}}/logo.png)');
      expect(html, contains('src="https://example.com/chat/logo.png"'));
    });

    test('an unknown key is left exactly as written', () {
      final html = renderer.render('Write to {{config.support_emial}}.');
      expect(textOf(html), contains('{{config.support_emial}}'));
    });

    test('an unknown key is badged so it cannot be read past', () {
      final html = renderer.render('Write to {{config.support_emial}}.');
      expect(html, contains('<span style="$errorStyle">'));
    });

    test('a resolved key is plain text, with no badge', () {
      final html = renderer.render('Write to {{config.support_email}}.');
      expect(html, isNot(contains(errorStyle)));
    });

    /// Unlike a literally typed address, a substituted one is not re-scanned for
    /// autolinks — write `[text](mailto:{{config.support_email}})` for a link.
    test('a substituted value is inserted as plain text, not autolinked', () {
      final html = renderer.render('Write to {{config.support_email}}.');
      expect(html, contains('example.com'));
      expect(html, isNot(contains('href="mailto:')));
    });

    test('without a config, references are left as written', () {
      const bare = StepikMarkdownRenderer();
      expect(
        textOf(bare.render('{{config.support_email}}')),
        contains('{{config.support_email}}'),
      );
    });

    test('a value is HTML-escaped, so it cannot inject markup', () {
      const injected = StepikMarkdownRenderer(
        config: CourseConfig({'x': '<script>alert(1)</script>'}),
      );
      final html = injected.render('{{config.x}}');
      expect(html, isNot(contains('<script>')));
      expect(textOf(html), contains('&lt;script&gt;'));
    });
  });

  group('code is substituted too', () {
    test('expands inside an inline code span', () {
      final html = renderer.render('use `{{config.team}}` here');
      expect(html, contains('<code>Pluto Team</code>'));
      expect(html, isNot(contains('{{')));
    });

    test('expands inside a fenced block', () {
      final html = renderer.render('```\nprint("{{config.team}}");\n```');
      expect(html, contains('Pluto Team'));
      expect(html, isNot(contains('{{')));
    });

    test('tolerates surrounding whitespace in code', () {
      expect(renderer.render('`{{ config.team }}`'), contains('Pluto Team'));
    });

    /// The value lands in text the parser has already escaped, so it has to be
    /// escaped to match — otherwise it would reach the student as live markup.
    test('a value is HTML-escaped inside code', () {
      const injected = StepikMarkdownRenderer(
        config: CourseConfig({'x': '<script>alert(1)</script>'}),
      );
      final html = injected.render('`{{config.x}}`');
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });

    /// Prose badges an unknown key, but an element inside `<code>` would render
    /// as literal tag text, so code leaves it alone and validation reports it.
    test('an unknown key in code is left as written, unbadged', () {
      final html = renderer.render('`{{config.tema}}`');
      expect(html, contains('{{config.tema}}'));
      expect(html, isNot(contains(errorStyle)));
    });

    test('without a config, code is left as written', () {
      const bare = StepikMarkdownRenderer();
      expect(bare.render('`{{config.team}}`'), contains('{{config.team}}'));
    });
  });

  group('validation', () {
    const repo = ValidationRepository();

    Course courseWith(String stepText) => Course(
      id: 1,
      title: 'c',
      config: config,
      sections: [
        Section(
          id: 1,
          position: 1,
          title: 's',
          description: '',
          units: [
            Unit(
              id: 1,
              position: 1,
              lesson: Lesson(
                id: 1,
                title: 'l',
                steps: [TextStep(id: 1, position: 1, text: stepText)],
              ),
            ),
          ],
        ),
      ],
    );

    List<HtmlViolation> unknowns(String stepText) => repo
        .validate(courseWith(stepText))
        .violations
        .where((v) => v.kind == ViolationKind.unknownConfigVar)
        .toList();

    test('a declared key produces no violation', () {
      expect(unknowns('Write to {{config.support_email}}.'), isEmpty);
    });

    test('an undeclared key is reported', () {
      final result = unknowns('Write to {{config.support_emial}}.');
      expect(result, hasLength(1));
      expect(result.single.detail, contains('support_emial'));
    });

    test('a key repeated in a step is reported once', () {
      expect(
        unknowns('{{config.nope}} and {{config.nope}} and {{config.nope}}'),
        hasLength(1),
      );
    });

    /// The renderer cannot badge an unknown key inside code, so this report is
    /// the only signal an author gets for one.
    test('a reference inside code is reported', () {
      expect(unknowns('`{{config.nope}}`'), hasLength(1));
      expect(unknowns('```\n{{config.nope}}\n```'), hasLength(1));
    });

    test('a declared key inside code produces no violation', () {
      expect(unknowns('`{{config.support_email}}`'), isEmpty);
    });

    test('the same key in code and prose is reported once', () {
      expect(
        unknowns('```\n{{config.nope}}\n```\n\ntext {{config.nope}}'),
        hasLength(1),
      );
    });
  });
}

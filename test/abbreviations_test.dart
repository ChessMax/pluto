import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/domain/validation_repository.dart';
import 'package:pluto/markdown/stepik_markdown_renderer.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// A one-step course whose step carries [text].
Course _course(String text, Abbreviations abbreviations) => Course(
  id: null,
  title: 'Course',
  abbreviations: abbreviations,
  sections: [
    Section(
      id: null,
      position: 1,
      title: 'Section',
      description: '',
      units: [
        Unit(
          id: null,
          position: 1,
          lesson: Lesson(
            id: null,
            title: 'Lesson',
            steps: [TextStep(id: null, position: 1, text: text)],
          ),
        ),
      ],
    ),
  ],
);

void main() {
  const abbreviations = Abbreviations({
    'PL': 'Programming Language',
    'HTTP': 'HyperText Transfer Protocol',
    'HTTPS': 'HyperText Transfer Protocol Secure',
  });
  const renderer = StepikMarkdownRenderer(abbreviations: abbreviations);

  group('marking', () {
    test('a declared term is wrapped in abbr with its expansion', () {
      final html = renderer.render('PL');
      expect(
        html,
        contains('<abbr title="Programming Language"><em>PL</em></abbr>'),
      );
    });

    test('the term stays italic, like every other Latin word', () {
      final html = renderer.render('use PL here');
      expect(html, contains('<em>use</em>'));
      expect(html, contains('<em>PL</em>'));
      expect(html, contains('<em>here</em>'));
    });

    test('only the first use in a step is marked', () {
      final html = renderer.render('PL and PL and PL');
      expect('<abbr'.allMatches(html), hasLength(1));
      expect(html, contains('<abbr title="Programming Language"'));
      // The later uses survive as ordinary italicized text.
      expect(html, contains('<em>and PL and PL</em>'));
    });

    test('first use is scoped to one render, not to the renderer', () {
      expect(renderer.render('PL'), contains('<abbr'));
      expect(renderer.render('PL'), contains('<abbr'));
    });

    test('each term is marked independently', () {
      final html = renderer.render('PL over HTTP');
      expect(html, contains('title="Programming Language"'));
      expect(html, contains('title="HyperText Transfer Protocol"'));
    });

    test('the longest matching term wins', () {
      final html = renderer.render('HTTPS');
      expect(html, contains('title="HyperText Transfer Protocol Secure"'));
      expect(html, contains('<em>HTTPS</em>'));
    });

    test('matching is case-sensitive', () {
      final html = renderer.render('pl and Pl');
      expect(html, isNot(contains('<abbr')));
    });

    test('a term glued to other letters is not a match', () {
      final html = renderer.render('PLs and xPL');
      expect(html, isNot(contains('<abbr')));
    });

    test('an undeclared acronym is left alone', () {
      final html = renderer.render('FTP');
      expect(html, isNot(contains('<abbr')));
    });
  });

  group('cyrillic terms', () {
    const cyrillic = Abbreviations({
      'ЯП': 'язык программирования',
      'ПО': 'программное обеспечение',
    });
    const renderer = StepikMarkdownRenderer(abbreviations: cyrillic);

    test('a cyrillic term is marked', () {
      final html = renderer.render('это ЯП тут');
      expect(html, contains('<abbr title="язык программирования">ЯП</abbr>'));
    });

    test('a cyrillic term is not italicized', () {
      // AutoItalicTransformer never wraps Cyrillic, so neither does this one.
      final html = renderer.render('ЯП');
      expect(html, isNot(contains('<em>ЯП</em>')));
    });

    test('a cyrillic term at the very start is marked', () {
      expect(renderer.render('ЯП это'), contains('<abbr'));
    });

    test('a cyrillic term glued to other letters is not a match', () {
      expect(renderer.render('ЯПы и вЯП'), isNot(contains('<abbr')));
    });

    test('surrounding punctuation still bounds the term', () {
      expect(renderer.render('(ЯП), ПО.'), contains('<abbr title="язык'));
      expect(
        renderer.render('(ЯП), ПО.'),
        contains('<abbr title="программное обеспечение">ПО</abbr>'),
      );
    });

    test('only the first use is marked', () {
      final html = renderer.render('ЯП и ЯП');
      expect('<abbr'.allMatches(html), hasLength(1));
    });

    test('a cyrillic term in code is untouched', () {
      expect(renderer.render('`ЯП`'), isNot(contains('<abbr')));
    });
  });

  group('skipped contexts', () {
    test('a fenced code block is untouched', () {
      final html = renderer.render('```\nPL\n```');
      expect(html, isNot(contains('<abbr')));
      expect(html, contains('<pre><code>PL\n</code></pre>'));
    });

    test('inline code is untouched', () {
      final html = renderer.render('`PL`');
      expect(html, isNot(contains('<abbr')));
      expect(html, contains('<code>PL</code>'));
    });

    test('an indented code block is untouched', () {
      final html = renderer.render('    PL');
      expect(html, isNot(contains('<abbr')));
    });

    test('a term in code does not consume the first use of later prose', () {
      final html = renderer.render('`PL` is short for PL');
      expect(html, contains('<code>PL</code>'));
      expect(
        html,
        contains('<abbr title="Programming Language"><em>PL</em></abbr>'),
      );
    });

    test('already-emphasized text is untouched', () {
      final html = renderer.render('**PL**');
      expect(html, isNot(contains('<abbr')));
    });

    test('a term inside an inline HTML tag is not marked', () {
      final html = renderer.render('<span class="PL">x</span>');
      expect(html, isNot(contains('<abbr')));
    });
  });

  group('rendering without abbreviations', () {
    test('a bare renderer marks nothing', () {
      const bare = StepikMarkdownRenderer();
      expect(bare.render('PL'), isNot(contains('<abbr')));
    });

    test('an empty declaration marks nothing', () {
      const empty = StepikMarkdownRenderer(abbreviations: Abbreviations.empty);
      expect(empty.render('PL'), isNot(contains('<abbr')));
    });
  });

  group('escaping', () {
    test('an expansion is escaped for the title attribute', () {
      const quoted = StepikMarkdownRenderer(
        abbreviations: Abbreviations({'AT': 'a "quoted" & <angled> name'}),
      );
      final html = quoted.render('AT');
      expect(
        html,
        contains('title="a &quot;quoted&quot; &amp; &lt;angled&gt; name"'),
      );
    });
  });

  group('fromYaml', () {
    Abbreviations parse(String yaml) => Abbreviations.fromYaml(loadYaml(yaml));

    test('reads term/expansion pairs', () {
      final parsed = parse('PL: Programming Language\nHTTP: Protocol');
      expect(parsed.resolve('PL'), 'Programming Language');
      expect(parsed.resolve('HTTP'), 'Protocol');
    });

    test('null front matter yields empty', () {
      expect(Abbreviations.fromYaml(null).isEmpty, isTrue);
    });

    test('stringifies scalar expansions', () {
      expect(parse('A1: 2026').resolve('A1'), '2026');
    });

    test('drops a term with no expansion', () {
      expect(parse('PL:').isEmpty, isTrue);
    });

    test('keeps terms joined by internal punctuation', () {
      final parsed = parse('HTTP/2: the second version\nwell-known: known');
      expect(parsed.resolve('HTTP/2'), 'the second version');
      expect(parsed.resolve('well-known'), 'known');
    });

    test('rejects a term that could never match on a word boundary', () {
      expect(() => parse('"C++": a language'), throwsA(isA<String>()));
      expect(() => parse('"a b": two words'), throwsA(isA<String>()));
    });

    test('accepts terms in any script', () {
      final parsed = parse('ЯП: язык программирования\nП-О: с дефисом');
      expect(parsed.resolve('ЯП'), 'язык программирования');
      expect(parsed.resolve('П-О'), 'с дефисом');
    });

    test('rejects a non-scalar expansion', () {
      expect(() => parse('PL:\n  - a\n  - b'), throwsA(isA<String>()));
    });

    test('rejects front matter that is not a map', () {
      expect(() => Abbreviations.fromYaml('PL'), throwsA(isA<String>()));
    });
  });

  group('pattern', () {
    test('is compiled once per declaring map', () {
      expect(abbreviations.pattern, same(abbreviations.pattern));
    });

    test('is null when nothing is declared', () {
      expect(Abbreviations.empty.pattern, isNull);
    });
  });

  group('unused abbreviations', () {
    const validation = ValidationRepository();

    List<HtmlViolation> unusedIn(String text) =>
        validation.validateAbbreviations(_course(text, abbreviations));

    test('a term no step mentions is reported', () {
      final unused = unusedIn('nothing here');
      expect(unused.map((v) => v.detail), {'PL', 'HTTP', 'HTTPS'});
      expect(unused.first.kind, ViolationKind.unusedAbbreviation);
      expect(unused.first.location, 'abbreviations.md');
    });

    test('a used term is not reported', () {
      expect(unusedIn('PL and HTTP and HTTPS'), isEmpty);
    });

    test('a term used only in a fenced code block counts as unused', () {
      final unused = unusedIn('```\nPL\n```\n\nHTTP HTTPS');
      expect(unused.map((v) => v.detail), {'PL'});
    });

    test('a term used only in inline code counts as unused', () {
      final unused = unusedIn('`PL` HTTP HTTPS');
      expect(unused.map((v) => v.detail), {'PL'});
    });

    test('a term glued to other letters does not count as a use', () {
      final unused = unusedIn('PLs HTTP HTTPS');
      expect(unused.map((v) => v.detail), {'PL'});
    });

    test('HTTPS does not count as a use of HTTP', () {
      final unused = unusedIn('HTTPS and PL');
      expect(unused.map((v) => v.detail), {'HTTP'});
    });

    test('a course declaring nothing reports nothing', () {
      final course = _course('nothing', Abbreviations.empty);
      expect(validation.validateAbbreviations(course), isEmpty);
    });

    test('unused abbreviations warn without failing validation', () {
      final result = validation.validate(_course('nothing', abbreviations));

      expect(result.isValid, isTrue);
      expect(result.violations, isEmpty);
      expect(
        result.warnings.where(
          (w) => w.kind == ViolationKind.unusedAbbreviation,
        ),
        hasLength(3),
      );
    });
  });
}

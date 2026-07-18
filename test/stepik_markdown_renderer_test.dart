import 'package:markdown/markdown.dart';
import 'package:pluto/markdown/stepik_markdown_renderer.dart';
import 'package:pluto/domain/validation_repository.dart';
import 'package:test/test.dart';

void main() {
  const renderer = StepikMarkdownRenderer();

  group('strikethrough rewrite', () {
    test('~~Text~~ renders as <strike>, never <del>', () {
      final html = renderer.render('~~Text~~');
      expect(html, contains('<strike><em>Text</em></strike>'));
      expect(html, isNot(contains('<del>')));
      expect(html, isNot(contains('</del>')));
    });

    test('inline strikethrough among surrounding text', () {
      final html = renderer.render('a ~~b~~ c');
      expect(html, contains('<em>a</em> <strike><em>b</em></strike> <em>c</em>'));
    });

    test('nested emphasis inside strikethrough is preserved', () {
      final html = renderer.render('~~**x**~~');
      expect(html, contains('<strike><strong>x</strong></strike>'));
    });
  });

  group('untouched output', () {
    test('self-closing image stays well-formed', () {
      final html = renderer.render('![alt](img.png)');
      expect(html, contains('<img src="img.png" alt="alt" />'));
      expect(html, isNot(contains('<del>')));
    });

    test('content without strikethrough gets no strike/del tags', () {
      const source = '# Title\n\nplain **bold** and `code`\n\n- a\n- b';
      final html = renderer.render(source);
      expect(html, isNot(contains('<strike')));
      expect(html, isNot(contains('<del')));
    });
  });

  group('auto italic', () {
    test('standalone number is wrapped', () {
      expect(renderer.render('2 + 2'), contains('<em>2</em> + <em>2</em>'));
    });

    test('english phrase groups across spaces', () {
      expect(renderer.render('hello world'), contains('<em>hello world</em>'));
    });

    test('punctuation breaks the phrase into separate ems', () {
      expect(renderer.render('foo, bar'), contains('<em>foo</em>, <em>bar</em>'));
    });

    test('versions and decimals stay as one unit', () {
      expect(renderer.render('3.14'), contains('<em>3.14</em>'));
      expect(renderer.render('v2.0'), contains('<em>v2.0</em>'));
      expect(renderer.render('HTTP/2'), contains('<em>HTTP/2</em>'));
    });

    test('cyrillic is not wrapped, latin/number in the middle is', () {
      final html = renderer.render('Привет hello 42 мир');
      expect(html, contains('<em>hello 42</em>'));
      expect(html, contains('Привет'));
      expect(html, contains('мир'));
      expect(html, isNot(contains('<em>Привет')));
    });

    test('inline code is not wrapped', () {
      final html = renderer.render('`code 123`');
      expect(html, contains('<code>code 123</code>'));
      expect(html, isNot(contains('<em>')));
    });

    test('fenced code block is not wrapped', () {
      final html = renderer.render('```\nlet x = 42\n```');
      expect(html, contains('let x = 42'));
      expect(html, isNot(contains('<em>')));
    });

    test('html entities are not corrupted (quot/amp not wrapped)', () {
      expect(renderer.render('"Сюбор"'), contains('&quot;Сюбор&quot;'));
      expect(renderer.render('a & b'), contains('<em>a</em> &amp; <em>b</em>'));
      expect(renderer.render('"foo bar"'), contains('&quot;<em>foo bar</em>&quot;'));
    });

    test('raw inline html tag names are not wrapped', () {
      final html = renderer.render('<em>Нью-Йорке</em>');
      expect(html, contains('<em>Нью-Йорке</em>'));
      expect(html, isNot(contains('<em>em</em>')));
    });
  });

  group('validator cross-check', () {
    const validator = ValidationRepository();

    test('rendered strikethrough passes the whitelist validator', () {
      final html = renderer.render('a ~~struck~~ b');
      final violations = validator.validateHtml(html, location: 'test');
      expect(violations, isEmpty);
    });

    test('plain markdown <del> output would fail — proves the check bites', () {
      final rawDel = markdownToHtml(
        'a ~~struck~~ b',
        extensionSet: ExtensionSet.gitHubWeb,
      );
      final violations = validator.validateHtml(rawDel, location: 'test');
      expect(
        violations.map((v) => v.kind),
        contains(ViolationKind.disallowedTag),
      );
    });
  });
}

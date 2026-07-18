import 'package:markdown/markdown.dart';
import 'package:pluto/domain/stepik_markdown_renderer.dart';
import 'package:pluto/domain/validation_repository.dart';
import 'package:test/test.dart';

void main() {
  const renderer = StepikMarkdownRenderer();

  group('strikethrough rewrite', () {
    test('~~Text~~ renders as <strike>, never <del>', () {
      final html = renderer.render('~~Text~~');
      expect(html, contains('<strike>Text</strike>'));
      expect(html, isNot(contains('<del>')));
      expect(html, isNot(contains('</del>')));
    });

    test('inline strikethrough among surrounding text', () {
      final html = renderer.render('a ~~b~~ c');
      expect(html, contains('a <strike>b</strike> c'));
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

    test('content without strikethrough matches plain markdownToHtml', () {
      const source = '# Title\n\nplain **bold** and `code`\n\n- a\n- b';
      expect(
        renderer.render(source),
        equals(markdownToHtml(source, extensionSet: ExtensionSet.gitHubWeb)),
      );
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

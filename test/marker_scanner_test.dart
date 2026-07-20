import 'package:pluto/domain/marker_scanner.dart';
import 'package:pluto/domain/validation_repository.dart';
import 'package:pluto/markdown/stepik_markdown_renderer.dart';
import 'package:test/test.dart';

void main() {
  const scanner = MarkerScanner();

  group('scanText', () {
    test('locates a TODO with 1-based line and column', () {
      const text = 'line one\nbefore [[TODO: do it]] after\n';
      final findings = scanner.scanText(text, 'a.md');

      expect(findings, hasLength(1));
      final finding = findings.single;
      expect(finding.kind.keyword, 'TODO');
      expect(finding.severity, MarkerSeverity.warning);
      expect(finding.message, 'do it');
      expect(finding.location.path, 'a.md');
      expect(finding.location.line, 2);
      expect(finding.location.column, 8); // after "before " (7 chars)
      expect(finding.toString(), 'a.md:2:8: TODO: do it');
    });

    test('marker at the very start is 1:1', () {
      final finding = scanner.scanText('[[TODO: x]]', 'a.md').single;
      expect(finding.location.line, 1);
      expect(finding.location.column, 1);
    });

    test('multiple markers across lines keep independent locations', () {
      const text = '[[TODO: one]]\n\n  [[TODO: two]]';
      final findings = scanner.scanText(text, 'a.md');

      expect(findings.map((f) => f.message), ['one', 'two']);
      expect(findings[0].location.line, 1);
      expect(findings[0].location.column, 1);
      expect(findings[1].location.line, 3);
      expect(findings[1].location.column, 3);
    });

    test('CRLF line endings do not corrupt columns', () {
      const text = 'a\r\n[[TODO: x]]';
      final finding = scanner.scanText(text, 'a.md').single;
      expect(finding.location.line, 2);
      expect(finding.location.column, 1);
    });

    test('marker without a colon is not matched', () {
      expect(scanner.scanText('[[TODO no colon]]', 'a.md'), isEmpty);
    });

    test('FIXME is an error and NOTE is info', () {
      final findings = scanner.scanText(
        '[[FIXME: broken]]\n[[NOTE: aside]]',
        'a.md',
      );

      expect(findings.map((f) => f.kind.keyword), ['FIXME', 'NOTE']);
      expect(findings[0].severity, MarkerSeverity.error);
      expect(findings[1].severity, MarkerSeverity.info);
    });

    test('mixed severities are all reported with their locations', () {
      const text = '[[NOTE: n]] [[TODO: t]] [[FIXME: f]]';
      final findings = scanner.scanText(text, 'a.md');

      expect(findings, hasLength(3));
      expect(findings.map((f) => f.severity), [
        MarkerSeverity.info,
        MarkerSeverity.warning,
        MarkerSeverity.error,
      ]);
    });
  });

  group('push gating', () {
    test('FIXME blocks a push, TODO and NOTE do not', () {
      const scanner = MarkerScanner();

      ValidationResult resultFor(String text) =>
          ValidationResult(const [], markers: scanner.scanText(text, 'a.md'));

      expect(resultFor('[[NOTE: n]]').hasBlockingMarkers, isFalse);
      expect(resultFor('[[TODO: t]]').hasBlockingMarkers, isFalse);
      expect(resultFor('[[FIXME: f]]').hasBlockingMarkers, isTrue);
      expect(resultFor('[[TODO: t]] [[FIXME: f]]').hasBlockingMarkers, isTrue);
    });
  });

  group('rendering', () {
    String render(String markdown) =>
        const StepikMarkdownRenderer().render(markdown);

    test('NOTE is stripped from the published HTML', () {
      final html = render('before [[NOTE: author aside]] after');

      expect(html, isNot(contains('NOTE')));
      expect(html, isNot(contains('author aside')));
      expect(html, contains('before'));
      expect(html, contains('after'));
    });

    test('TODO still renders a visible badge', () {
      final html = render('[[TODO: add a screenshot]]');

      expect(html, contains('TODO: add a screenshot'));
      expect(html, contains('<span'));
    });

    test('FIXME renders a badge distinct from TODO', () {
      final fixme = render('[[FIXME: broken link]]');

      expect(fixme, contains('FIXME: broken link'));
      expect(fixme, isNot(contains('#fff3cd'))); // not the TODO colour
    });

    test('marker message is HTML-escaped', () {
      final html = render('[[TODO: <script>x</script>]]');

      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });
  });
}

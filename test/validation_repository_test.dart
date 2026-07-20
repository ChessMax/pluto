import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/marker_scanner.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/source_file.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/domain/validation_repository.dart';
import 'package:test/test.dart';

void main() {
  const repo = ValidationRepository();

  List<HtmlViolation> check(String? html) =>
      repo.validateHtml(html, location: 'test');

  group('validateHtml — valid input', () {
    test('allowed tags and attributes pass', () {
      expect(
        check('<p>Hello <a href="https://x.com" title="t">link</a></p>'),
        isEmpty,
      );
      expect(
        check('<img src="a.png" alt="a" width="10" height="10">'),
        isEmpty,
      );
      expect(
        check('<details><summary>More</summary><p>text</p></details>'),
        isEmpty,
      );
      expect(
        check(
          '<table border="1" style="width:500px"><thead><tr><th>A</th></tr>'
          '</thead><tbody><tr><td style="text-align:center">1</td></tr>'
          '</tbody></table>',
        ),
        isEmpty,
      );
    });

    test('allowed URL schemes pass', () {
      expect(check('<a href="http://x.com">x</a>'), isEmpty);
      expect(check('<a href="https://x.com">x</a>'), isEmpty);
      expect(check('<a href="mailto:a@b.com">x</a>'), isEmpty);
    });

    test('relative/anchor URLs (no scheme) pass', () {
      expect(check('<a href="/page">x</a>'), isEmpty);
      expect(check('<a href="#section">x</a>'), isEmpty);
    });

    test('null and empty html produce no violations', () {
      expect(check(null), isEmpty);
      expect(check(''), isEmpty);
    });

    test('plain text produces no violations', () {
      expect(check('just some text, no tags'), isEmpty);
    });
  });

  group('validateHtml — violations', () {
    test('disallowed tag is reported', () {
      final v = check('<div>nope</div>');
      expect(v, hasLength(1));
      expect(v.single.kind, ViolationKind.disallowedTag);
      expect(v.single.detail, '<div>');
    });

    test('only h1-h3 allowed, h4 is reported', () {
      expect(check('<h1>ok</h1><h2>ok</h2><h3>ok</h3>'), isEmpty);
      final v = check('<h4>nope</h4>');
      expect(v.single.kind, ViolationKind.disallowedTag);
      expect(v.single.detail, '<h4>');
    });

    test('disallowed attribute is reported', () {
      final v = check('<p onclick="hack()">x</p>');
      expect(v.single.kind, ViolationKind.disallowedAttribute);
      expect(v.single.detail, '<p onclick>');
    });

    test('attribute allowed on one tag is not allowed on another', () {
      final v = check('<p href="https://x.com">x</p>');
      expect(v.single.kind, ViolationKind.disallowedAttribute);
      expect(v.single.detail, '<p href>');
    });

    test('disallowed URL scheme is reported', () {
      final v = check('<a href="javascript:alert(1)">x</a>');
      expect(v.single.kind, ViolationKind.disallowedUrlScheme);
      expect(v.single.detail, contains('javascript'));
    });

    test('nested disallowed tag inside an allowed tag is caught', () {
      final v = check('<p><strong>hi <marquee>bad</marquee></strong></p>');
      expect(v.single.kind, ViolationKind.disallowedTag);
      expect(v.single.detail, '<marquee>');
    });

    test('multiple violations are all collected', () {
      final v = check('<div>a</div><span onclick="x">b</span>');
      expect(v, hasLength(2));
      expect(v.map((e) => e.kind), [
        ViolationKind.disallowedTag,
        ViolationKind.disallowedAttribute,
      ]);
    });

    test('toString includes location and detail', () {
      final v = repo.validateHtml('<div>x</div>', location: 'step 2');
      expect(v.single.toString(), 'step 2: disallowed tag <div>');
    });
  });

  group('validate(Course)', () {
    test('valid course has empty violations and isValid == true', () {
      final course = _course(
        summaryRendered: '<p>ok</p>',
        stepHtml: '<p>ok</p>',
      );
      final result = repo.validate(course);
      expect(result.isValid, isTrue);
      expect(result.violations, isEmpty);
    });

    test('aggregates violations from summary and steps with locations', () {
      final course = _course(
        summaryRendered: '<div>bad summary</div>',
        stepHtml: '<script>bad step</script>',
      );
      final result = repo.validate(course);

      expect(result.isValid, isFalse);
      expect(result.violations, hasLength(2));

      final locations = result.violations.map((v) => v.location).toList();
      expect(locations, contains('course summary'));
      expect(
        locations.any(
          (l) => l.contains('section "Sec"') && l.contains('step 1'),
        ),
        isTrue,
      );
    });
  });

  group('validate(Course) — markers', () {
    final course = _course(summaryRendered: '<p>ok</p>', stepHtml: '<p>ok</p>');

    test('no sources means no markers', () {
      expect(repo.validate(course).markers, isEmpty);
    });

    test('scans provided sources with exact file:line:column', () {
      const source = SourceFile(
        path: 'source/section_01/unit_01/step_01.md',
        content: 'intro\ntext [[TODO: fix wording]] more\n',
      );
      final result = repo.validate(course, sources: [source]);

      expect(result.isValid, isTrue); // markers never affect HTML validity
      expect(result.markers, hasLength(1));
      final marker = result.markers.single;
      expect(marker.kind.keyword, 'TODO');
      expect(marker.severity, MarkerSeverity.warning);
      expect(marker.message, 'fix wording');
      expect(
        marker.location.toString(),
        'source/section_01/unit_01/step_01.md:2:6',
      );
    });

    test('TODO markers are warnings and do not block a push', () {
      const source = SourceFile(path: 'a.md', content: '[[TODO: later]]');
      final result = repo.validate(course, sources: [source]);
      expect(result.markers, hasLength(1));
      expect(result.hasBlockingMarkers, isFalse);
    });
  });

  group('validateIds', () {
    test('distinct ids pass', () {
      expect(repo.validateIds(_courseWithStepIds([1, 2, 3])), isEmpty);
    });

    test('null ids are ignored, however many', () {
      expect(repo.validateIds(_courseWithStepIds([null, null, null])), isEmpty);
    });

    test('a repeated step id is reported against the later file', () {
      final v = repo.validateIds(_courseWithStepIds([10, 20, 10]));

      expect(v, hasLength(1));
      expect(v.single.kind, ViolationKind.duplicateId);
      expect(v.single.location, 'section_01/unit_01/step_03.md');
      expect(
        v.single.detail,
        'step id 10, already used by '
        'section_01/unit_01/step_01.md',
      );
    });

    test('every repeat past the first is reported', () {
      final v = repo.validateIds(_courseWithStepIds([7, 7, 7]));

      expect(v, hasLength(2));
      expect(
        v.map((violation) => violation.location),
        ['section_01/unit_01/step_02.md', 'section_01/unit_01/step_03.md'],
      );
    });

    test('ids of different kinds may coincide', () {
      final step = TextStep(id: 5, position: 1, text: '');
      final course = Course(
        id: 5,
        title: 'Course',
        sections: [
          Section(
            id: 5,
            position: 1,
            title: 'Sec',
            description: '',
            units: [
              Unit(
                id: 5,
                position: 1,
                lesson: Lesson(id: 5, title: 'Lesson', steps: [step]),
              ),
            ],
          ),
        ],
      );

      expect(repo.validateIds(course), isEmpty);
    });

    test('duplicate ids surface through validate() as violations', () {
      final result = repo.validate(_courseWithStepIds([1, 1]));

      expect(result.isValid, isFalse);
      expect(
        result.violations.map((violation) => violation.kind),
        contains(ViolationKind.duplicateId),
      );
    });
  });
}

/// A one-section, one-unit course whose steps carry [ids], positioned in order
/// so each maps to `step_NN.md`.
Course _courseWithStepIds(List<int?> ids) {
  final steps = [
    for (var i = 0; i < ids.length; ++i)
      TextStep(id: ids[i], position: i + 1, text: ''),
  ];

  return Course(
    id: 1,
    title: 'Course',
    sections: [
      Section(
        id: null,
        position: 1,
        title: 'Sec',
        description: '',
        units: [
          Unit(
            id: null,
            position: 1,
            lesson: Lesson(id: null, title: 'Lesson', steps: steps),
          ),
        ],
      ),
    ],
  );
}

Course _course({
  String? summary,
  String? summaryRendered,
  String stepText = '',
  String? stepHtml,
}) {
  final step = TextStep(
    id: null,
    position: 1,
    text: stepText,
    renderedText: stepHtml,
  );

  final unit = Unit(
    id: null,
    position: 1,
    lesson: Lesson(id: null, title: 'Lesson', steps: [step]),
  );

  final section = Section(
    id: null,
    position: 1,
    title: 'Sec',
    description: '',
    units: [unit],
  );

  return Course(
    id: 1,
    title: 'Course',
    summary: summary,
    summaryRendered: summaryRendered,
    sections: [section],
  );
}

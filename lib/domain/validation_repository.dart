import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/html_whitelist.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/domain/marker_scanner.dart';
import 'package:pluto/domain/source_file.dart';

enum ViolationKind {
  disallowedTag,
  disallowedAttribute,
  disallowedUrlScheme,
  unresolvedLink,
  duplicateLabel,
}

class HtmlViolation {
  final ViolationKind kind;
  final String detail;
  final String location;

  const HtmlViolation({
    required this.kind,
    required this.detail,
    required this.location,
  });

  @override
  String toString() {
    final message = switch (kind) {
      ViolationKind.disallowedTag => 'disallowed tag $detail',
      ViolationKind.disallowedAttribute => 'disallowed attribute $detail',
      ViolationKind.disallowedUrlScheme => 'disallowed URL scheme $detail',
      ViolationKind.unresolvedLink => 'link to unknown step $detail',
      ViolationKind.duplicateLabel => 'label $detail is used by several steps',
    };
    return '$location: $message';
  }
}

class ValidationResult {
  final List<HtmlViolation> violations;

  /// Reminder markers (TODO/FIXME) found in the source, with exact locations.
  final List<MarkerFinding> markers;

  const ValidationResult(this.violations, {this.markers = const []});

  bool get isValid => violations.isEmpty;

  /// Whether any error-severity marker (e.g. FIXME) should abort a push.
  bool get hasBlockingMarkers =>
      markers.any((m) => m.severity == .error);
}

class ValidationRepository {
  const ValidationRepository();

  // https://help.stepik.org/article/54794
  List<HtmlViolation> validateHtml(String? html, {required String location}) {
    final violations = <HtmlViolation>[];
    if (html == null || html.isEmpty) return violations;

    final fragment = parseFragment(html);

    void traverse(Node node) {
      for (final child in node.nodes) {
        if (child is Element) {
          final tag = child.localName?.toLowerCase();
          final rule = tag == null ? null : allowedTags[tag];

          if (rule == null) {
            violations.add(
              HtmlViolation(
                kind: ViolationKind.disallowedTag,
                detail: '<$tag>',
                location: location,
              ),
            );
          } else {
            _validateAttributes(child, tag!, rule, location, violations);
          }
        }

        traverse(child);
      }
    }

    traverse(fragment);
    return violations;
  }

  void _validateAttributes(
    Element element,
    String tag,
    TagRule rule,
    String location,
    List<HtmlViolation> violations,
  ) {
    element.attributes.forEach((key, value) {
      final name = (key is AttributeName ? key.name : key.toString())
          .toLowerCase();

      final isAllowed =
          globalAttributes.contains(name) ||
          rule.attributes.contains(name) ||
          rule.urlAttributes.contains(name);

      if (!isAllowed) {
        violations.add(
          HtmlViolation(
            kind: ViolationKind.disallowedAttribute,
            detail: '<$tag $name>',
            location: location,
          ),
        );
        return;
      }

      if (rule.urlAttributes.contains(name)) {
        final scheme = Uri.tryParse(value)?.scheme;
        if (scheme == null || scheme.isEmpty) return;

        // A surviving `ref:` means resolution failed — either the ref names no
        // step, or the target had not been created on Stepik yet. Reported as
        // itself rather than as a stray URL scheme, since the cause is a broken
        // link and not a disallowed protocol.
        if (scheme.toLowerCase() == refScheme) {
          violations.add(
            HtmlViolation(
              kind: ViolationKind.unresolvedLink,
              detail: value.substring(refScheme.length + 1),
              location: location,
            ),
          );
          return;
        }

        if (!allowedUrlSchemes.contains(scheme.toLowerCase())) {
          violations.add(
            HtmlViolation(
              kind: ViolationKind.disallowedUrlScheme,
              detail: '$scheme (in <$tag $name>)',
              location: location,
            ),
          );
        }
      }
    });
  }

  /// Validates the course. HTML violations come from the rendered [course];
  /// reminder markers (TODO/FIXME) are scanned from the raw [sources] the course
  /// was read from, so each marker gets a precise file:line:column location.
  ValidationResult validate(
    Course course, {
    List<SourceFile> sources = const [],
    LinkIndex? links,
  }) {
    final violations = <HtmlViolation>[];

    violations.addAll(
      validateHtml(course.summaryRendered, location: 'course summary'),
    );

    for (final label in links?.duplicateLabels ?? const <String>[]) {
      violations.add(
        HtmlViolation(
          kind: ViolationKind.duplicateLabel,
          detail: '"$label"',
          location: 'course',
        ),
      );
    }

    final sections = course.sections;
    for (var i = 0; i < sections.length; ++i) {
      final section = sections[i];
      final units = section.units;

      for (var j = 0; j < units.length; ++j) {
        final unit = units[j];
        final steps = unit.lesson.steps;

        for (var k = 0; k < steps.length; ++k) {
          final step = steps[k];
          final location =
              'section "${section.title}" > unit ${j + 1} > step ${step.position}';

          violations.addAll(
            validateHtml(step.block.textRendered, location: location),
          );

          // TODO: choice option text/feedback and step feedbackCorrect/Wrong
          // are not rendered to HTML yet — validate them once they are.
        }
      }
    }

    const scanner = MarkerScanner();
    final markers = <MarkerFinding>[
      for (final source in sources)
        ...scanner.scanText(source.content, source.path),
    ];

    return ValidationResult(violations, markers: markers);
  }
}

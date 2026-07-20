import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/course_config.dart';
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

  /// A ref whose target step exists in the source but has never been pushed, so
  /// it currently resolves only to a synthetic id. Warning-only — see
  /// [ValidationResult.warnings].
  unpushedLink,

  /// A `{{config.<key>}}` reference naming a key `course.md` does not declare.
  unknownConfigVar,
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
      ViolationKind.unpushedLink =>
        'link to $detail, a step that has not been pushed yet',
      // Backticks live here rather than in `detail` so the reference stays bare
      // for callers that mark it up themselves (the preview wraps it in <code>).
      ViolationKind.unknownConfigVar =>
        'reference to undeclared config variable `$detail`',
    };
    return '$location: $message';
  }
}

class ValidationResult {
  final List<HtmlViolation> violations;

  /// Problems worth reporting that must not block a push — see
  /// [ViolationKind.unpushedLink], the only one so far.
  final List<HtmlViolation> warnings;

  /// Reminder markers (TODO/FIXME) found in the source, with exact locations.
  final List<MarkerFinding> markers;

  const ValidationResult(
    this.violations, {
    this.warnings = const [],
    this.markers = const [],
  });

  /// Warnings are deliberately excluded: they describe work still to do, not
  /// content Stepik would reject.
  bool get isValid => violations.isEmpty;

  /// Whether any error-severity marker (e.g. FIXME) should abort a push.
  bool get hasBlockingMarkers => markers.any((m) => m.severity == .error);
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
    final warnings = <HtmlViolation>[];

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
            validateHtml(step.renderedText, location: location),
          );
          warnings.addAll(
            _unpushedLinks(step.text, location: location, links: links),
          );
          violations.addAll(
            validateConfigVars(
              step.text,
              location: location,
              config: course.config,
            ),
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

    return ValidationResult(violations, warnings: warnings, markers: markers);
  }

  /// Refs pointing at a step that exists in the source but carries no Stepik id
  /// yet, so it resolved only to a synthetic stand-in.
  ///
  /// Read from the raw Markdown rather than the rendered HTML: rendering has
  /// already turned such a ref into an ordinary-looking URL, and nothing in the
  /// output distinguishes a synthetic id from a real one.
  ///
  /// Only reachable when the index was built with `allowSynthetic` — push
  /// refuses those, so there the same ref surfaces as an
  /// [ViolationKind.unresolvedLink] error instead.
  List<HtmlViolation> _unpushedLinks(
    String markdown, {
    required String location,
    required LinkIndex? links,
  }) {
    if (links == null) return const [];

    return [
      for (final match in _refLinkRegExp.allMatches(markdown))
        if (links.resolve(match.group(1)!) case final target?)
          if (!target.isRemote)
            HtmlViolation(
              kind: ViolationKind.unpushedLink,
              detail: match.group(1)!,
              location: location,
            ),
    ];
  }

  /// The destination of an inline Markdown link using the [refScheme].
  static final RegExp _refLinkRegExp = RegExp(r'\]\(\s*ref:([^)\s]+)');

  /// `{{config.<key>}}` references the course does not declare.
  ///
  /// Read from the raw Markdown rather than the rendered HTML: recovering the
  /// references from the badges rendering wraps them in would mean parsing HTML
  /// to learn what the source already says plainly. Code is blanked out first,
  /// matching the renderer, which never expands references there — a course
  /// about programming is full of `{{ }}` in Vue, Jinja and Handlebars samples
  /// that must not be reported.
  ///
  /// One violation per distinct key, not per occurrence: a key repeated through
  /// a step is a single typo to fix, and listing it a dozen times buries the
  /// other diagnostics beside it.
  List<HtmlViolation> validateConfigVars(
    String markdown, {
    required String location,
    required CourseConfig config,
  }) {
    final keys = unknownConfigKeys(_blankCode(markdown), config).toSet();
    return [
      for (final key in keys)
        HtmlViolation(
          kind: ViolationKind.unknownConfigVar,
          detail: '{{$configNamespace.$key}}',
          location: location,
        ),
    ];
  }

  /// Replaces fenced blocks and inline code spans with spaces, preserving every
  /// other character's offset.
  static String _blankCode(String markdown) {
    return markdown.replaceAllMapped(
      _codeRegExp,
      (match) => ' ' * match.group(0)!.length,
    );
  }

  /// A fenced code block, or an inline code span of any backtick run length.
  static final RegExp _codeRegExp = RegExp(
    r'^```[\s\S]*?^```|(`+)[\s\S]*?\1',
    multiLine: true,
  );
}

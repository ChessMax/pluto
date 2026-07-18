import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/html_whitelist.dart';
import 'package:pluto/markdown/todo_syntax.dart';

enum ViolationKind {
  disallowedTag,
  disallowedAttribute,
  disallowedUrlScheme,
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
    };
    return '$location: $message';
  }
}

/// A `[[TODO: ...]]` marker found in the course source. Reported as a
/// *warning* (unlike [HtmlViolation], it never makes a course invalid).
class TodoOccurrence {
  final String message;
  final String location;

  const TodoOccurrence({required this.message, required this.location});

  @override
  String toString() => '$location: TODO: $message';
}

class ValidationResult {
  final List<HtmlViolation> violations;
  final List<TodoOccurrence> todos;

  const ValidationResult({this.violations = const [], this.todos = const []});

  bool get isValid => violations.isEmpty;
}

class ValidationRepository {
  static final _todo = RegExp(todoPattern);

  const ValidationRepository();

  /// Scans *raw Markdown source* (not rendered HTML) for `[[TODO: ...]]`, so
  /// messages stay clean and locations are precise.
  List<TodoOccurrence> scanTodos(String? source, {required String location}) {
    if (source == null || source.isEmpty) return const [];
    return [
      for (final match in _todo.allMatches(source))
        TodoOccurrence(message: match[1]!.trim(), location: location),
    ];
  }

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
        if (scheme != null &&
            scheme.isNotEmpty &&
            !allowedUrlSchemes.contains(scheme.toLowerCase())) {
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

  /// Validates course. Can generate error that abort or warnings.
  ValidationResult validate(Course course) {
    final violations = <HtmlViolation>[];
    final todos = <TodoOccurrence>[];

    violations.addAll(
      validateHtml(course.summaryRendered, location: 'course summary'),
    );
    todos.addAll(scanTodos(course.summary, location: 'course summary'));

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
          todos.addAll(scanTodos(step.block.text, location: location));

          // TODO: choice option text/feedback and step feedbackCorrect/Wrong
          // are not rendered to HTML yet — validate them once they are.
        }
      }
    }

    return ValidationResult(violations: violations, todos: todos);
  }
}

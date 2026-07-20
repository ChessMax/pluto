import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/markdown/stepik_markdown_renderer.dart';

// TODO: is it OK that's it a repository?
class RenderRepository {
  static final _nlRegEx = RegExp(r'\n+');

  const RenderRepository();

  String renderMultiLineText(String text) {
    String replaceLineBreaks(String input) {
      return input.replaceAllMapped(_nlRegEx, (match) {
        final newlines = match.group(0)!;
        if (newlines.length == 1) {
          return '';
        } else {
          return '\n' * (newlines.length ~/ 2);
        }
      });
    }

    return replaceLineBreaks(text);
  }

  String renderMdText(String text, {LinkIndex? links}) {
    return StepikMarkdownRenderer(links: links).render(text);
  }

  /// Renders every step's Markdown to HTML.
  ///
  /// [links] resolves `ref:` links to other steps; it is built from the course
  /// *before* rendering, since a link's target only needs ids and positions.
  Course render(Course course, {LinkIndex? links}) {
    final sections = course.sections.toList();

    for (int i = 0; i < sections.length; ++i) {
      final section = sections[i];
      final units = section.units;

      for (int j = 0; j < units.length; ++j) {
        final unit = units[j];
        final steps = unit.lesson.steps.toList();

        for (int k = 0; k < steps.length; ++k) {
          final step = steps[k];

          steps[k] = step.copyWith(
            renderedText: renderMdText(step.text, links: links),
          );
        }

        final renderedUnit = unit.copyWith(
          lesson: unit.lesson.copyWith(steps: steps),
        );
        units[j] = renderedUnit;
      }

      final renderedSection = section.copyWith(units: units);
      sections[i] = renderedSection;
    }

    final summary = course.summary;
    final renderedCourse = course.copyWith(
      summaryRendered: summary != null && summary.isNotEmpty
          ? renderMultiLineText(summary)
          : summary,
      sections: sections,
    );
    return renderedCourse;
  }
}

import 'package:markdown/markdown.dart';
import 'package:pluto/domain/course.dart';

// TODO: is it OK that's it a repository?
class RenderRepository {
  const RenderRepository();

  String renderText(String text) {
    final result =
    markdownToHtml(
      text,
      extensionSet: ExtensionSet.gitHubWeb,
    );

    return result;
  }

  Course render(Course course) {
    final sections = course.sections.toList();

    for (int i = 0; i < sections.length; ++i) {
      final section = sections[i];
      final units = section.units;

      for (int j = 0; j < units.length; ++j) {
        final unit = units[j];
        final steps = unit.lesson.steps.toList();

        for (int k = 0; k < steps.length; ++k) {
          final step = steps[k];

          final renderedText = renderText(step.block.text);
          final renderedStep = step.copyWith(
            block: step.block.copyWith(text: renderedText),
          );
          steps[k] = renderedStep;
        }

        final renderedUnit = unit.copyWith(
          lesson: unit.lesson.copyWith(steps: steps),
        );
        units[j] = renderedUnit;
      }

      final renderedSection = section.copyWith(units: units);
      sections[i] = renderedSection;
    }
    final renderedCourse = course.copyWith(
      sections: sections,
    );
    return renderedCourse;
  }
}

import 'package:pluto/domain/step.dart';
import 'package:pluto/extensions/string_extensions.dart';

class StepCodec {
  const StepCodec();

  Step? read(String content) {}

  String write(Step step) {
    final sb = StringBuffer('---\n');
    sb.writeln('id: ${step.id ?? ''}');
    final label = step.label;
    if (label != null && label.isNotEmpty) {
      sb.writeln('label: $label');
    }
    sb.writeln(
      'type: ${switch (step) {
        TextStep() => 'text',
        CodeStep() => 'code',
        ChoiceStep(:final isMultipleChoice) => isMultipleChoice ? 'multiple_choice' : 'single_choice',
        FreeAnswerStep() => 'free_answer',
      }}',
    );

    switch (step) {
      case TextStep():
      case CodeStep():
        break;
      case ChoiceStep():
        sb.writeln('is_always_correct: ${step.isAlwaysCorrect}');
        sb.writeln('preserve_order: ${step.preserveOrder}');
        sb.writeln('is_html_enabled: ${step.isHtmlEnabled}');
      case FreeAnswerStep():
        sb.writeln('manual_scoring: ${step.manualScoring}');
        sb.writeln('is_attachments_enabled: ${step.isAttachmentsEnabled}');
        sb.writeln('is_html_enabled: ${step.isHtmlEnabled}');
    }

    sb.writeln('---');

    sb.write(step.text);

    switch (step) {
      case TextStep():
      case FreeAnswerStep():
        break;
      case ChoiceStep(:final options):
        sb.writeln();
        sb.writeln();
        sb.writeln('## options');
        sb.writeln();
        for (final option in options) {
          final lines = option.text.splitByLines();
          sb.writeln(
            '- [${option.isCorrect ? 'x' : ' '}] ${lines.firstOrNull ?? ''}',
          );
          // Continuation lines carry the two-space indent that keeps them part
          // of the item; blank lines stay blank so trailing whitespace is not
          // written into the file.
          for (final line in lines.skip(1)) {
            sb.writeln(line.isEmpty ? '' : '  $line');
          }
          for (final line in option.feedback.splitByLines()) {
            sb.writeln('  > $line');
          }
        }
      case CodeStep(:final samples, :final tests, :final code):
        sb.writeln('```samples');
        for (final sample in samples) {
          sb.writeln(sample.input);
          sb.writeln(sample.output);
        }
        sb.writeln('```');
        sb.writeln('```tests');
        for (final test in tests) {
          sb.writeln(test.input);
          sb.writeln(test.output);
        }
        sb.writeln('```');
        sb.writeln('```dart');
        sb.write(code);
        sb.writeln('```');
    }

    return sb.toString();
  }
}

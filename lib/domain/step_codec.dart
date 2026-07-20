import 'package:pluto/domain/step.dart';

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
        sb.writeln('```options');
        for (final option in options) {
          sb.writeln(option.isCorrect);
          sb.writeln(option.text);
          sb.writeln(option.feedback);
        }
        sb.write('```');
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

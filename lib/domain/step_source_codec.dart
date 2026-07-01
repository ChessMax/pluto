import 'package:pluto/domain/step_source.dart';

class StepSourceCodec {
  const StepSourceCodec();

  StepSource? read(String content) {}

  String write(StepSource stepSource) {
    final type = stepSource.block.name;
    final source = stepSource.block.source;

    final sb = StringBuffer('---\n');
    sb.writeln('id: ${stepSource.id ?? ''}');
    sb.writeln(
      'type: ${switch (type) {
        .code => 'code',
        .text => 'text',
        .singleChoice => 'single_choice',
        .multipleChoice => 'multiple_choice',
      }}',
    );

    if (source is ChoiceStepBlockSource) {
      sb.writeln('is_always_correct: ${source.isAlwaysCorrect}');
      sb.writeln('preserve_order: ${source.preserveOrder}');
      sb.writeln('is_html_enabled: ${source.isHtmlEnabled}');
    }

    sb.writeln('---');

    sb.write(stepSource.block.text);

    switch (stepSource.block.options) {
      case TextStepBlockOptions():
        break;
      case ChoiceStepBlockOptions():
        break;
      case CodeStepBlockOptions(:final samples):
        sb.writeln('```samples');
        for (final sample in samples) {
          sb.writeln(sample.input);
          sb.writeln(sample.output);
        }
        sb.writeln('```');
        break;
    }

    switch (source) {
      case TextStepBlockSource():
        break;
      case ChoiceStepBlockSource():
        sb.writeln('```options');
        for (final option in source.options) {
          sb.writeln(option.isCorrect);
          sb.writeln(option.text);
          sb.writeln(option.feedback);
        }
        sb.write('```');
        break;
      case CodeStepBlockSource(:final testCases, :final code):
        sb.writeln('```tests');
        for (final test in testCases) {
          sb.writeln(test.input);
          sb.writeln(test.output);
        }
        sb.writeln('```');
        sb.writeln('```dart');
        sb.write(code);
        sb.writeln('```');
        break;
    }

    return sb.toString();
  }
}

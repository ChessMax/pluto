import 'package:pluto/data/json.dart';
import 'package:pluto/domain/step.dart';

/// Converts a domain [Step] into Stepik's `step-source` payload.
///
/// Everything Stepik requires but an author never writes — `test_archive`,
/// the execution limits, the grader stub — is contained here rather than in
/// the domain model.
JsonObject stepToDto(Step step, int lessonId, [JsonObject? base]) {
  assert(step.position > 0);

  // Key order matters to callers that merge over `base`: 'lesson' stays last.
  return {
    ...?base,
    if (step.id != null) 'id': step.id,
    'position': step.position,
    'block': _blockToDto(step),
    'lesson': lessonId,
  };
}

JsonObject _blockToDto(Step step) {
  return {
    'name': switch (step) {
      TextStep() => 'text',
      ChoiceStep() => 'choice',
      CodeStep() => 'code',
      FreeAnswerStep() => 'free-answer',
    },
    'text': step.renderedText ?? (throw 'Rendered text is expected'),
    if (step is QuizStep && step.feedbackCorrect?.isNotEmpty == true)
      'feedback_correct': step.feedbackCorrect,
    if (step is QuizStep && step.feedbackWrong?.isNotEmpty == true)
      'feedback_wrong': step.feedbackWrong,
    'options': _optionsToDto(step),
    'source': _sourceToDto(step),
  };
}

JsonObject _optionsToDto(Step step) {
  return switch (step) {
    TextStep() => const {},
    FreeAnswerStep() => const {},
    ChoiceStep(:final isMultipleChoice) => {
      'is_multiple_choice': isMultipleChoice,
    },
    CodeStep(:final samples) => {
      'samples': [
        for (final sample in samples) _testCaseToDto(sample),
      ],
    },
  };
}

JsonObject _sourceToDto(Step step) {
  return switch (step) {
    TextStep() => const {},
    ChoiceStep(
      :final isMultipleChoice,
      :final isAlwaysCorrect,
      :final preserveOrder,
      :final isHtmlEnabled,
      :final options,
    ) =>
      {
        'is_multiple_choice': isMultipleChoice,
        'is_always_correct': isAlwaysCorrect,
        'preserve_order': preserveOrder,
        'is_html_enabled': isHtmlEnabled,
        'options': [
          for (final option in options)
            {
              'text': option.text,
              'feedback': option.feedback,
              'is_correct': option.isCorrect,
            },
        ],
        // TODO: it should be able to manipulate this parameter.
        'sample_size': options.length,
        // required params
        'is_options_feedback': false,
      },
    FreeAnswerStep(
      :final manualScoring,
      :final isAttachmentsEnabled,
      :final isHtmlEnabled,
    ) =>
      {
        'manual_scoring': manualScoring,
        'is_attachments_enabled': isAttachmentsEnabled,
        'is_html_enabled': isHtmlEnabled,
      },
    CodeStep(:final tests, :final samplesCount) => {
      // TODO: when updating? this overrides?
      // required param
      'test_archive': const <int>[],
      'is_time_limit_scaled': true,
      'is_memory_limit_scaled': true,
      'manual_time_limits': const <int>[],
      'manual_memory_limits': const <int>[],
      'execution_time_limit': 5,
      'execution_memory_limit': 256,
      'code':
          'def generate():\n    return []\n\ndef check(reply, clue):\n    return reply.strip() == clue.strip()',
      // end required param
      // TODO: allow to change?
      'templates_data': '::dart\n\n\n\n\n',
      'samples_count': samplesCount,
      'test_cases': [
        for (final test in tests) _testCaseToDto(test),
      ],
    },
  };
}

List<String> _testCaseToDto(TestCase testCase) => [
  testCase.input,
  testCase.output,
];

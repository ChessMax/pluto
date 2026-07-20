/// A single step of a course.
///
/// This is the *authoring* model, deliberately flat: one type per kind of step,
/// carrying only what an author writes. Stepik's `block`/`source`/`options`
/// shape is a transport concern and lives in `lib/data/step_mapper.dart`.
sealed class Step {
  final int? id;

  final int position;

  /// Stable name for `ref:` links, so a link survives the step being renumbered
  /// or moved. Author-supplied and course-unique; see [LinkIndex].
  final String? label;

  /// The author's Markdown.
  final String text;

  /// [text] rendered to HTML. Null until the course has been through
  /// `RenderRepository`; pushing an unrendered step is an error.
  final String? renderedText;

  const Step({
    required this.id,
    required this.position,
    required this.text,
    this.label,
    this.renderedText,
  });

  Step copyWith({int? id, String? renderedText});
}

/// A step the student answers, and which can therefore carry feedback.
sealed class QuizStep extends Step {
  /// Shown after a correct submission.
  final String? feedbackCorrect;

  /// Shown after an incorrect submission.
  final String? feedbackWrong;

  const QuizStep({
    required super.id,
    required super.position,
    required super.text,
    this.feedbackCorrect,
    this.feedbackWrong,
    super.label,
    super.renderedText,
  });
}

final class TextStep extends Step {
  const TextStep({
    required super.id,
    required super.position,
    required super.text,
    super.label,
    super.renderedText,
  });

  @override
  TextStep copyWith({int? id, String? renderedText}) => TextStep(
    id: id ?? this.id,
    position: position,
    text: text,
    label: label,
    renderedText: renderedText ?? this.renderedText,
  );
}

// TODO: for always correct answers we could use simple syntax, should we?
class ChoiceOption {
  final bool isCorrect;

  final String text;

  final String feedback;

  const ChoiceOption({
    required this.isCorrect,
    required this.text,
    required this.feedback,
  });
}

final class ChoiceStep extends QuizStep {
  final bool isMultipleChoice;

  final bool isAlwaysCorrect;

  final bool preserveOrder;

  final bool isHtmlEnabled;

  final List<ChoiceOption> options;

  const ChoiceStep({
    required super.id,
    required super.position,
    required super.text,
    required this.isMultipleChoice,
    required this.isAlwaysCorrect,
    required this.preserveOrder,
    required this.isHtmlEnabled,
    required this.options,
    super.feedbackCorrect,
    super.feedbackWrong,
    super.label,
    super.renderedText,
  });

  @override
  ChoiceStep copyWith({int? id, String? renderedText}) => ChoiceStep(
    id: id ?? this.id,
    position: position,
    text: text,
    isMultipleChoice: isMultipleChoice,
    isAlwaysCorrect: isAlwaysCorrect,
    preserveOrder: preserveOrder,
    isHtmlEnabled: isHtmlEnabled,
    options: options,
    feedbackCorrect: feedbackCorrect,
    feedbackWrong: feedbackWrong,
    label: label,
    renderedText: renderedText ?? this.renderedText,
  );
}

// TODO: add command to get all always correct answers.
/// A free-form text answer step. With [manualScoring] `false` Stepik
/// auto-accepts any submission, which makes it usable as a survey question
/// (no "wrong answer", answers still recorded and retrievable via submissions).
final class FreeAnswerStep extends QuizStep {
  final bool manualScoring;

  final bool isAttachmentsEnabled;

  final bool isHtmlEnabled;

  const FreeAnswerStep({
    required super.id,
    required super.position,
    required super.text,
    required this.manualScoring,
    required this.isAttachmentsEnabled,
    required this.isHtmlEnabled,
    super.feedbackCorrect,
    super.feedbackWrong,
    super.label,
    super.renderedText,
  });

  @override
  FreeAnswerStep copyWith({int? id, String? renderedText}) => FreeAnswerStep(
    id: id ?? this.id,
    position: position,
    text: text,
    manualScoring: manualScoring,
    isAttachmentsEnabled: isAttachmentsEnabled,
    isHtmlEnabled: isHtmlEnabled,
    feedbackCorrect: feedbackCorrect,
    feedbackWrong: feedbackWrong,
    label: label,
    renderedText: renderedText ?? this.renderedText,
  );
}

class TestCase {
  final String input;

  final String output;

  const TestCase({required this.input, required this.output});
}

final class CodeStep extends QuizStep {
  /// Starter code shown to the student.
  final String code;

  /// Cases the submission is graded against.
  final List<TestCase> tests;

  /// Cases shown to the student as worked examples.
  final List<TestCase> samples;

  // TODO: derive from `samples` once the parser stops hardcoding it.
  final int samplesCount;

  const CodeStep({
    required super.id,
    required super.position,
    required super.text,
    required this.code,
    required this.tests,
    required this.samples,
    required this.samplesCount,
    super.feedbackCorrect,
    super.feedbackWrong,
    super.label,
    super.renderedText,
  });

  @override
  CodeStep copyWith({int? id, String? renderedText}) => CodeStep(
    id: id ?? this.id,
    position: position,
    text: text,
    code: code,
    tests: tests,
    samples: samples,
    samplesCount: samplesCount,
    feedbackCorrect: feedbackCorrect,
    feedbackWrong: feedbackWrong,
    label: label,
    renderedText: renderedText ?? this.renderedText,
  );
}

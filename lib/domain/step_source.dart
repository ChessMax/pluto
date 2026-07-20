import 'package:pluto/data/json.dart';

class StepSource {
  final int? id;
  final int position;
  final StepBlock block;

  /// Stable name for `ref:` links, so a link survives the step being renumbered
  /// or moved. Author-supplied and course-unique; see [LinkIndex].
  final String? label;

  StepSource({
    required this.id,
    required this.position,
    required this.block,
    this.label,
  });

  StepSource copyWith({
    int? id,
    int? position,
    StepBlock? block,
    String? label,
  }) {
    return StepSource(
      id: id ?? this.id,
      block: block ?? this.block,
      position: position ?? this.position,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      if (label != null) 'label': label,
      'block': block.toJson(),
    };
  }

  Map<String, dynamic> toDto(int lessonId, [JsonObject? base]) {
    assert(position > 0);

    return {
      ...?base,
      if (id != null) 'id': id,
      'position': position,
      'block': block.toDto(),
      'lesson': lessonId,
    };
  }
}

enum StepBlockType {
  text,
  singleChoice,
  multipleChoice,
  code,
  freeAnswer,
  ;

  static StepBlockType parse(String value) =>
      StepBlockType.values.firstWhere((type) => type.name == value);

  String toDto() {
    return switch (this) {
      .code => 'code',
      .text => 'text',
      .singleChoice => 'choice',
      .multipleChoice => 'choice',
      .freeAnswer => 'free-answer',
    };
  }
}

sealed class StepBlockSource {
  const StepBlockSource();

  Object toJson();

  Object toDto();
}

class TextStepBlockSource extends StepBlockSource {
  const TextStepBlockSource();

  @override
  Object toJson() => {};

  @override
  Object toDto() => toJson();
}

// TODO: for always correct answers we could use simple syntax, should we?
class ChoiceStepBlockOption {
  final bool isCorrect;
  final String text;
  final String feedback;

  ChoiceStepBlockOption({
    required this.isCorrect,
    required this.text,
    required this.feedback,
  });

  Object toJson() {
    return {
      'text': text,
      'feedback': feedback,
      'is_correct': isCorrect,
    };
  }
}

class ChoiceStepBlockSource extends StepBlockSource {
  final bool isMultipleChoice;
  final bool isAlwaysCorrect;
  final bool preserveOrder;
  final bool isHtmlEnabled;
  final List<ChoiceStepBlockOption> options;

  const ChoiceStepBlockSource({
    required this.isMultipleChoice,
    required this.isAlwaysCorrect,
    required this.preserveOrder,
    required this.isHtmlEnabled,
    required this.options,
  });

  @override
  Object toJson() {
    return {
      'is_multiple_choice': isMultipleChoice,
      'is_always_correct': isAlwaysCorrect,
      'preserve_order': preserveOrder,
      'is_html_enabled': isHtmlEnabled,
      'options': [
        for (final option in options) option.toJson(),
      ],
    };
  }

  @override
  Object toDto() => {
    ...(toJson() as JsonObject),
    // TODO: it should be able to manipulate this parameter.
    'sample_size': options.length,
    // required params
    'is_options_feedback': false,
  };
}

// TODO: add command to get all always correct answers.
/// A free-form text answer step. With [manualScoring] `false` Stepik
/// auto-accepts any submission, which makes it usable as a survey question
/// (no "wrong answer", answers still recorded and retrievable via submissions).
class FreeAnswerStepBlockSource extends StepBlockSource {
  final bool manualScoring;
  final bool isAttachmentsEnabled;
  final bool isHtmlEnabled;

  const FreeAnswerStepBlockSource({
    required this.manualScoring,
    required this.isAttachmentsEnabled,
    required this.isHtmlEnabled,
  });

  @override
  Object toJson() {
    return {
      'manual_scoring': manualScoring,
      'is_attachments_enabled': isAttachmentsEnabled,
      'is_html_enabled': isHtmlEnabled,
    };
  }

  @override
  Object toDto() => toJson();
}

class CodeStepBlockSource extends StepBlockSource {
  final int samplesCount;
  final List<CodeTestCase> testCases;
  final String code;

  const CodeStepBlockSource({
    required this.code,
    required this.testCases,
    required this.samplesCount,
  });

  @override
  Object toJson() {
    return {
      'samples_count': samplesCount,
      'test_cases': [
        for (final tc in testCases) tc.toJson(),
      ],
    };
  }

  @override
  Object toDto() {
    return {
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
        for (final tc in testCases) tc.toDto(),
      ],
    };
  }
}

sealed class StepBlockOptions {
  const StepBlockOptions();

  Object toJson();

  Object toDto();
}

class TextStepBlockOptions extends StepBlockOptions {
  const TextStepBlockOptions();

  @override
  Object toJson() => {};

  @override
  Object toDto() => toJson();
}

class ChoiceStepBlockOptions extends StepBlockOptions {
  final bool isMultipleChoice;

  const ChoiceStepBlockOptions({required this.isMultipleChoice});

  @override
  Object toJson() => {'is_multiple_choice': isMultipleChoice};

  @override
  Object toDto() => toJson();
}

class FreeAnswerStepBlockOptions extends StepBlockOptions {
  const FreeAnswerStepBlockOptions();

  @override
  Object toJson() => {};

  @override
  Object toDto() => toJson();
}

class CodeStepBlockOptions extends StepBlockOptions {
  final List<CodeTestCase> samples;

  const CodeStepBlockOptions({required this.samples});

  @override
  Object toJson() {
    return {
      'samples': [
        for (final sample in samples) sample.toJson(),
      ],
    };
  }

  @override
  Object toDto() {
    return {
      'samples': [
        for (final sample in samples) sample.toDto(),
      ],
    };
  }
}

class CodeTestCase {
  final String input;
  final String output;

  CodeTestCase({required this.input, required this.output});

  JsonObject toJson() {
    return {
      'input': input,
      'output': output,
    };
  }

  Object toDto() {
    return [input, output];
  }
}

class StepBlock {
  final StepBlockType name;
  final String text;
  final String? textRendered;
  final String? feedbackCorrect;
  final String? feedbackWrong;
  final StepBlockOptions options;
  final StepBlockSource source;

  StepBlock({
    required this.name,
    required this.text,
    this.textRendered,
    required this.feedbackCorrect,
    required this.feedbackWrong,
    required this.options,
    required this.source,
  });

  StepBlock copyWith({
    StepBlockType? name,
    String? text,
    String? textRendered,
    String? feedbackCorrect,
    String? feedbackWrong,
    StepBlockOptions? options,
    StepBlockSource? source,
  }) {
    return StepBlock(
      name: name ?? this.name,
      text: text ?? this.text,
      textRendered: textRendered ?? this.textRendered,
      feedbackCorrect: feedbackCorrect ?? this.feedbackCorrect,
      feedbackWrong: feedbackWrong ?? this.feedbackWrong,
      options: options ?? this.options,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.name,
      'text': text,
      'feedback_correct': feedbackCorrect,
      'feedback_wrong': feedbackWrong,
      'options': options.toJson(),
      'source': source.toJson(),
    };
  }

  Map<String, dynamic> toDto() {
    return {
      'name': name.toDto(),
      'text': textRendered ?? (throw 'Rendered text is expected'),
      if (feedbackCorrect?.isNotEmpty == true)
        'feedback_correct': feedbackCorrect,
      if (feedbackWrong?.isNotEmpty == true) 'feedback_wrong': feedbackWrong,
      'options': options.toDto(),
      'source': source.toDto(),
    };
  }
}

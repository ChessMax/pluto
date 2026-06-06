// TODO: rename to stepSource??
import 'package:pluto/data/json.dart';

class StepSource {
  final int? id;
  final int position;
  final StepBlock block;

  StepSource({required this.id, required this.position, required this.block});

  StepSource copyWith({
    int? id,
    int? position,
    StepBlock? block,
  }) {
    return StepSource(
      id: id ?? this.id,
      block: block ?? this.block,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
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
  choice,
  code,
  ;

  static StepBlockType parse(String value) =>
      StepBlockType.values.firstWhere((type) => type.name == value);
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
  Object toDto() => toJson();
}

class CodeStepBlockSource extends StepBlockSource {
  final int samplesCount;
  final List<CodeTestCase> testCases;

  const CodeStepBlockSource({
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
      'samples_count': samplesCount,
      'test_cases': [
        for (final tc in testCases) tc.toJson(),
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
  final String? feedbackCorrect;
  final String? feedbackWrong;
  final StepBlockOptions options;
  final StepBlockSource source;

  StepBlock({
    required this.name,
    required this.text,
    required this.feedbackCorrect,
    required this.feedbackWrong,
    required this.options,
    required this.source,
  });

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
      'name': name.name,
      'text': text,
      if (feedbackCorrect?.isNotEmpty == true)
        'feedback_correct': feedbackCorrect,
      if (feedbackWrong?.isNotEmpty == true) 'feedback_wrong': feedbackWrong,
      'options': options.toDto(),
      'source': source.toDto(),
    };
  }
}

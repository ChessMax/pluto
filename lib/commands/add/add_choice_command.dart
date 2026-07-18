import 'package:args/args.dart';
import 'package:pluto/commands/add/add_step_command.dart';
import 'package:pluto/domain/step_source.dart';

abstract class AddChoiceCommand extends AddStepCommand {
  bool get isMultipleChoice;

  StepBlockType get blockType => isMultipleChoice
      ? .multipleChoice
      : .singleChoice;

  @override
  void registerExtraArgs(ArgParser parser) {
    parser.addFlag(
      'is-always-correct',
      help: 'Accept any answer as correct.',
      defaultsTo: false,
    );
  }

  List<ChoiceStepBlockOption> _templateOptions() {
    return [
      ChoiceStepBlockOption(isCorrect: true, text: 'Option 1', feedback: ''),
      ChoiceStepBlockOption(isCorrect: false, text: 'Option 2', feedback: ''),
      ChoiceStepBlockOption(isCorrect: false, text: 'Option 3', feedback: ''),
    ];
  }

  @override
  StepBlock buildBlock(String text) {
    final isAlwaysCorrect = argResults?.flag('is-always-correct') ?? false;
    return StepBlock(
      name: blockType,
      text: text,
      textRendered: null,
      feedbackCorrect: null,
      feedbackWrong: null,
      options: ChoiceStepBlockOptions(isMultipleChoice: isMultipleChoice),
      source: ChoiceStepBlockSource(
        isMultipleChoice: isMultipleChoice,
        isAlwaysCorrect: isAlwaysCorrect,
        preserveOrder: false,
        isHtmlEnabled: false,
        options: _templateOptions(),
      ),
    );
  }
}

class AddSingleChoiceCommand extends AddChoiceCommand {
  @override
  String get name => 'single-choice';

  @override
  String get description => 'Adds a single-choice quiz step to a lesson.';

  @override
  bool get isMultipleChoice => false;
}

class AddMultipleChoiceCommand extends AddChoiceCommand {
  @override
  String get name => 'multiple-choice';

  @override
  String get description => 'Adds a multiple-choice quiz step to a lesson.';

  @override
  bool get isMultipleChoice => true;
}

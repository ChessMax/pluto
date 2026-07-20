import 'package:args/args.dart';
import 'package:pluto/commands/add/add_step_command.dart';
import 'package:pluto/domain/step.dart';

abstract class AddChoiceCommand extends AddStepCommand {
  bool get isMultipleChoice;

  @override
  void registerExtraArgs(ArgParser parser) {
    parser.addFlag(
      'is-always-correct',
      help: 'Accept any answer as correct.',
      defaultsTo: false,
    );
  }

  List<ChoiceOption> _templateOptions() {
    return const [
      ChoiceOption(isCorrect: true, text: 'Option 1', feedback: ''),
      ChoiceOption(isCorrect: false, text: 'Option 2', feedback: ''),
      ChoiceOption(isCorrect: false, text: 'Option 3', feedback: ''),
    ];
  }

  @override
  ChoiceStep buildStep(String text, int position) {
    final isAlwaysCorrect = argResults?.flag('is-always-correct') ?? false;
    return ChoiceStep(
      id: null,
      position: position,
      text: text,
      isMultipleChoice: isMultipleChoice,
      isAlwaysCorrect: isAlwaysCorrect,
      preserveOrder: false,
      isHtmlEnabled: false,
      options: _templateOptions(),
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

import 'package:args/args.dart';
import 'package:pluto/commands/add/add_step_command.dart';
import 'package:pluto/domain/step_source.dart';

class AddFreeAnswerCommand extends AddStepCommand {
  @override
  String get name => 'free-answer';

  @override
  String get description => 'Adds a free-answer (survey) step to a lesson.';

  @override
  void registerExtraArgs(ArgParser parser) {
    parser.addFlag(
      'manual-scoring',
      help: 'Instructor grades answers. Off means Stepik auto-accepts any '
          'answer (survey behaviour).',
      defaultsTo: false,
    );
  }

  @override
  StepBlock buildBlock(String text) {
    final manualScoring = argResults?.flag('manual-scoring') ?? false;
    return StepBlock(
      name: .freeAnswer,
      text: text,
      textRendered: null,
      feedbackCorrect: null,
      feedbackWrong: null,
      options: const FreeAnswerStepBlockOptions(),
      source: FreeAnswerStepBlockSource(
        manualScoring: manualScoring,
        isAttachmentsEnabled: false,
        isHtmlEnabled: false,
      ),
    );
  }
}

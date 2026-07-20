import 'package:args/args.dart';
import 'package:pluto/commands/add/add_step_command.dart';
import 'package:pluto/domain/step.dart';

class AddFreeAnswerCommand extends AddStepCommand {
  @override
  String get name => 'free-answer';

  @override
  String get description => 'Adds a free-answer (survey) step to a lesson.';

  @override
  void registerExtraArgs(ArgParser parser) {
    parser.addFlag(
      'manual-scoring',
      help:
          'Instructor grades answers. Off means Stepik auto-accepts any '
          'answer (survey behaviour).',
      defaultsTo: false,
    );
  }

  @override
  FreeAnswerStep buildStep(String text, int position) {
    final manualScoring = argResults?.flag('manual-scoring') ?? false;
    return FreeAnswerStep(
      id: null,
      position: position,
      text: text,
      manualScoring: manualScoring,
      isAttachmentsEnabled: false,
      isHtmlEnabled: false,
    );
  }
}

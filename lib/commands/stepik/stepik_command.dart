import 'package:args/command_runner.dart';
import 'package:pluto/commands/stepik/stepik_list_command.dart';

class StepikCommand extends Command<void> {
  @override
  String get name => 'stepik';

  @override
  String get description => 'Stepik api commands.';

  StepikCommand() {
    addSubcommand(StepikListCommand());
  }
}

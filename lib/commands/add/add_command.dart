import 'package:args/command_runner.dart';
import 'package:pluto/commands/add/add_free_answer_command.dart';
import 'package:pluto/commands/add/add_section_command.dart';

class AddCommand extends Command<void> {
  @override
  String get name => 'add';

  @override
  String get description => 'Adds new lesson, steps, sections to the existing course.';

  AddCommand() {
    addSubcommand(AddSectionCommand());
    addSubcommand(AddFreeAnswerCommand());
  }
}

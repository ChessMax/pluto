import 'package:args/command_runner.dart';
import 'package:pluto/commands/init/init_course_command.dart';

class InitCommand extends Command<void> {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize working directory.';

  InitCommand() {
    addSubcommand(InitCourseCommand());
  }
}

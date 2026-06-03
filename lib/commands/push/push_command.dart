import 'package:args/command_runner.dart';
import 'package:pluto/commands/init/init_course_command.dart';

class PushCommand extends Command<void> {
  @override
  String get name => 'push';

  @override
  String get description => 'Pushes changes to server.';

  PushCommand() {
    addSubcommand(InitCourseCommand());
  }
}

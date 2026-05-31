import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pluto/assets/templates/asset_templates.dart';
import 'package:pluto/commands/init/init_course_command.dart';
import 'package:pluto/commands/stepik/stepik_list_command.dart';
import 'package:pluto/template/template.dart';

class StepikCommand extends Command<void> {
  @override
  String get name => 'stepik';

  @override
  String get description => 'Stepik api commands.';

  StepikCommand() {
    addSubcommand(StepikListCommand());
  }
}

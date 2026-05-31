import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pluto/assets/templates/asset_templates.dart';
import 'package:pluto/commands/init/init_course_command.dart';
import 'package:pluto/template/template.dart';

class InitCommand extends Command<void> {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize working directory.';

  InitCommand() {
    addSubcommand(InitCourseCommand());
  }
}

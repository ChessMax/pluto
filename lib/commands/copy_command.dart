import 'package:args/command_runner.dart';

class CopyCommand extends Command<void> {
  @override
  final name = "copy";
  
  @override
  final description = "Copies course source from one directory to another.";

  CopyCommand() {
    argParser.addOption('src', abbr: 's', help: 'Path to course directory.');
    argParser.addOption('dest', abbr: 'd', help: 'Path to new course directory.');
  }

  @override
  void run() {
    final src = argResults!.option('src');
    final dest = argResults!.option('dest');
    print('$src -> $dest');
  }
}
import 'package:pluto/commands/command.dart';

class VersionCommand extends Command {
  const VersionCommand() : super('version');

  Future<void> execute() async {
    print('pluto version 0.0.1');
  }
}
import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/commands/command.dart';

class InitCourseCommand extends Command {
  const InitCourseCommand() : super('init');

  Future<void> execute(String name) async {
    String relativePath(String part, [String? part2]) => join('.', name, part, part2);

    await run(['dart', 'create', name]);
    await deleteDirectory(relativePath('bin'));
    await deleteDirectory(relativePath('test'));
    await deleteFile(relativePath('lib', '$name.dart'));

    print('Course $name initialized');
  }

  Future<void> deleteFile(String path) async {
    print('Deleting file `$path`...');
    await File(path).delete();
  }

  Future<void> deleteDirectory(String path) async {
    print('Deleting dir `$path`...');
    await Directory(path).delete(recursive: true);
  }
  
  Future<void> run(List<String> args) async {
    final command = args.join(' ');
    print('Run `$command`...');
    final result = await Process.run(args.removeAt(0), args);
    if (result.exitCode != 0) {
      throw 'Command `command` failed with error code: ${result.exitCode}';
    }
  }
}
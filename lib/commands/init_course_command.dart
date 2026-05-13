import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/assets/templates/asset_templates.dart';
import 'package:pluto/commands/command.dart';

class InitCourseCommand extends Command {
  const InitCourseCommand() : super('init');

  Future<void> execute(String name) async {
    String relativePath(String part, [String? part2, String? part3, String? part4]) =>
        join('.', name, part, part2, part3, part4);

    await run(['dart', 'create', name]);
    await run([
      'dart',
      'pub',
      'add',
      'dev:pluto:{path: ..}',
    ], workingDirectory: relativePath(''));
    await deleteDirectory(relativePath('bin'));
    await deleteDirectory(relativePath('test'));
    await deleteFile(relativePath('lib', '$name.dart'));
    await createDir(relativePath('source'));

    print('Creating course.md ...');

    await AssetTemplates.course.renderToFile(
      relativePath('source', 'course.md'),
      {
        'id': null,
        'title': name,
        'title_en': name,
        'summary': '',
        'acquired_assets': '',
        'description': '',
        'target_audience': '',
        'requirements': '',
        'learning_format': '',
        'acquired_skills': '',
        'sections': const <int>[],
      },
    );

    print('Creating lesson.md ...');

    await AssetTemplates.lesson.renderToFile(
      relativePath('source', '01', '01', 'lesson.md'),
      {
        'id': null,
        'title': 'My lesson',
        'steps': const <int>[],
      },
    );

    print('Course $name initialized');
  }

  Future<void> createDir(String path) async {
    print('Creating directory `$path`...');
    await Directory(path).create(recursive: true);
  }

  Future<void> deleteFile(String path) async {
    print('Deleting file `$path`...');
    await File(path).delete();
  }

  Future<void> deleteDirectory(String path) async {
    print('Deleting dir `$path`...');
    await Directory(path).delete(recursive: true);
  }

  Future<void> run(List<String> args, {String? workingDirectory}) async {
    final command = args.join(' ');
    print(
      'Run `$command${workingDirectory != null ? ' at `$workingDirectory`' : ''}`...',
    );
    final result = await Process.run(
      args.removeAt(0),
      args,
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) {
      print(result.stderr);
      throw 'Command `$command` failed with error code: ${result.exitCode}';
    }
  }
}

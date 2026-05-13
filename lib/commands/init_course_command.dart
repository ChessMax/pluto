import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/assets/templates/asset_templates.dart';
import 'package:pluto/commands/command.dart';
import 'package:pluto/template/template.dart';

class InitCourseCommand extends Command {
  const InitCourseCommand() : super('init');

  Future<void> execute(String name) async {
    String relativePath(
      String part, [
      String? part2,
      String? part3,
      String? part4,
    ]) => join('.', name, part, part2, part3, part4);

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

    final path = ['.', name, 'source'];

    String getPath(String fileName) {
      path.add(fileName);
      final result = joinAll(path);
      path.removeLast();
      return result;
    }

    await renderToFile(
      getPath('course.md'),
      AssetTemplates.course,
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

    path.add('section_01');
    await renderToFile(getPath('section_01.md'), AssetTemplates.section, {
      'id': null,
      'course': null,
      'units': const <int>[],
      'position': 1,
      'title': 'My section',
    });

    path.add('unit_01');

    await renderToFile(getPath('unit_01.md'), AssetTemplates.unit, {
      'id': null,
      'section': null,
      'lesson': null,
      'position': 1,
    });

    await renderToFile(
      getPath('lesson_01.md'),
      AssetTemplates.lesson,
      {
        'id': null,
        'title': 'My lesson',
        'steps': const <int>[],
      },
    );

    print('Course $name initialized');
  }

  Future<void> renderToFile(
    String path,
    Future<Template> template,
    dynamic model,
  ) async {
    print('Creating `$path` ...');
    await template.renderToFile(path, model);
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

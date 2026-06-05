import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';

class InitCourseCommand extends Command<void> {
  @override
  String get name => 'course';

  @override
  String get description => 'Initialize course directory';

  InitCourseCommand() {
    // argParser.addOption('name', abbr: 'n', help: 'Directory name like `my_course`');
  }

  @override
  Future<void> run() async {
    // final name = argResults!.option('name')!;
    final name = argResults!.rest[0];

    print('Initialize $name course:');

    String relativePath(
      String part, [
      String? part2,
      String? part3,
      String? part4,
    ]) => join('.', name, part, part2, part3, part4);

    await runCmd(['dart', 'create', name]);
    await runCmd([
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

    final step1 = Step(
      id: null,
      position: 1,
      block: StepBlock(
        name: .text,
        text: 'Source of your first step',
        options: const TextStepBlockOptions(),
        source: const TextStepBlockSource(),
        feedbackCorrect: null,
        feedbackWrong: null,
      ),
    );
    final lesson1 = Lesson(id: null, title: 'My lesson', steps: [step1]);
    final unit1 = Unit(id: null, position: 1, lesson: lesson1);
    final section1 = Section(
      id: null,
      position: 1,
      units: [unit1],
      title: 'My section',
      description: 'My section description',
    );
    final course = Course(
      id: null,
      title: name,
      titleEn: name,
      sections: [section1],
      summary: 'Some summary text',
    );

    await const SourceRepository().writeCourse(course, join('.', name));

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

  Future<void> runCmd(List<String> args, {String? workingDirectory}) async {
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

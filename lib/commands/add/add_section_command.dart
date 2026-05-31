import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/section.dart';

class AddSectionCommand extends Command<void> {
  @override
  String get name => 'section';

  @override
  String get description => 'Adds new section.';

  AddSectionCommand() {
    argParser.addOption('path', abbr: 'p', help: 'Path to course directory');
    argParser.addOption('title', abbr: 't', help: 'Section title');
    argParser.addOption('description', abbr: 'd', help: 'Section description');
  }

  @override
  Future<void> run() async {
    final dir = argResults!.option('path') ?? Directory.current.path;
    final sourceRepository = const SourceRepository();
    final course = await sourceRepository.readCourse(dir);

    final position = course.sections.length + 1;

    final title =
        argResults!.option('title') ?? 'Section $position';
    final description =
        argResults!.option('description') ?? 'Section description';

    final section = Section(
      id: null,
      units: [],
      title: title,
      position: position,
      description: description,
    );

    final updatedCourse = course.copyWith(
      sections: [...course.sections, section],
    );

    await sourceRepository.writeCourse(updatedCourse, dir);
  }
}

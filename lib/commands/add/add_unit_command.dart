import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';

class AddUnitCommand extends Command<void> {
  @override
  String get name => 'unit';

  @override
  String get description =>
      'Adds new unit (with an empty lesson) to a section.';

  AddUnitCommand() {
    argParser
      ..addOption('path', abbr: 'p', help: 'Path to course directory')
      ..addOption(
        'section',
        abbr: 's',
        help: 'Section number (1-based); defaults to the last section',
      )
      ..addOption('title', abbr: 't', help: 'Lesson title');
  }

  @override
  Future<void> run() async {
    final dir = argResults?.option('path') ?? Directory.current.path;

    const sourceRepository = SourceRepository();
    final course = await sourceRepository.readCourse(dir);

    if (course.sections.isEmpty) {
      throw UsageException(
        'Course has no sections; add a section first.',
        usage,
      );
    }

    final section = switch (argResults?.option('section')) {
      null => course.sections.last,
      final raw => _resolveSection(course.sections, raw),
    };

    final position = section.units.length + 1;
    final title = argResults?.option('title') ?? 'Unit $position';

    final step1 = TextStep(
      id: null,
      position: 1,
      text: 'Source of your first step',
    );

    final unit = Unit(
      id: null,
      position: position,
      lesson: Lesson(id: null, title: title, steps: [step1]),
    );

    final updatedSection = section.copyWith(
      units: [...section.units, unit],
    );
    final updatedCourse = course.copyWith(
      sections: [
        for (final s in course.sections)
          s.position == section.position ? updatedSection : s,
      ],
    );

    await sourceRepository.writeCourse(updatedCourse, dir);
  }

  Section _resolveSection(List<Section> sections, String raw) {
    final number = int.tryParse(raw);
    if (number == null || number < 1) {
      throw UsageException(
        'Option --section must be a positive number.',
        usage,
      );
    }
    final section = sections.where((s) => s.position == number).firstOrNull;
    if (section == null) {
      throw UsageException('No section $number in the course.', usage);
    }
    return section;
  }
}

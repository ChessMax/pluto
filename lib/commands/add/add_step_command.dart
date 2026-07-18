import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/step_source.dart';

/// Base class for commands that append a single [StepSource] to a lesson.
abstract class AddStepCommand extends Command<void> {
  AddStepCommand() {
    argParser
      ..addOption('path', abbr: 'p', help: 'Path to course directory')
      ..addOption('section', abbr: 's', help: 'Section number (1-based)')
      ..addOption('unit', abbr: 'u', help: 'Unit number within the section')
      ..addOption('text', abbr: 't', help: 'Question text');
    registerExtraArgs(argParser);
  }

  /// Registers step-specific options/flags if needed.
  void registerExtraArgs(ArgParser parser) {}

  /// Builds the block to append. Subclasses can read their own flags via [argResults].
  StepBlock buildBlock(String text);

  int _requirePosition(String option) {
    final raw = argResults?.option(option);
    if (raw == null) {
      throw UsageException('Option --$option is required.', usage);
    }
    final value = int.tryParse(raw);
    if (value == null || value < 1) {
      throw UsageException(
        'Option --$option must be a positive number.',
        usage,
      );
    }
    return value;
  }

  @override
  Future<void> run() async {
    final dir = argResults?.option('path') ?? Directory.current.path;
    final sectionNumber = _requirePosition('section');
    final unitNumber = _requirePosition('unit');
    final text = argResults?.option('text') ?? 'Your question here.';

    const sourceRepository = SourceRepository();
    final course = await sourceRepository.readCourse(dir);

    final section = course.sections
        .where((s) => s.position == sectionNumber)
        .firstOrNull;
    if (section == null) {
      throw UsageException('No section $sectionNumber in the course.', usage);
    }

    final unit = section.units
        .where((u) => u.position == unitNumber)
        .firstOrNull;
    if (unit == null) {
      throw UsageException(
        'No unit $unitNumber in section $sectionNumber.',
        usage,
      );
    }

    final lesson = unit.lesson;
    if (lesson.steps.length >= maxStepsPerLesson) {
      throw UsageException(
        'Lesson already has the maximum of $maxStepsPerLesson steps.',
        usage,
      );
    }

    final step = StepSource(
      id: null,
      position: lesson.steps.length + 1,
      block: buildBlock(text),
    );

    final updatedLesson = lesson.copyWith(steps: [...lesson.steps, step]);
    final updatedUnit = unit.copyWith(lesson: updatedLesson);
    final updatedSection = section.copyWith(
      units: [
        for (final u in section.units)
          u.position == unitNumber ? updatedUnit : u,
      ],
    );
    final updatedCourse = course.copyWith(
      sections: [
        for (final s in course.sections)
          s.position == sectionNumber ? updatedSection : s,
      ],
    );

    await sourceRepository.writeCourse(updatedCourse, dir);
  }
}

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';

/// Base class for commands that append a single [Step] to a lesson.
abstract class AddStepCommand extends Command<void> {
  AddStepCommand() {
    argParser
      ..addOption('path', abbr: 'p', help: 'Path to course directory')
      ..addOption(
        'section',
        abbr: 's',
        help: 'Section number (1-based); defaults to the last section',
      )
      ..addOption(
        'unit',
        abbr: 'u',
        help: 'Unit number within the section; defaults to the last unit',
      )
      ..addOption('text', abbr: 't', help: 'Step text');
    registerExtraArgs(argParser);
  }

  /// Registers step-specific options/flags if needed.
  void registerExtraArgs(ArgParser parser) {}

  /// Used when `--text` is omitted.
  String get defaultText => 'Your question here.';

  /// Builds the step to append. Subclasses can read their own flags via [argResults].
  Step buildStep(String text, int position);

  int? _optionalPosition(String option) {
    final raw = argResults?.option(option);
    if (raw == null) return null;
    final value = int.tryParse(raw);
    if (value == null || value < 1) {
      throw UsageException(
        'Option --$option must be a positive number.',
        usage,
      );
    }
    return value;
  }

  Section _resolveSection(List<Section> sections) {
    if (sections.isEmpty) {
      throw UsageException(
        'Course has no sections; add a section first.',
        usage,
      );
    }
    return switch (_optionalPosition('section')) {
      null => sections.last,
      final number =>
        sections.where((s) => s.position == number).firstOrNull ??
            (throw UsageException('No section $number in the course.', usage)),
    };
  }

  Unit _resolveUnit(Section section) {
    if (section.units.isEmpty) {
      throw UsageException(
        'Section ${section.position} has no units; add a unit first.',
        usage,
      );
    }
    return switch (_optionalPosition('unit')) {
      null => section.units.last,
      final number =>
        section.units.where((u) => u.position == number).firstOrNull ??
            (throw UsageException(
              'No unit $number in section ${section.position}.',
              usage,
            )),
    };
  }

  @override
  Future<void> run() async {
    final dir = argResults?.option('path') ?? Directory.current.path;
    final text = argResults?.option('text') ?? defaultText;

    const sourceRepository = SourceRepository();
    final course = await sourceRepository.readCourse(dir);

    final section = _resolveSection(course.sections);
    final unit = _resolveUnit(section);

    final lesson = unit.lesson;
    if (lesson.steps.length >= maxStepsPerLesson) {
      throw UsageException(
        'Lesson already has the maximum of $maxStepsPerLesson steps.',
        usage,
      );
    }

    final step = buildStep(text, lesson.steps.length + 1);

    final updatedLesson = lesson.copyWith(steps: [...lesson.steps, step]);
    final updatedUnit = unit.copyWith(lesson: updatedLesson);
    final updatedSection = section.copyWith(
      units: [
        for (final u in section.units)
          u.position == unit.position ? updatedUnit : u,
      ],
    );
    final updatedCourse = course.copyWith(
      sections: [
        for (final s in course.sections)
          s.position == section.position ? updatedSection : s,
      ],
    );

    await sourceRepository.writeCourse(updatedCourse, dir);
  }
}

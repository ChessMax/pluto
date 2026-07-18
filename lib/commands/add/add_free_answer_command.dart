import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/step_source.dart';

class AddFreeAnswerCommand extends Command<void> {
  @override
  String get name => 'free-answer';

  @override
  String get description => 'Adds a free-answer (survey) step to a lesson.';

  AddFreeAnswerCommand() {
    argParser
      ..addOption('path', abbr: 'p', help: 'Path to course directory')
      ..addOption('section', abbr: 's', help: 'Section number (1-based)')
      ..addOption('unit', abbr: 'u', help: 'Unit number within the section')
      ..addOption('text', abbr: 't', help: 'Question text')
      ..addFlag(
        'manual-scoring',
        help: 'Instructor grades answers. Off means Stepik auto-accepts any '
            'answer (survey behaviour).',
        defaultsTo: false,
      );
  }

  int _requirePosition(String option) {
    final raw = argResults?.option(option);
    if (raw == null) throw UsageException('Option --$option is required.', usage);
    final value = int.tryParse(raw);
    if (value == null || value < 1) {
      throw UsageException('Option --$option must be a positive number.', usage);
    }
    return value;
  }

  @override
  Future<void> run() async {
    final dir = argResults?.option('path') ?? Directory.current.path;
    final sectionNumber = _requirePosition('section');
    final unitNumber = _requirePosition('unit');
    final text = argResults?.option('text') ?? 'Your question here.';
    final manualScoring = argResults?.flag('manual-scoring') ?? false;

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
      block: StepBlock(
        name: StepBlockType.freeAnswer,
        text: text,
        textRendered: null,
        feedbackCorrect: null,
        feedbackWrong: null,
        options: const FreeAnswerStepBlockOptions(),
        source: FreeAnswerStepBlockSource(
          manualScoring: manualScoring,
          isAttachmentsEnabled: false,
          isHtmlEnabled: true,
        ),
      ),
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

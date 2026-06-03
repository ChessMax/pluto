import 'package:pluto/stepik_api/raw_stepik_api.dart';

class CourseEntity {
  final RawCourseDto course;
  final List<RawSectionDto> sections;
  final Map<RawSectionDto, List<RawUnitDto>> sectionUnits;
  final Map<RawUnitDto, RawLessonDto> unitLessons;
  final Map<RawLessonDto, List<RawStepSourceDto>> lessonSteps;

  CourseEntity({
    required this.course,
    required this.sections,
    required this.sectionUnits,
    required this.unitLessons,
    required this.lessonSteps,
  }) {
    if (course.sections.length != sections.length) {
      throw 'Inconsistent sections lengths';
    }

    for (final sectionId in course.sections) {
      final section = getSectionById(sectionId);
      if (section == null) {
        throw 'Section with id `$sectionId` not found';
      }

      final unitIds = section.units;
      final units = sectionUnits[section];
      if (units == null || units.length != unitIds.length) {
        throw 'Inconsistent units lengths';
      }

      for (final unitId in unitIds) {
        final unit = getUnitById(units, unitId);
        if (unit == null) {
          throw 'Unit with id `$unitId` not found';
        }

        final lessonId = unit.lesson;
        final lesson = unitLessons[unit];
        if (lesson == null || lesson.id != lessonId) {
          throw 'Inconsistent lesson lengths';
        }

        final stepIds = lesson.steps;
        final steps = lessonSteps[lesson];
        if (steps == null || steps.length != stepIds.length) {
          throw 'Inconsistent steps lengths';
        }

        for (final stepId in stepIds) {
          final step = getStepById(steps, stepId);
          if (step == null) {
            throw 'Step with id `$stepId` not found';
          }
        }
      }
    }
  }

  RawSectionDto? getSectionById(int sectionId) {
    for (final section in sections) {
      if (section.id == sectionId) {
        return section;
      }
    }
    return null;
  }

  RawUnitDto? getUnitById(List<RawUnitDto> units, int unitId) {
    for (final unit in units) {
      if (unit.id == unitId) {
        return unit;
      }
    }
    return null;
  }

  RawStepSourceDto? getStepById(List<RawStepSourceDto> steps, int stepId) {
    for (final step in steps) {
      if (step.id == stepId) {
        return step;
      }
    }
    return null;
  }
}

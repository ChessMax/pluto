import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/remote_course.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';

/// When a [Diff] can be applied, relative to rendering.
///
/// Step text may contain `ref:` links to other steps, and resolving one needs
/// the target lesson's real id — which only exists once the lesson has been
/// created. So structure is pushed first, the course is rendered against the
/// ids that came back, and only then is any text sent.
enum DiffPhase {
  /// Creates/updates course, sections, lessons and units: everything that mints
  /// an id. Carries no rendered Markdown.
  structure,

  /// Sends rendered text: step sources, and the course summary.
  content,

  /// Deletions. Reference only remote ids, so they are payload-independent.
  removal,
}

// TODO: check if something really changed, not just added/removed.
sealed class Diff {
  DiffPhase get phase => switch (this) {
    CourseAdded() ||
    SectionAdded() ||
    SectionUpdated() ||
    LessonAdded() ||
    LessonUpdated() ||
    UnitAdded() ||
    UnitUpdated() => .structure,
    StepAdded() || StepUpdated() || CourseUpdated() => .content,
    CourseDeleted() ||
    SectionRemoved() ||
    LessonRemoved() ||
    UnitRemove() ||
    StepRemoved() => .removal,
  };

  static Iterable<Diff> create(CourseEntity? entity, Course course) sync* {
    if ((course.id != null) != (entity != null)) {
      throw 'Inconsistent state';
    }

    // updating
    if (entity != null) {
      final sectionsToRemove = entity.sections.toList();
      final lessonsToRemove = entity.lessons.toList();
      final stepsToRemove = entity.steps.toList();
      final unitsToRemove = entity.units.toList();

      for (
        var sectionIndex = 0;
        sectionIndex < course.sections.length;
        ++sectionIndex
      ) {
        final section = course.sections[sectionIndex];
        final sectionId = section.id;

        if (sectionId == null) {
          yield SectionAdded(section: section, sectionIndex: sectionIndex);
        } else {
          final sectionBase = sectionsToRemove.removeFirstWhere(
            (section) => section.id == sectionId,
          );
          yield SectionUpdated(base: sectionBase, section: section);
        }

        for (var unitIndex = 0; unitIndex < section.units.length; ++unitIndex) {
          final unit = section.units[unitIndex];
          final unitId = unit.id;
          final lesson = unit.lesson;
          final lessonId = lesson.id;

          if (lessonId == null) {
            yield LessonAdded(
              lesson: lesson,
              sectionIndex: sectionIndex,
              unitIndex: unitIndex,
            );
          } else {
            final lessonBase = lessonsToRemove.removeFirstWhere(
              (lesson) => lesson.id == lessonId,
            );
            yield LessonUpdated(base: lessonBase, lesson: lesson);
          }

          for (
            var stepIndex = 0;
            stepIndex < lesson.steps.length;
            ++stepIndex
          ) {
            final step = lesson.steps[stepIndex];
            final stepId = step.id;

            if (stepId == null) {
              yield StepAdded(
                step: step,
                sectionIndex: sectionIndex,
                unitIndex: unitIndex,
                stepIndex: stepIndex,
              );
            } else {
              final stepBase = stepsToRemove.removeFirstWhere(
                (step) => step.id == stepId,
              );
              yield StepUpdated(
                base: stepBase,
                step: step,
                sectionIndex: sectionIndex,
                unitIndex: unitIndex,
                stepIndex: stepIndex,
              );
            }
          }

          if (unitId == null) {
            yield UnitAdded(
              unit: unit,
              sectionIndex: sectionIndex,
              unitIndex: unitIndex,
            );
          } else {
            final unitBase = unitsToRemove.removeFirstWhere(
              (unit) => unit.id == unitId,
            );
            yield UnitUpdated(base: unitBase, unit: unit);
          }
        }
      }

      for (final stepToRemove in stepsToRemove) {
        yield StepRemoved(stepId: stepToRemove.id);
      }

      for (final lessonToRemove in lessonsToRemove) {
        yield LessonRemoved(lessonId: lessonToRemove.id);
      }

      for (final unitToRemove in unitsToRemove) {
        yield UnitRemove(unitId: unitToRemove.id);
      }

      for (final sectionToRemove in sectionsToRemove) {
        yield SectionRemoved(sectionId: sectionToRemove.id);
      }

      yield CourseUpdated(base: entity.course, course: course);

      return;
    }

    yield CourseAdded(course: course);

    for (
      var sectionIndex = 0;
      sectionIndex < course.sections.length;
      ++sectionIndex
    ) {
      final section = course.sections[sectionIndex];

      yield SectionAdded(section: section, sectionIndex: sectionIndex);

      for (var unitIndex = 0; unitIndex < section.units.length; ++unitIndex) {
        final unit = section.units[unitIndex];
        final lesson = unit.lesson;

        yield LessonAdded(
          lesson: lesson,
          sectionIndex: sectionIndex,
          unitIndex: unitIndex,
        );

        for (var stepIndex = 0; stepIndex < lesson.steps.length; ++stepIndex) {
          final step = lesson.steps[stepIndex];

          yield StepAdded(
            step: step,
            sectionIndex: sectionIndex,
            unitIndex: unitIndex,
            stepIndex: stepIndex,
          );
        }

        yield UnitAdded(
          unit: unit,
          sectionIndex: sectionIndex,
          unitIndex: unitIndex,
        );
      }
    }
  }
}

class StepAdded extends Diff {
  final Step step;
  final int sectionIndex;
  final int unitIndex;
  final int stepIndex;

  StepAdded({
    required this.step,
    required this.sectionIndex,
    required this.unitIndex,
    required this.stepIndex,
  });
}

class StepUpdated extends Diff {
  final RawStepSourceDto base;
  final Step step;
  final int sectionIndex;
  final int unitIndex;
  final int stepIndex;

  StepUpdated({
    required this.base,
    required this.step,
    required this.sectionIndex,
    required this.unitIndex,
    required this.stepIndex,
  });
}

class StepRemoved extends Diff {
  final int stepId;

  StepRemoved({required this.stepId});
}

class LessonAdded extends Diff {
  final Lesson lesson;
  final int sectionIndex;
  final int unitIndex;

  LessonAdded({
    required this.lesson,
    required this.sectionIndex,
    required this.unitIndex,
  });
}

class LessonUpdated extends Diff {
  final RawLessonDto base;
  final Lesson lesson;

  LessonUpdated({required this.base, required this.lesson});
}

class LessonRemoved extends Diff {
  final int lessonId;

  LessonRemoved({required this.lessonId});
}

class UnitAdded extends Diff {
  final Unit unit;
  final int sectionIndex;
  final int unitIndex;

  UnitAdded({
    required this.unit,
    required this.sectionIndex,
    required this.unitIndex,
  });
}

class UnitUpdated extends Diff {
  final RawUnitDto base;
  final Unit unit;

  UnitUpdated({
    required this.base,
    required this.unit,
  });
}

class UnitRemove extends Diff {
  final int unitId;

  UnitRemove({required this.unitId});
}

class SectionAdded extends Diff {
  final Section section;
  final int sectionIndex;

  SectionAdded({required this.section, required this.sectionIndex});
}

class SectionUpdated extends Diff {
  final RawSectionDto base;
  final Section section;

  SectionUpdated({required this.base, required this.section});
}

class SectionRemoved extends Diff {
  final int sectionId;

  SectionRemoved({required this.sectionId});
}

class CourseAdded extends Diff {
  final Course course;

  CourseAdded({required this.course});
}

class CourseUpdated extends Diff {
  final RawCourseDto base;
  final Course course;

  CourseUpdated({required this.base, required this.course});
}

class CourseDeleted extends Diff {
  final int courseId;

  CourseDeleted({required this.courseId});
}

extension DiffListExt on List<Diff> {
  void dump() {
    final sb = StringBuffer();

    for (final diff in this) {
      switch (diff) {
        case StepAdded(:final step):
          sb.writeln('Step added: ${step.text}');
          break;
        case StepUpdated(:final base, :final step):
          sb.writeln(
            'Step updated: ${base.block.text} -> ${step.text}',
          );
          break;
        case StepRemoved(:final stepId):
          sb.writeln('Step source removed: $stepId');
          break;
        case LessonAdded(:final lesson):
          sb.writeln('Lesson added: ${lesson.title}');
          break;
        case LessonUpdated(:final base, :final lesson):
          sb.writeln('Lesson updated: ${base.title} -> ${lesson.title}');
          break;
        case LessonRemoved(:final lessonId):
          sb.writeln('Lesson removed: $lessonId');
          break;
        case UnitAdded(:final unit):
          sb.writeln('Unit added: ${unit.lesson.title}');
          break;
        case UnitUpdated(:final base, :final unit):
          sb.writeln('Lesson updated: ... -> ${unit.lesson.title}');
          break;
        case UnitRemove(:final unitId):
          sb.writeln('Unit removed: $unitId');
          break;
        case SectionAdded(:final section):
          sb.writeln('Section added: ${section.title}');
          break;
        case SectionUpdated(:final base, :final section):
          sb.writeln('Section updated: ${base.title} -> ${section.title}');
          break;
        case SectionRemoved(:final sectionId):
          sb.writeln('Section removed: $sectionId');
          break;
        case CourseAdded(:final course):
          sb.writeln('Course added: ${course.title}');
          break;
        case CourseUpdated(:final base, :final course):
          sb.writeln('Course updated: ${base.title} -> ${course.title}');
          break;
        case CourseDeleted(:final courseId):
          sb.writeln('Course removed: $courseId');
          break;
      }
    }

    print(sb);
  }
}

extension<T> on List<T> {
  T removeFirstWhere(bool Function(T) predicate) {
    for (var i = 0; i < length; ++i) {
      final item = this[i];
      if (predicate(item)) {
        removeAt(i);
        return item;
      }
    }

    throw 'Failed to find item';
  }
}

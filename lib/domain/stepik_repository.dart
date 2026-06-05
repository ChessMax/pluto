import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/remote_course.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';

class StepikRepository {
  final RawStepikApi _api;

  const StepikRepository(this._api);

  Future<CourseEntity> readCourse(int courseId) async {
    final course = await _api.course.fetchById(courseId);
    if (course == null) throw 'Failed to fetch course by id';

    final sections = await _api.section.fetchAllByIds(course.sections);

    if (sections == null) throw 'Failed to fetch course sections';

    final allUnits = <RawUnitDto>[];
    final allLessons = <RawLessonDto>[];
    final allSteps = <RawStepSourceDto>[];

    for (final section in sections) {
      final units = await _api.unit.fetchByIds(section.units);
      if (units == null) throw 'Failed to fetch units';

      allUnits.addAll(units);

      for (final unit in units) {
        final lesson = await _api.lesson.fetchById(unit.lesson);
        if (lesson == null) throw 'Failed to fetch lesson';

        allLessons.add(lesson);

        final steps = await _api.stepSource.fetchByIds(lesson.steps);
        if (steps == null) throw 'Failed to fetch steps';

        allSteps.addAll(steps);
      }
    }

    final entity = CourseEntity(
      course: course,
      sections: sections,
      units: allUnits,
      lessons: allLessons,
      steps: allSteps,
    );

    return entity;
  }

  // TODO: copy with new lists?
  Future<Course> writeCourse(Course course) async {
    if (course.id != null) {
      throw 'Attempt to create course instead of updating';
    }

    final courseDto = course.toDto();
    final courseId = (await _api.course.create(courseDto))?.id;
    if (courseId == null) {
      throw 'Failed to create course $courseDto';
    }

    course = course.copyWith(id: courseId);

    for (var i = 0; i < course.sections.length; ++i) {
      final section = course.sections[i];
      final sectionDto = section.toDto(courseId);

      final sectionId = (await _api.section.create(sectionDto))?.id;
      if (sectionId == null) {
        throw 'Failed to create section: $sectionDto';
      }

      course.sections[i] = section.copyWith(id: sectionId);

      for (var j = 0; j < section.units.length; ++j) {
        final unit = section.units[j];
        final lesson = unit.lesson;
        final lessonPayload = lesson.toDto();

        final lessonId = (await _api.lesson.create(lessonPayload))?.id;
        if (lessonId == null) {
          throw 'Failed to create lesson: $lessonPayload';
        }

        section.units[j] = unit.copyWith(lesson: lesson.copyWith(id: lessonId));

        for (var k = 0; k < lesson.steps.length; ++k) {
          final stepSource = lesson.steps[k];
          final stepSourceDto = stepSource.toDto(lessonId);

          final stepId = (await _api.stepSource.create(stepSourceDto))?.id;
          if (stepId == null) {
            throw 'Failed to create step source: $stepSourceDto}';
          }

          lesson.steps[k] = stepSource.copyWith(id: stepId);
        }

        final unitDto = unit.toDto(sectionId, lessonId);
        final unitId = (await _api.unit.create(unitDto))?.id;
        if (unitId == null) {
          throw 'Failed to create unit: $unitDto';
        }
      }
    }

    return course;
  }

  Future<Course> updateCourse(CourseEntity entity, Course course) async {
    final courseId = course.id;

    if (courseId == null) {
      throw 'Attempt to update course instead of creating';
    }

    // TODO: better make diff and apply it

    // TODO: check that all models that have id have corresponding entities.
    // TODO: remove sections/units/lessons/steps that are not needed any more?
    for (var i = 0; i < course.sections.length; ++i) {
      final section = course.sections[i];
      var sectionId = section.id;

      if (sectionId == null) {
        final sectionDto = section.toDto(courseId);

        sectionId = (await _api.section.create(sectionDto))?.id;
        if (sectionId == null) {
          throw 'Failed to create section: $sectionDto';
        }

        course.sections[i] = section.copyWith(id: sectionId);
      } else {
        final sectionDto = section.toDto(
          courseId,
          entity.getSectionById(sectionId)!,
        );
        await _api.section.update(sectionId, sectionDto);
      }

      for (var j = 0; j < section.units.length; ++j) {
        final unit = section.units[j];
        final unitId = unit.id;
        final lesson = unit.lesson;
        final lessonPayload = lesson.toDto();

        var lessonId = lesson.id;
        if (lessonId == null) {
          lessonId = (await _api.lesson.create(lessonPayload))?.id;
          if (lessonId == null) {
            throw 'Failed to create lesson: $lessonPayload';
          }

          section.units[j] = unit.copyWith(
            lesson: lesson.copyWith(id: lessonId),
          );
        } else {
          final lessonDto = lesson.toDto(entity.getLessonById(lessonId)!);
          await _api.lesson.update(lessonId, lessonDto);
        }

        for (var k = 0; k < lesson.steps.length; ++k) {
          final stepSource = lesson.steps[k];
          final stepSourceId = stepSource.id;

          if (stepSourceId == null) {
            final stepSourceDto = stepSource.toDto(lessonId);

            final stepId = (await _api.stepSource.create(stepSourceDto))?.id;
            if (stepId == null) {
              throw 'Failed to create step source: $stepSourceDto}';
            }

            lesson.steps[k] = stepSource.copyWith(id: stepId);
          } else {
            final stepSourceDto = stepSource.toDto(
              lessonId,
              entity.getStepById(stepSourceId),
            );
            await _api.stepSource.update(stepSourceId, stepSourceDto);
          }
        }

        if (unitId == null) {
          final unitDto = unit.toDto(sectionId, lessonId);
          final unitId = (await _api.unit.create(unitDto))?.id;
          if (unitId == null) {
            throw 'Failed to create unit: $unitDto';
          }
        } else {
          final unitDto = unit.toDto(
            sectionId,
            lessonId,
            entity.getUnitById(unitId),
          );
          await _api.unit.update(unitId, unitDto);
        }
      }
    }

    final courseDto = course.toDto(entity.course);
    await _api.course.update(courseId, courseDto);

    return course;
  }

  Future<Course> applyDiff(Course course, List<Diff> diffs) async {
    late int courseId;
    late int sectionId;
    late int unitId;
    late int lessonId;
    late int stepSourceId;

    for (final diff in diffs) {
      switch (diff) {
        case StepSourceAdded(:final stepSource):
          final stepSourceDto = stepSource.toDto(lessonId);
          stepSourceId = (await _api.stepSource.create(stepSourceDto))!.id;
          course = course.copyWithStepSource(stepSource, (stepSource) => stepSource.copyWith(id: stepSourceId));
          break;
        case StepSourceUpdated(:final base, :final stepSource):
          final stepSourceDto = stepSource.toDto(lessonId, base);
          await _api.stepSource.update(base.id, stepSourceDto);
          break;
        case StepSourceRemoved(:final stepSourceId):
          await _api.stepSource.delete(stepSourceId);
          break;
        case LessonAdded(:final lesson):
          final lessonDto = lesson.toDto();
          lessonId = (await _api.lesson.create(lessonDto))!.id;
          course = course.copyWithLesson(lesson, (lesson) => lesson.copyWith(id: lessonId));
          break;
        case LessonUpdated(:final base, :final lesson):
          final lessonDto = lesson.toDto(base);
          await _api.lesson.update(base.id, lessonDto);
          break;
        case LessonRemoved(:final lessonId):
          await _api.lesson.delete(lessonId);
          break;
        case UnitAdded(:final unit):
          final unitDto = unit.toDto(sectionId);
          unitId = (await _api.unit.create(unitDto))!.id;
          course = course.copyWithUnit(unit, (unit) => unit.copyWith(id: unitId));
          break;
        case UnitUpdated(:final base, :final unit):
          final unitDto = unit.toDto(sectionId, lessonId, base);
          await _api.unit.update(base.id, unitDto);
          break;
        case UnitRemove(:final unitId):
          await _api.unit.delete(unitId);
          break;
        case SectionAdded(:final section):
          final sectionDto = section.toDto(courseId);
          sectionId = (await _api.section.create(sectionDto))!.id;
          course = course.copyWithSection(
            section,
            (section) => section.copyWith(id: sectionId),
          );
          break;
        case SectionUpdated(:final base, :final section):
          final sectionDto = section.toDto(courseId, base);
          await _api.section.update(base.id, sectionDto);
          break;
        case SectionRemoved(:final sectionId):
          await _api.section.delete(sectionId);
          break;
        case CourseAdded(course: final c):
          final courseDto = c.toDto();
          courseId = (await _api.course.create(courseDto))!.id;
          course = course.copyWith(id: courseId);
          break;
        case CourseUpdated(:final base, :final course):
          final courseDto = course.toDto(base);
          await _api.course.update(base.id, courseDto);
          break;
        case CourseDeleted(:final courseId):
          await _api.course.delete(courseId);
          break;
      }
    }
    return course;
  }
}

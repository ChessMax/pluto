import 'package:fpdart/fpdart.dart';
import 'package:pluto/domain/course.dart';
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

    final sectionUnits = <RawSectionDto, List<RawUnitDto>>{};
    final unitLessons = <RawUnitDto, RawLessonDto>{};
    final lessonSteps = <RawLessonDto, List<RawStepSourceDto>>{};

    for (final section in sections) {
      final units = await _api.unit.fetchByIds(section.units);
      if (units == null) throw 'Failed to fetch units';

      sectionUnits[section] = units;

      for (final unit in units) {
        final lesson = await _api.lesson.fetchById(unit.lesson);
        if (lesson == null) throw 'Failed to fetch lesson';

        unitLessons[unit] = lesson;

        final steps = await _api.stepSource.fetchByIds(lesson.steps);
        if (steps == null) throw 'Failed to fetch steps';

        lessonSteps[lesson] = steps;
      }
    }

    final entity = CourseEntity(
      course: course,
      sections: sections,
      sectionUnits: sectionUnits,
      unitLessons: unitLessons,
      lessonSteps: lessonSteps,
    );

    return entity;
  }

  Future<void> writeCourse(Course course) async {
    if (course.id != null) {
      throw 'Attempt to create course instead of updating';
    }

    final courseDto = course.toDto();
    final courseId = (await _api.course.create(courseDto))?.id;
    if (courseId == null) {
      throw 'Failed to create course $courseDto';
    }

    for (final section in course.sections) {
      final sectionDto = section.toDto(courseId);

      final sectionId = (await _api.section.create(sectionDto))?.id;
      if (sectionId == null) {
        throw 'Failed to create section: $sectionDto';
      }

      for (final unit in section.units) {
        final lesson = unit.lesson;
        final lessonPayload = lesson.toDto();

        final lessonId = (await _api.lesson.create(lessonPayload))?.id;
        if (lessonId == null) {
          throw 'Failed to create lesson: $lessonPayload';
        }

        for (final stepSource in lesson.steps) {
          final stepSourceDto = stepSource.toDto(lessonId);

          final stepId = (await _api.stepSource.create(stepSourceDto))?.id;
          if (stepId == null) {
            throw 'Failed to create step source: $stepSourceDto}';
          }
        }

        final unitDto = unit.toDto(sectionId, lessonId);
        final unitId = (await _api.unit.create(unitDto))?.id;
        if (unitId == null) {
          throw 'Failed to create unit: $unitDto';
        }
      }

    }



    for (final section in course.sections) {

    }
  }

  Future<void> updateCourse(CourseEntity entity, Course course) async {}
}

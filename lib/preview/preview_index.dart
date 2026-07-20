import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/course_ids.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step_source.dart';
import 'package:pluto/domain/unit.dart';

/// One lesson, addressable the way Stepik addresses it: `/lesson/{lessonId}/
/// step/{n}?unit={unitId}`.
///
/// [lessonId] and [unitId] are the real Stepik ids when the source carries them
/// and stable synthetic ones otherwise — see [PreviewIndex.build].
class PreviewLesson {
  final int lessonId;
  final int unitId;

  final int sectionIndex;
  final int unitIndex;

  final Section section;
  final Unit unit;

  const PreviewLesson({
    required this.lessonId,
    required this.unitId,
    required this.sectionIndex,
    required this.unitIndex,
    required this.section,
    required this.unit,
  });

  Lesson get lesson => unit.lesson;

  List<StepSource> get steps => lesson.steps;

  /// Whether the ids are real Stepik ids rather than preview-local ones, which
  /// decides if the URL can be opened against stepik.org.
  bool get hasRemoteIds => lesson.id != null && unit.id != null;

  /// Canonical URL of [step] (1-based), matching Stepik's own URL shape.
  String urlOfStep(int step) => '/lesson/$lessonId/step/$step?unit=$unitId';
}

/// A course flattened into Stepik-style addressable lessons.
class PreviewIndex {
  final Course course;
  final List<PreviewLesson> lessons;

  final Map<int, List<PreviewLesson>> _byLessonId;

  PreviewIndex._(this.course, this.lessons, this._byLessonId);

  PreviewLesson? get firstLesson =>
      lessons.where((lesson) => lesson.steps.isNotEmpty).firstOrNull;

  /// URL the preview opens on: the first step of the first non-empty lesson.
  String? get entryUrl => firstLesson?.urlOfStep(1);

  /// Resolves `/lesson/{lessonId}/step/...?unit={unitId}`.
  ///
  /// [unitId] is optional: Stepik itself renders the lesson without it, so the
  /// first unit referencing the lesson is used when it is missing or unknown.
  PreviewLesson? resolve(int lessonId, {int? unitId}) {
    final candidates = _byLessonId[lessonId];
    if (candidates == null || candidates.isEmpty) return null;

    if (unitId != null) {
      for (final candidate in candidates) {
        if (candidate.unitId == unitId) return candidate;
      }
    }

    return candidates.first;
  }

  /// The lesson before/after [lesson] in course order, for prev/next paging
  /// across lesson boundaries.
  PreviewLesson? lessonBefore(PreviewLesson lesson) {
    final index = lessons.indexOf(lesson);
    for (var i = index - 1; i >= 0; --i) {
      if (lessons[i].steps.isNotEmpty) return lessons[i];
    }
    return null;
  }

  PreviewLesson? lessonAfter(PreviewLesson lesson) {
    final index = lessons.indexOf(lesson);
    for (var i = index + 1; i < lessons.length; ++i) {
      if (lessons[i].steps.isNotEmpty) return lessons[i];
    }
    return null;
  }

  static PreviewIndex build(Course course) {
    final lessons = <PreviewLesson>[];
    final ids = assignUnitIds(course);

    var flatIndex = 0;
    final sections = course.sections;
    for (var i = 0; i < sections.length; ++i) {
      final section = sections[i];
      final units = section.units;

      for (var j = 0; j < units.length; ++j) {
        final unit = units[j];
        final unitIds = ids[flatIndex++];

        lessons.add(
          PreviewLesson(
            lessonId: unitIds.lessonId,
            unitId: unitIds.unitId,
            sectionIndex: i,
            unitIndex: j,
            section: section,
            unit: unit,
          ),
        );
      }
    }

    final byLessonId = <int, List<PreviewLesson>>{};
    for (final lesson in lessons) {
      byLessonId.putIfAbsent(lesson.lessonId, () => []).add(lesson);
    }

    return PreviewIndex._(course, lessons, byLessonId);
  }
}

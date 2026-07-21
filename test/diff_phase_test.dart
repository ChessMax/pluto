import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/remote_course.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';
import 'package:test/test.dart';

Step _step(int position) => TextStep(
  id: null,
  position: position,
  text: 'step $position',
);

Course _newCourse() => Course(
  id: null,
  title: 'Course',
  sections: [
    Section(
      id: null,
      position: 1,
      title: 'Section',
      description: '',
      units: [
        Unit(
          id: null,
          position: 1,
          lesson: Lesson(
            id: null,
            title: 'Lesson',
            steps: [_step(1), _step(2)],
          ),
        ),
      ],
    ),
  ],
);

/// A course of one section holding a single unit/lesson/step, matched by the
/// [Course] the local source no longer contains.
CourseEntity _remoteEntity() => CourseEntity(
  course: RawCourseDto({
    'id': 1,
    'sections': [10],
  }),
  sections: [
    RawSectionDto({
      'id': 10,
      'course': 1,
      'position': 1,
      'units': [20],
    }),
  ],
  units: [
    RawUnitDto({'id': 20, 'section': 10, 'lesson': 30, 'position': 1}),
  ],
  lessons: [
    RawLessonDto({
      'id': 30,
      'title': 'Lesson',
      'steps': [40],
    }),
  ],
  steps: [
    RawStepSourceDto({'id': 40, 'lesson': 30, 'position': 1}),
  ],
);

Course _courseWithoutUnit() => Course(
  id: 1,
  title: 'Course',
  sections: [
    Section(id: 10, position: 1, title: 'Section', description: '', units: []),
  ],
);

void main() {
  group('Diff removal order', () {
    test('units are removed before the lessons they reference', () {
      final diffs = Diff.create(_remoteEntity(), _courseWithoutUnit()).toList();

      // Stepik cascades a lesson deletion onto its units, so removing the
      // lesson first leaves the unit DELETE to 404 and abort the push.
      expect(
        diffs.indexWhere((d) => d is UnitRemove),
        lessThan(diffs.indexWhere((d) => d is LessonRemoved)),
      );
    });

    test('steps are removed before their lesson', () {
      final diffs = Diff.create(_remoteEntity(), _courseWithoutUnit()).toList();

      expect(
        diffs.indexWhere((d) => d is StepRemoved),
        lessThan(diffs.indexWhere((d) => d is LessonRemoved)),
      );
    });
  });

  group('DiffPhase', () {
    test('a new course splits into structure then content', () {
      final diffs = Diff.create(null, _newCourse()).toList();

      final structure = diffs.where((d) => d.phase == .structure);
      final content = diffs.where((d) => d.phase == .content);

      // Everything that mints an id lands in the structure phase, so lesson ids
      // exist before any step text is rendered.
      expect(
        structure.map((d) => d.runtimeType.toString()),
        ['CourseAdded', 'SectionAdded', 'LessonAdded', 'UnitAdded'],
      );
      expect(content.map((d) => d.runtimeType.toString()), [
        'StepAdded',
        'StepAdded',
      ]);
    });

    test('no step diff is ever applied in the structure phase', () {
      final diffs = Diff.create(null, _newCourse()).toList();

      expect(
        diffs.where((d) => d.phase == .structure),
        everyElement(isNot(isA<StepAdded>())),
      );
    });

    test('lessons are created before the units that reference them', () {
      final diffs = Diff.create(
        null,
        _newCourse(),
      ).where((d) => d.phase == .structure).toList();

      expect(
        diffs.indexWhere((d) => d is LessonAdded),
        lessThan(diffs.indexWhere((d) => d is UnitAdded)),
      );
    });
  });
}

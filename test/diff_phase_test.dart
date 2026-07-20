import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
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

void main() {
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

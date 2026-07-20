import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/preview/preview_index.dart';
import 'package:test/test.dart';

Step _step(int position) => TextStep(
  id: null,
  position: position,
  text: 'step $position',
  renderedText: '<p>step $position</p>',
);

Unit _unit({
  required int position,
  int? unitId,
  int? lessonId,
  int steps = 2,
  String title = 'Lesson',
}) => Unit(
  id: unitId,
  position: position,
  lesson: Lesson(
    id: lessonId,
    title: title,
    steps: [for (var i = 1; i <= steps; ++i) _step(i)],
  ),
);

Course _course(List<Section> sections) =>
    Course(id: null, title: 'Course', sections: sections);

Section _section({
  required int position,
  required List<Unit> units,
  String title = 'Section',
}) => Section(
  id: null,
  position: position,
  title: title,
  description: '',
  units: units,
);

void main() {
  group('PreviewIndex ids', () {
    test('uses real stepik ids when the source carries them', () {
      final index = PreviewIndex.build(
        _course([
          _section(
            position: 1,
            units: [_unit(position: 1, unitId: 2527487, lessonId: 2489640)],
          ),
        ]),
      );

      final lesson = index.lessons.single;
      expect(lesson.lessonId, 2489640);
      expect(lesson.unitId, 2527487);
      expect(lesson.hasRemoteIds, isTrue);
      expect(lesson.urlOfStep(1), '/lesson/2489640/step/1?unit=2527487');
    });

    test('synthesises stepik-shaped ids when they are null', () {
      final index = PreviewIndex.build(
        _course([
          _section(position: 1, units: [_unit(position: 1)]),
        ]),
      );

      final lesson = index.lessons.single;
      expect(lesson.hasRemoteIds, isFalse);
      expect(lesson.lessonId, inInclusiveRange(1000000, 9999999));
      expect(lesson.unitId, inInclusiveRange(1000000, 9999999));
      expect(lesson.lessonId, isNot(lesson.unitId));
    });

    test('synthetic ids are stable across rebuilds', () {
      Course build() => _course([
        _section(position: 1, units: [_unit(position: 1)]),
      ]);

      final first = PreviewIndex.build(build()).lessons.single;
      final second = PreviewIndex.build(build()).lessons.single;

      expect(second.lessonId, first.lessonId);
      expect(second.unitId, first.unitId);
    });

    test('editing a lesson does not move its URL', () {
      final before = PreviewIndex.build(
        _course([
          _section(position: 1, units: [_unit(position: 1, title: 'Old')]),
        ]),
      ).lessons.single;

      final after = PreviewIndex.build(
        _course([
          _section(
            position: 1,
            units: [_unit(position: 1, title: 'New', steps: 5)],
          ),
        ]),
      ).lessons.single;

      expect(after.urlOfStep(1), before.urlOfStep(1));
    });

    test('inserting a section does not renumber existing lessons', () {
      final before = PreviewIndex.build(
        _course([
          _section(position: 1, units: [_unit(position: 1)]),
          _section(position: 2, units: [_unit(position: 1)]),
        ]),
      );

      final after = PreviewIndex.build(
        _course([
          _section(position: 1, units: [_unit(position: 1)]),
          _section(position: 2, units: [_unit(position: 1)]),
          _section(position: 3, units: [_unit(position: 1)]),
        ]),
      );

      expect(
        after.lessons.take(2).map((l) => l.lessonId),
        before.lessons.map((l) => l.lessonId),
      );
    });

    test('lessons in different units get different ids', () {
      final index = PreviewIndex.build(
        _course([
          _section(
            position: 1,
            units: [_unit(position: 1), _unit(position: 2)],
          ),
          _section(position: 2, units: [_unit(position: 1)]),
        ]),
      );

      final ids = index.lessons.map((l) => l.lessonId).toSet();
      expect(ids, hasLength(3));
    });
  });

  group('PreviewIndex resolution', () {
    late PreviewIndex index;

    setUp(() {
      index = PreviewIndex.build(
        _course([
          _section(
            position: 1,
            units: [
              _unit(position: 1, steps: 3, title: 'First'),
              _unit(position: 2, steps: 1, title: 'Second'),
            ],
          ),
          _section(
            position: 2,
            units: [_unit(position: 1, steps: 2, title: 'Third')],
          ),
        ]),
      );
    });

    test('resolves a lesson by id and unit', () {
      final target = index.lessons[1];
      final resolved = index.resolve(target.lessonId, unitId: target.unitId);
      expect(resolved?.lesson.title, 'Second');
    });

    test('resolves without a unit id, as stepik does', () {
      final target = index.lessons[2];
      expect(index.resolve(target.lessonId)?.lesson.title, 'Third');
    });

    test('falls back to the first unit when the unit id is unknown', () {
      final target = index.lessons[0];
      expect(
        index.resolve(target.lessonId, unitId: 999)?.lesson.title,
        'First',
      );
    });

    test('returns null for an unknown lesson', () {
      expect(index.resolve(4242), isNull);
    });

    test('entry url points at the first step of the first lesson', () {
      expect(index.entryUrl, index.lessons.first.urlOfStep(1));
    });

    test('pages across lesson boundaries', () {
      expect(index.lessonAfter(index.lessons[0]), index.lessons[1]);
      expect(index.lessonBefore(index.lessons[1]), index.lessons[0]);
      expect(index.lessonBefore(index.lessons[0]), isNull);
      expect(index.lessonAfter(index.lessons[2]), isNull);
    });

    test('skips empty lessons when paging', () {
      final sparse = PreviewIndex.build(
        _course([
          _section(
            position: 1,
            units: [
              _unit(position: 1, steps: 1, title: 'First'),
              _unit(position: 2, steps: 0, title: 'Empty'),
              _unit(position: 3, steps: 1, title: 'Last'),
            ],
          ),
        ]),
      );

      expect(sparse.lessonAfter(sparse.lessons[0])?.lesson.title, 'Last');
      expect(sparse.entryUrl, sparse.lessons[0].urlOfStep(1));
    });
  });
}

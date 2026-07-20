import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step_source.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/markdown/render_repository.dart';
import 'package:pluto/preview/preview_index.dart';
import 'package:test/test.dart';

StepSource _step(int position, {String? label}) => StepSource(
  id: null,
  position: position,
  label: label,
  block: StepBlock(
    name: .text,
    text: 'step $position',
    feedbackCorrect: null,
    feedbackWrong: null,
    options: const TextStepBlockOptions(),
    source: const TextStepBlockSource(),
  ),
);

Unit _unit({
  required int position,
  int? unitId,
  int? lessonId,
  List<StepSource>? steps,
}) => Unit(
  id: unitId,
  position: position,
  lesson: Lesson(
    id: lessonId,
    title: 'Lesson',
    steps: steps ?? [_step(1), _step(2)],
  ),
);

Section _section({required int position, required List<Unit> units}) => Section(
  id: null,
  position: position,
  title: 'Section',
  description: '',
  units: units,
);

Course _course(List<Section> sections) =>
    Course(id: null, title: 'Course', sections: sections);

Course _remoteCourse() => _course([
  _section(
    position: 1,
    units: [_unit(position: 1, unitId: 2527487, lessonId: 2489640)],
  ),
  _section(
    position: 2,
    units: [
      _unit(
        position: 1,
        unitId: 2527488,
        lessonId: 2489641,
        steps: [
          _step(1),
          _step(2, label: 'intro-variables'),
        ],
      ),
    ],
  ),
]);

void main() {
  group('LinkIndex resolution', () {
    test('resolves a step by source location', () {
      final index = LinkIndex.build(_remoteCourse());

      final target = index.resolve('section_02/unit_01/step_02');
      expect(target, isNotNull);
      expect(target!.url, '/lesson/2489641/step/2?unit=2527488');
      expect(target.isRemote, isTrue);
    });

    test('accepts unpadded positions', () {
      final index = LinkIndex.build(_remoteCourse());

      expect(
        index.resolve('section_2/unit_1/step_2')?.url,
        index.resolve('section_02/unit_01/step_02')?.url,
      );
    });

    test('a location without a step points at the first step', () {
      final index = LinkIndex.build(_remoteCourse());

      expect(
        index.resolve('section_01/unit_01')?.url,
        '/lesson/2489640/step/1?unit=2527487',
      );
    });

    test('resolves a step by label', () {
      final index = LinkIndex.build(_remoteCourse());

      expect(
        index.resolve('intro-variables')?.url,
        '/lesson/2489641/step/2?unit=2527488',
      );
    });

    test('returns null for unknown refs and malformed locations', () {
      final index = LinkIndex.build(_remoteCourse());

      expect(index.resolve('no-such-label'), isNull);
      expect(index.resolve('section_09/unit_01/step_01'), isNull);
      expect(index.resolve('section_01/unit_01/step_99'), isNull);
      expect(index.resolve('section_01/lesson_01/step_01'), isNull);
      expect(index.resolve(''), isNull);
    });

    test('a duplicated label resolves to nothing and is reported', () {
      final index = LinkIndex.build(
        _course([
          _section(
            position: 1,
            units: [
              _unit(
                position: 1,
                unitId: 1,
                lessonId: 2,
                steps: [
                  _step(1, label: 'dup'),
                  _step(2, label: 'dup'),
                ],
              ),
            ],
          ),
        ]),
      );

      expect(index.duplicateLabels, ['dup']);
      expect(index.resolve('dup'), isNull);
    });
  });

  group('LinkIndex synthetic ids', () {
    test('a never-pushed course resolves nothing without allowSynthetic', () {
      final index = LinkIndex.build(
        _course([
          _section(position: 1, units: [_unit(position: 1)]),
        ]),
      );

      expect(index.resolve('section_01/unit_01/step_01'), isNull);
    });

    test('allowSynthetic resolves and agrees with the preview URL', () {
      final course = _course([
        _section(position: 1, units: [_unit(position: 1)]),
      ]);

      final index = LinkIndex.build(course, allowSynthetic: true);
      final target = index.resolve('section_01/unit_01/step_02');
      expect(target, isNotNull);
      expect(target!.isRemote, isFalse);

      // The whole point of the shared id assignment: a ref resolved for the
      // preview must land on the URL the preview server actually serves.
      final preview = PreviewIndex.build(course);
      expect(target.url, preview.lessons.single.urlOfStep(2));
    });
  });

  group('ref link rendering', () {
    String render(String markdown, {LinkIndex? links}) =>
        const RenderRepository().renderMdText(markdown, links: links);

    test('rewrites a ref link to the stepik url', () {
      final html = render(
        'see [the intro](ref:section_02/unit_01/step_02)',
        links: LinkIndex.build(_remoteCourse()),
      );

      expect(html, contains('href="/lesson/2489641/step/2?unit=2527488"'));
      // The link text keeps whatever AutoItalicTransformer did to it.
      expect(html, contains('the intro'));
    });

    test('rewrites a label ref', () {
      final html = render(
        '[intro](ref:intro-variables)',
        links: LinkIndex.build(_remoteCourse()),
      );

      expect(html, contains('href="/lesson/2489641/step/2?unit=2527488"'));
    });

    test('leaves an unresolvable ref for validation to report', () {
      final html = render(
        '[nope](ref:no-such-label)',
        links: LinkIndex.build(_remoteCourse()),
      );

      expect(html, contains('href="ref:no-such-label"'));
    });

    test('leaves ordinary links alone', () {
      final html = render(
        '[stepik](https://stepik.org/course/1)',
        links: LinkIndex.build(_remoteCourse()),
      );

      expect(html, contains('href="https://stepik.org/course/1"'));
    });
  });
}

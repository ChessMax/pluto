import 'package:pluto/md/options_parser.dart';
import 'package:test/test.dart';

void main() {
  MdOptions parse(String source) => const OptionsParser().parse(source);

  test('Should report no section when there is none', () {
    final result = parse('Just a step body.');
    expect(result.options, isNull);
    expect(result.content, 'Just a step body.');
  });

  test('Should distinguish an empty section from a missing one', () {
    final result = parse('Body.\n\n## options\n');
    expect(result.options, isEmpty);
  });

  test('Should parse correctness from the checkbox', () {
    final result = parse('## options\n\n- [x] Paris\n- [ ] Lyon\n');
    expect(result.options?.map((o) => o.isCorrect), [true, false]);
    expect(result.options?.map((o) => o.text), ['Paris', 'Lyon']);
  });

  test('Should treat an uppercase X as correct', () {
    final result = parse('## options\n\n- [X] Paris\n');
    expect(result.options?.first.isCorrect, isTrue);
  });

  test('Should keep markdown in option text', () {
    final result = parse('## options\n\n- [x] The capital is **Paris**\n');
    expect(result.options?.first.text, 'The capital is **Paris**');
  });

  test('Should read blockquote lines as feedback', () {
    final result = parse(
      '## options\n\n- [x] Paris\n  > Capital since 987.\n- [ ] Lyon\n',
    );
    expect(result.options?[0].feedback, 'Capital since 987.');
    expect(result.options?[1].feedback, '');
  });

  test('Should join multi-line feedback', () {
    final result = parse('## options\n\n- [x] Paris\n  > One.\n  > Two.\n');
    expect(result.options?.first.feedback, 'One.\nTwo.');
  });

  test('Should continue option text across indented lines', () {
    final result = parse(
      '## options\n\n- [x] Which compile?\n\n  ```dart\n  final x = 1;\n  ```\n',
    );
    expect(
      result.options?.first.text,
      'Which compile?\n\n```dart\nfinal x = 1;\n```',
    );
  });

  test('Should strip the section from the content', () {
    final result = parse('Question?\n\n## options\n\n- [x] Yes\n');
    expect(result.content, 'Question?');
  });

  test('Should end the section at the next header', () {
    final result = parse(
      '## options\n\n- [x] Yes\n\n## notes\n\nAfter.\n',
    );
    expect(result.options?.length, 1);
    expect(result.content, '## notes\n\nAfter.');
  });

  test('Should reject an unindented non-option line', () {
    expect(
      () => parse('## options\n\n- [x] Yes\nstray\n'),
      throwsA(contains('line 4')),
    );
  });

  test('Should reject content before the first option', () {
    expect(
      () => parse('## options\n\n  stray\n- [x] Yes\n'),
      throwsA(contains('before the first option')),
    );
  });
}

import 'package:pluto/md/md_file.dart';
import 'package:pluto/md/md_parser.dart';
import 'package:test/test.dart';

void main() {
  MdFile parse(String source) => const MdParser().parse(source);

  group('Front matter', () {
    test('FM should be empty if there is no FM', () {
      final result = parse('*Hello*');
      expect(result.frontMatter.length, 0);
      expect(result.content, '*Hello*');
    });

    test('FM should be parsed', () {
      final result = parse('---\nid: 5\ntype: code\n---\n*Hello*');
      expect(result.frontMatter['id'], 5);
      expect(result.frontMatter['type'], 'code');
      expect(result.content, '*Hello*');
    });

    test('empty FM parses to no keys', () {
      final result = parse('---\n---\nBody');
      expect(result.frontMatter.length, 0);
      expect(result.content, 'Body');
    });

    test('unterminated FM is an error', () {
      expect(() => parse('---\nid: 5\nBody'), throwsA(isA<String>()));
    });
  });

  group('Code fences', () {
    test('Should return tests', () {
      final result = parse('*Hello*\n```tests\n1 2\n3\n```\n');
      expect(result.codes[0].lang, 'tests');
      expect(result.codes[0].content, '1 2\n3\n');
    });

    test('body keeps its fences — cutting one is the reader\'s choice', () {
      const body = '*Hello*\n```tests\n1 2\n3\n```\n';
      expect(parse(body).content, body);
    });

    test('contentWithout cuts the fence back out', () {
      final result = parse('Before.\n\n```dart\nvar x = 1;\n```\n\nAfter.\n');
      expect(
        result.contentWithout([result.getCode('dart')!]),
        'Before.\n\n\nAfter.\n',
      );
    });

    test('prose after a fence is kept', () {
      final result = parse('Before.\n\n```dart\nvar x = 1;\n```\n\nAfter.\n');
      expect(result.content, contains('After.'));
      expect(result.codes.length, 1);
    });

    test('several fences are all found, in order', () {
      final result = parse('```samples\na\n```\n\n```tests\nb\n```\n');
      expect(result.codes.map((c) => c.lang), ['samples', 'tests']);
      expect(result.getCodeContent('tests'), 'b\n');
    });

    test('an indented fence belongs to its list item, not to the file', () {
      final result = parse('- [x] Yes\n  > ```dart\n  > var x = 1;\n  > ```\n');
      expect(result.codes, isEmpty);
    });

    test('unterminated fence is an error', () {
      expect(() => parse('```dart\nvar x = 1;\n'), throwsA(isA<String>()));
    });
  });

  group('Line-anchored delimiters', () {
    test('--- inside a sentence is prose', () {
      const body = 'Everything below the `---` is Markdown.';
      final result = parse(body);
      expect(result.content, body);
    });

    test('a thematic break is prose', () {
      const body = 'One\n\n---\n\nTwo';
      final result = parse('---\nid: 1\n---\n$body');
      expect(result.content, body);
    });

    test('a table separator is prose', () {
      const body = '| A | B |\n| --- | --- |\n| 1 | 2 |\n';
      final result = parse(body);
      expect(result.content, body);
    });

    test('inline triple backticks are prose', () {
      const body = 'Write ```dart to open a fence.';
      final result = parse(body);
      expect(result.content, body);
      expect(result.codes, isEmpty);
    });
  });
}

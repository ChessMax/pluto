import 'package:pluto/md/front_matter.dart';
import 'package:pluto/md/md_document.dart';
import 'package:test/test.dart';

void main() {
  group('Splitting', () {
    test('Should read keys and body', () {
      final doc = MdDocument.parse('---\nid: 1\ntitle: Test\n---\nBody.\n');

      expect(doc.frontMatter['id'], 1);
      expect(doc.frontMatter['title'], 'Test');
      expect(doc.body, 'Body.\n');
    });

    test('Should treat a file without front matter as all body', () {
      final doc = MdDocument.parse('Just text.\n');

      expect(doc.frontMatter.values, isEmpty);
      expect(doc.body, 'Just text.\n');
    });

    test('Should not stop at a rule inside the body', () {
      final doc = MdDocument.parse('---\nid: 1\n---\nAbove\n\n---\n\nBelow\n');

      expect(doc.frontMatter['id'], 1);
      expect(doc.body, 'Above\n\n---\n\nBelow\n');
    });
  });

  group('Writing', () {
    test('Should keep comments, order and blank lines', () {
      final doc = MdDocument.parse(
        '---\n'
        '# title max 64 chars\n'
        'title: Old\n'
        '\n'
        'id: 1\n'
        '---\n',
      );

      expect(
        doc.write({'id': 1, 'title': 'New'}),
        '---\n'
        '# title max 64 chars\n'
        'title: New\n'
        '\n'
        'id: 1\n'
        '---\n',
      );
    });

    test('Should keep the author spelling of an unchanged value', () {
      final doc = MdDocument.parse('---\ntitle: "Test"\n---\n');

      expect(doc.write({'title': 'Test'}), '---\ntitle: "Test"\n---\n');
    });

    test('Should keep a key the format does not own', () {
      final doc = MdDocument.parse('---\nid: 1\nmine: keep\n---\n');

      expect(doc.write({'id': 2}), '---\nid: 2\nmine: keep\n---\n');
    });

    test('Should append a key the file does not have yet', () {
      final doc = MdDocument.parse('---\nid: 1\n---\n');

      expect(doc.write({'label': 'intro'}), '---\nid: 1\nlabel: intro\n---\n');
    });

    test('Should remove a key written as absent', () {
      final doc = MdDocument.parse('---\nid: 1\nlabel: intro\n---\n');

      expect(doc.write({'label': FrontMatter.absent}), '---\nid: 1\n---\n');
    });

    test('Should write a null value as an empty one', () {
      expect(MdDocument.empty.write({'id': null}), '---\nid:\n---\n');
    });

    test('Should replace a nested map with its own lines', () {
      final doc = MdDocument.parse(
        '---\nconfig:\n  a: 1\n  b: 2\nid: 1\n---\n',
      );

      expect(
        doc.write({
          'config': {'c': '3'},
        }),
        '---\nconfig:\n  c: 3\nid: 1\n---\n',
      );
    });

    test('Should drop an empty nested map', () {
      final doc = MdDocument.parse('---\nconfig:\n  a: 1\nid: 1\n---\n');

      expect(doc.write({'config': <String, String>{}}), '---\nid: 1\n---\n');
    });

    test('Should quote a value YAML would misread', () {
      final written = MdDocument.empty.write({'title': 'Read: the manual'});

      expect(written, "---\ntitle: 'Read: the manual'\n---\n");
      expect(
        MdDocument.parse(written).frontMatter['title'],
        'Read: the manual',
      );
    });

    test('Should preserve the body', () {
      final doc = MdDocument.parse('---\nid: 1\n---\n\nSome text.\n');

      expect(doc.write({'id': 2}), '---\nid: 2\n---\n\nSome text.\n');
    });

    test('Should be idempotent', () {
      const fields = {'id': 1, 'title': 'Test'};
      final once = MdDocument.empty.write(fields);
      final twice = MdDocument.parse(once).write(fields);

      expect(twice, once);
    });
  });
}

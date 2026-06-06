import 'package:pluto/md/md_file.dart';
import 'package:pluto/md/md_parser.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:test/test.dart';

void main() {
  MdFile parse(String source) =>
      const MdParser().parse(SourceView2(source));

  test('FM should be empty if there is no FM', (){
    final result = parse('*Hello*');
    expect(result.frontMatter.length, 0);
  });

  test('FM should be parsed', (){
    final result = parse('---\nid: 5\ntype: code\n---\n*Hello*');
    expect(result.frontMatter['id'], 5);
    expect(result.frontMatter['type'], 'code');
    expect(result.content, '*Hello*');
  });

  test('Should return tests', (){
    final result = parse('*Hello*\n```tests\n1 2\n3\n```\n');
    expect(result.content, '*Hello*\n');
    expect(result.codes[0].lang, 'tests');
    expect(result.codes[0].code, '1 2\n3\n');
  });
}
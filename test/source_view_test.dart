import 'package:pluto/template/lexer/source_view.dart';
import 'package:test/test.dart';

void main() {
  group('read char should work correct', () {
    test('read char should return char', () async {
      final sv = SourceView('source');
      final char = sv.readChar('s');
      expect(char, 's');
      expect(sv.toString(), 'ource');
    });

    test('read char should not return char', () async {
      final sv = SourceView('source');
      final char = sv.readChar('o');
      expect(char, null);
      expect(sv.toString(), 'source');
    });
  });

  group('read string should work correct', () {
    test('read string should return empty string', () async {
      final sv = SourceView('source');
      final actual = sv.readString('');
      expect(actual, '');
      expect(sv.toString(), 'source');
    });

    test('read string should not return string', () async {
      final sv = SourceView('source');
      final actual = sv.readString('o');
      expect(actual, null);
      expect(sv.toString(), 'source');
    });

    test('read string should return string', () async {
      final sv = SourceView('source');
      final actual = sv.readString('source');
      expect(actual, 'source');
      expect(sv.toString(), '');
    });

    test('read string should return string 2', () async {
      final sv = SourceView('source');
      final actual = sv.readString('source code');
      expect(actual, null);
      expect(sv.toString(), 'source');
    });

    test('read string should return string 3', () async {
      final sv = SourceView('source code');
      final actual1 = sv.readString('source');
      final actual2 = sv.readString(' ');
      expect(actual1, 'source');
      expect(actual2, ' ');
      expect(sv.toString(), 'code');
    });

    test('read string should return string 4', () async {
      final sv = SourceView('source code');
      final actual1 = sv.readString('source');
      final actual2 = sv.readString(' ');
      final actual3 = sv.readString('code');
      expect(actual1, 'source');
      expect(actual2, ' ');
      expect(actual3, 'code');
      expect(sv.toString(), '');
    });

    test('read string should return string 5', () async {
      final sv = SourceView('source');

      final actual1 = sv.readString('source');
      final actual2 = sv.readString('code');

      expect(actual1, 'source');
      expect(actual2, null);
      expect(sv.toString(), '');
    });

    test('read string should return string with extra', () async {
      final sv = SourceView('source code');
      final actual = sv.readString('source');
      expect(actual, 'source');
      expect(sv.toString(), ' code');
    });

    test('read string should not return string', () async {
      final sv = SourceView('source');
      final actual = sv.readString('field');
      expect(actual, null);
      expect(sv.toString(), 'source');
    });
  });

  group('read any should return correct values', () {
    test('should return null if input is empty', () {
      final sv = SourceView('source code');

      final actual = sv.readAny(const []);

      expect(actual, null);
      expect(sv.toString(), 'source code');
    });

    test('should return null if no values', () {
      final sv = SourceView('source code');

      final actual = sv.readAny(const ['field', 'bool', 'do']);

      expect(actual, null);
      expect(sv.toString(), 'source code');
    });

    test('should return value if there is values', () {
      final sv = SourceView('source code');

      final actual = sv.readAny(const ['code', 'source', 'do']);

      expect(actual, 'source');
      expect(sv.toString(), ' code');
    });
  });

  group('read identifier should return correct identifiers', () {
    test('should return null if input is empty', () {
      final sv = SourceView('5 source code');

      final actual = sv.readIdentifier();

      expect(actual, null);
      expect(sv.toString(), '5 source code');
    });

    test('should return identifier if there is an identifier', () {
      final sv = SourceView('source code');

      final actual = sv.readIdentifier();

      expect(actual, 'source');
      expect(sv.toString(), ' code');
    });

    test('should return identifier if there is an identifier 2', () {
      final sv = SourceView('_source code');

      final actual = sv.readIdentifier();

      expect(actual, '_source');
      expect(sv.toString(), ' code');
    });

    test('should return identifier if there is an identifier 3', () {
      final sv = SourceView('_source2 code');

      final actual = sv.readIdentifier();

      expect(actual, '_source2');
      expect(sv.toString(), ' code');
    });

    test('should return identifier if there is an identifier 4', () {
      final sv = SourceView('_source\$ code');

      final actual = sv.readIdentifier();

      expect(actual, '_source\$');
      expect(sv.toString(), ' code');
    });

    test('should return identifier if there is an identifier 5', () {
      final sv = SourceView('_source+ code');

      final actual = sv.readIdentifier();

      expect(actual, '_source');
      expect(sv.toString(), '+ code');
    });

    test('should consume id', () {
      final sv = SourceView('_source2');

      final actual = sv.readIdentifier();

      expect(actual, '_source2');
      expect(sv.toString(), '');
    });

    test('should return null if no values', () {
      final sv = SourceView('source code');

      final actual = sv.readAny(const ['field', 'bool', 'do']);

      expect(actual, null);
      expect(sv.toString(), 'source code');
    });

    test('should return value if there is values', () {
      final sv = SourceView('source code');

      final actual = sv.readAny(const ['code', 'source', 'do']);

      expect(actual, 'source');
      expect(sv.toString(), ' code');
    });
  });

  group('read white spaces should return correct values', () {
    test('should return white spaces', () {
      final sv = SourceView('  source');

      final actual = sv.readWhiteSpaces();

      expect(actual, '  ');
      expect(sv.toString(), 'source');
    });

    test('should return white spaces 2', () {
      final sv = SourceView('\t \n \r source');

      final actual = sv.readWhiteSpaces();

      expect(actual, '\t \n \r ');
      expect(sv.toString(), 'source');
    });

    test('should return null if there is no white spaces', () {
      final sv = SourceView('source');

      final actual = sv.readWhiteSpaces();

      expect(actual, null);
      expect(sv.toString(), 'source');
    });

    test('should return null if there is no white spaces 2', () {
      final sv = SourceView('source code');

      final actual = sv.readWhiteSpaces();

      expect(actual, null);
      expect(sv.toString(), 'source code');
    });

    test('should return null if there is no white spaces 3', () {
      final sv = SourceView('');

      final actual = sv.readWhiteSpaces();

      expect(actual, null);
      expect(sv.toString(), '');
    });
  });

  group('readWhile should return correct values', () {
    String? readText(SourceView source) {
      final text = source.readWhile(
            (source) => switch (source.peak()) {
          '<' => 0,
          '@' when source.peakNext() == '@' => 2,
          '@' => 0,
          _ => 1,
        },
      );
      return text;
    }

    final testCases = {
      '' : (null, ''),
      'Source code Hello world'              : ('Source code Hello world', ''),
      'Source code <div>Hello world</div>'   : ('Source code ', '<div>Hello world</div>'),
      'Source code @model.name.toString()'   : ('Source code ', '@model.name.toString()'),
      'Source code @@model.name.toString()'  : ('Source code @@model.name.toString()', ''),
      'Source code @@@model.name.toString()' : ('Source code @@', '@model.name.toString()'),
      'Source code @{var name = model.name}' : ('Source code ', '@{var name = model.name}'),
    };

    for (final MapEntry(: key, : value) in testCases.entries) {
      test('$key -> $value', (){
        final sv = SourceView(key);

        final actual = readText(sv);

        expect(actual, value.$1);
        expect(sv.toString(), value.$2);
      });
    }
  });

  group('readTag should return correct values', () {
    // <div>
    // <div id="header">
    // </div>
    // <br/>
    final testCases = {
      '<div>' : ('<div>', ''),
      '</div>' : ('</div>', ''),
      '<div id="header">' : ('<div id="header">', ''),
      '<br/>' : ('<br/>', ''),
      '<div>abc' : ('<div>', 'abc'),
      '</div>abc' : ('</div>', 'abc'),
      '<div id="header">abc' : ('<div id="header">', 'abc'),
      '<br/>abc' : ('<br/>', 'abc'),
    };

    for (final MapEntry(: key, : value) in testCases.entries) {
      test('$key -> $value', (){
        final sv = SourceView(key);

        final actual = sv.readTag();

        expect(actual.toString(), value.$1);
        expect(sv.toString(), value.$2);
      });
    }
  });

  group('readUntilAny should return correct values', (){
    test('Should return correct', (){
      final content = "Which variable could have `null` value?```options```";
      final sv = SourceView(content);
      final pos = sv.readUntilAny(const ['---', '```']);

      expect(pos, '```');
    });
  });
}

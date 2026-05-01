import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/lexer/text_lexer.dart';
import 'package:pluto/template/token.dart';

abstract interface class ModalLexer {
  Iterable<Token> tokenize(SourceView source);
}

class Lexer {
  @override
  Iterable<Token> tokenize(String value) sync* {
    final source = SourceView(value);
    yield* const TextLexer().tokenize(source);

    // assert(source.length <= 0, 'Expected all char consumed. But left: ${source.toString()}');
  }
}
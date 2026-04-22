import 'package:pluto/template/token.dart';

class Lexer {
  final String source;

  Lexer(this.source);

  bool _isAlpha(String value) {
    final code = value.codeUnitAt(0);
    return code >= 65 && code <= 90 || code >= 97 && code <= 122;
  }

  bool _isDigit(String value) {
    final code = value.codeUnitAt(0);
    return code >= '0'.codeUnitAt(0) && code <= '90'.codeUnitAt(0);
  }
  
  bool _isAlphaDigit(String value) {
    final code = value.codeUnitAt(0);
    return code >= 65 && code <= 90 || 
        code >= 97 && code <= 122 || 
        code >= '0'.codeUnitAt(0) && code <= '90'.codeUnitAt(0);
  }

  Iterable<Token> lex() sync* {
    int position = -1;
    String? nextChar() => source.length > position + 1 ? source[position + 1] : null;
    void consume() => ++position;
    bool isAtEnd() => position >= source.length;
    bool tryConsumeNext(String char) {
      if (source[position + 1] == char) {
        ++position;
        return true;
      }
      return false;
    }
    
    String? tryConsumeIdentifier() {
      final nc = nextChar();
      if (nc != null && _isAlpha(nc)) {
        int startPosition = ++position;
        
        while (!isAtEnd()) {
          final nc = nextChar();
          if (nc != null && _isAlphaDigit(nc)) {
            ++position;
          }
        }

        return source.substring(startPosition, position + 1);
      }
      return null;
    }

    while (++position < source.length) {
      final char = source[position];

      switch (char) {
        case '<': yield Token(type: .lt); break;
        case '>': yield Token(type: .gt); break;
        case '/': yield Token(type: .slash); break;
        case '.': yield Token(type: .dot); break;
        case '(': yield Token(type: .openParen); break;
        case ')': yield Token(type: .closeParen); break;
        case '@': yield Token(type: .at); break;
        default:
          if (char.isAlpha) {
            int startIndex = position;
            consume();
            while (!isAtEnd()) {
              final char = source[position];
              if (char.isAlphaNumeric) {
                ++position;
                continue;
              }
              break;
            }

            final identifier = source.substring(startIndex, position--);
            yield .new(type: .identifier, value: identifier);
          }
          
          // yield .new(type: .literal, );
          
          break;
      }
    }

    yield Token(type: .eof);
  }
}

  extension StringExt on String {
  bool get isDigit {
    if (length != 1) return false;
    final char = codeUnitAt(0);
    return char >= '0'.codeUnitAt(0) && char <= '9'.codeUnitAt(0);
  }

  bool get isAlpha {
    if (length != 1) return false;
    if (this == '_') return true;
    final char = codeUnitAt(0);
    return char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0) ||
        char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0);
  }

  bool get isAlphaNumeric => isAlpha || isDigit;
}
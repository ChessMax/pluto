import 'package:pluto/template/analyzer_lexer.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/token.dart';

import 'package:analyzer/dart/analysis/features.dart';
// import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/error/listener.dart';

class ImplicitExpressionLexer implements ModalLexer {
  const ImplicitExpressionLexer();

  @override
  Iterable<Token> tokenize(SourceView source) sync* {
    int? readImplicitExpr(String source) {
      final scanner = Scanner(
        source,
        DiagnosticReporter(
          DiagnosticListener.nullListener,
          StringSource(source, null),
        ),
      );
      scanner.configureFeatures(
        featureSetForOverriding: FeatureSet.latestLanguageVersion(),
        featureSet: FeatureSet.latestLanguageVersion(),
      );

      var depth = 0;
      var token = scanner.tokenize();

      if (token.type != .IDENTIFIER) {
        return null;
      }

      loop:
      while (token.type != .EOF) {
        final next = token.next!;
        switch (next.type) {
          case .PERIOD:
          case .COMMA:
          case .IDENTIFIER:
          case .OPEN_PAREN:
          case .CLOSE_PAREN:
          case .OPEN_SQUARE_BRACKET:
          case .CLOSE_SQUARE_BRACKET:
          case .STRING:
          case .STRING_INTERPOLATION_EXPRESSION:
          case .INT:
          case .DOUBLE:
          case .DOUBLE_WITH_SEPARATORS:
          case .INDEX:
            token = next;
            break;
          default:
            break loop;
        }
      }

      if (token.type == .PERIOD) {
        return token.previous!.end;
      }

      return token.end;
    }

    final end = readImplicitExpr(source.toString());
    if (end != null) {
      final token = Token(type: .expr, value: source.substring(0, end));
      source.consume(end);
      yield token;
      return;
    }
    throw 'Expected implicit expression';
  }
}
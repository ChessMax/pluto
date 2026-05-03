import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/token.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/token.dart' as ast;
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/error/listener.dart';

class ExplicitExpressionLexer {
  const ExplicitExpressionLexer();

  Iterable<Token> tokenize(SourceView source) sync* {
    print('Explicit expression lexer begin: ${source.toString()}');

    int? readExplicitExpr(String source) {
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

      while (token.type != .EOF) {
        // print("Token: ${token.lexeme} | Type: ${token.type}");

        if (token.type == .OPEN_PAREN) {
          depth++;
        } else if (token.type == .CLOSE_PAREN) {
          depth--;
        }

        if (depth == 0) {
          return token.charEnd;
        }

        token = token.next!;
      }

      return null;
    }


    final end = readExplicitExpr(source.toString());
    if (end != null) {
      final token = Token(type: .expr, value: source.substring(0, end));
      source.consume(end);
      yield token;
      print('Explicit expression lexer end: ${source.toString()}');
      return;
    }
    throw 'Expected explicit expression';
  }
}
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/token.dart' as ast;
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/error/listener.dart';


class AnalyzerLexer {
  const AnalyzerLexer();

  int? _consumeCode(String source, ast.TokenType open, ast.TokenType close) {
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

      if (token.type == open) {
        depth++;
      } else if (token.type == close) {
        depth--;
      }

      if (depth == 0) {
        return token.charEnd;//  source.substring(0, token.charEnd);
      }

      token = token.next!;
    }

    return null; //'';
  }

  int? readExpr(String source) =>
      _consumeCode(source, .OPEN_PAREN, .CLOSE_PAREN);

  int? readStatement(String source) =>
      _consumeCode(source, .OPEN_CURLY_BRACKET, .CLOSE_CURLY_BRACKET);
}
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/error/listener.dart';

class AnalyzerLexer {
  const AnalyzerLexer();

  int? _consumeCode(String source, TokenType open, TokenType close) {
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
        return token.charEnd;
      }

      token = token.next!;
    }

    return null;
  }

  int? readExpr(String source) =>
      _consumeCode(source, .OPEN_PAREN, .CLOSE_PAREN);

  int? readStmt(String source) {
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

      if (token.type == .OPEN_CURLY_BRACKET) {
        depth++;
      } else if (token.type == .CLOSE_CURLY_BRACKET) {
        depth--;
      }

      if (depth == 0) {
        return token.charEnd;
      }

      token = token.next!;
    }

    return null;
  }

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

    // while (token.type != .EOF) {
    //   // print("Token: ${token.lexeme} | Type: ${token.type}");
    //
    //   if (token.type == open) {
    //     depth++;
    //   } else if (token.type == close) {
    //     depth--;
    //   }
    //
    //   if (depth == 0) {
    //     return token.charEnd;
    //   }
    //
    //   token = token.next!;
    // }

    return null;
  }
}

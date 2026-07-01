import 'package:fpdart/fpdart.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/lexer/text_lexer.dart';
import 'package:pluto/template/token.dart';

import 'package:analyzer/dart/analysis/features.dart';

import 'package:analyzer/dart/ast/token.dart' as ast;
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/error/listener.dart';

class StatementLexer {
  const StatementLexer();

  Iterable<Token> tokenize(SourceView source) sync* {
    // print('Statement lexer begin: ${source.toString()}');
    Scanner createScanner(String value) {
      final scanner = Scanner(
        value,
        DiagnosticReporter(
          DiagnosticListener.nullListener,
          StringSource(value, null),
        ),
      );
      scanner.configureFeatures(
        featureSetForOverriding: FeatureSet.latestLanguageVersion(),
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      return scanner;
    }

    var scanner = createScanner(source.toString());

    Iterable<Token> consumeCode(ast.Token token) sync* {
      final statement = source.substring(0, token.end);
      if (statement.isNotEmpty) {
        yield Token(type: .stmt, value: statement);
        source.consume(token.end);
      }
    }

    var openCount = 0;

    var token = scanner.tokenize();
    while (token.type != .EOF) {
      if (token.type == .OPEN_CURLY_BRACKET) {
        openCount ++;
      } else if (token.type == .CLOSE_CURLY_BRACKET) {
        if (openCount == 0) {
          final statement = source.substring(0, token.offset);
          if (statement.isNotEmpty) {
            yield Token(type: .stmt, value: statement);
            source.consume(token.offset);
          }

          yield Token(type: .blockEnd);
          source.consume();
          return;
        }
        openCount --;
      } else
      if (token.type == .LT) {
        if (token.next case final tokenNext?
            when tokenNext.type == .IDENTIFIER) {
          if (tokenNext.next case final tokenNextNext?
              when tokenNextNext.type == .GT) {
            yield Token(
              type: .stmt,
              value: source.substring(0, token.offset),
            );
            source.consume(token.offset);

            yield* const TextLexer(topLevel: false).tokenize(source);

            scanner = createScanner(source.toString());
            token = scanner.tokenize();

            continue;
          }
        }
      }

      token = token.next!;
    }

    yield* consumeCode(token);

    // print('Statement lexer end: ${source.toString()}');
  }
}

import 'package:fpdart/fpdart.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/lexer/text_lexer.dart';
import 'package:pluto/template/token.dart';

import 'package:analyzer/dart/analysis/features.dart';

// import 'package:analyzer/dart/ast/token.dart' as analyzer;
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/error/listener.dart';

class StatementLexer implements ModalLexer {
  const StatementLexer();

  @override
  Iterable<Token> tokenize(SourceView source) sync* {
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

    var token = scanner.tokenize();
    while (token.type != .EOF) {
      if (token.type == .LT) {
        if (token.next case final tokenNext?
            when tokenNext.type == .IDENTIFIER) {
          if (tokenNext.next case final tokenNextNext?
              when tokenNextNext.type == .GT) {
            yield Token(
              type: .stmt,
              value: source.substring(0, token.previous!.end),
            );
            source.consume(token.previous!.end);

            yield* const TextLexer().tokenize(source);

            scanner = createScanner(source.toString());
            token = scanner.tokenize();

            continue;
          }
        }
      }

      token = token.next!;
    }

    yield Token(type: .stmt, value: source.substring(0, token.end));
    source.consume(token.end);
  }
}

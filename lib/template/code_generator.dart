
import 'package:pluto/template/node.dart';

class CodeGenerator {
  static const header =
'''
import 'dart:isolate';
import 'package:pluto/template/map_view.dart';

void main(List<String> args, dynamic message) {
  final replyTo = message[0] as SendPort;
  final model = message[1] is Map<String, dynamic> ? MapView(message[1] as Map<String, dynamic>) : message[1];
  String result = '';

''';

  static const footer =
'''
  replyTo.send(result);
}''';

  const CodeGenerator();

  String generate(Node node) {
    final tripleQuotes = "'''";
    final sb = StringBuffer(header);

    void writeNode(Node node) {
      switch (node) {
        case StatementNode():
          sb.writeln('  ${node.statement.replaceFirst('{', '').replaceLast('}', '')}');
          break;
        case ExpressionNode():
          sb.writeln('  result += ${node.expression}.toString();');
          break;
        case TextNode():
          final escaped = node.value.replaceAll("'''", "''' \"'''\" r'''\n");
          sb.writeln("  result += r'''\n$escaped''';");
          break;
        case DocumentNode():
          for (final childNode in node.children) {
            writeNode(childNode);
          }
          break;
        case BlockNode():
          for (final childNode in node.children) {
            writeNode(childNode);
          }
          break;
        case MarkupNode():
          for (final childNode in node.children) {
            writeNode(childNode);
          }
          break;
      }
    }

    writeNode(node);

    sb.write(footer);
    final result = sb.toString();

    print('```\n$result\n```');

    return result;
  }
}

extension on String {
  String replaceLast(String from, String to) {
    int lastIndex = lastIndexOf(from);
    if (lastIndex == -1) return this;
    return replaceFirst(from, to, lastIndex);
  }
}
import 'package:analyzer/dart/ast/ast.dart';
import 'package:pluto/template/node.dart';
import 'package:source_helper/source_helper.dart';

class CodeGenerator {
  static const header = '''
import 'dart:isolate';
import 'package:pluto/template/map_view.dart';

void main(List<String> args, dynamic message) {
  final replyTo = message[0] as SendPort;
  final model = message[1] is Map<String, dynamic> ? MapView(message[1] as Map<String, dynamic>) : message[1];
  String result = '';

''';

  static const footer = '''
  replyTo.send(result);
}''';

  const CodeGenerator();

  String generate(Node node) {
    final sb = StringBuffer(header);

    void writeNode(Node node, [Node? parent]) {
      switch (node) {
        case StatementNode():
          if (parent != null && parent is IfNode) {
            sb.write(' ${node.statement} ');
          } else {
            sb.writeln(
              '  ${node.statement.replaceFirst('{', '').replaceLast('}', '')}',
            );
          }

          break;
        case ExpressionNode():
          if (parent != null && parent is IfNode) {
            sb.write(node.expression);
          } else {
            sb.writeln('  result += ${node.expression}.toString();');
          }
          break;
        case IfNode():
          sb.write('  if ');
          writeNode(node.condition, node);
          sb.write(' { ');
          writeNode(node.ifStmt, node);
          sb.write(' } ');

          final elseStmt = node.elseStmt;
          if (elseStmt != null) {
            sb.writeln(' else { ');
            writeNode(elseStmt, node);
            sb.write(' } ');
          }
          break;
        case TextNode():
          final escaped = escapeDartString(node.value);
          sb.writeln("  result += $escaped;");
          break;
        case DocumentNode():
          for (final childNode in node.children) {
            writeNode(childNode);
          }
          break;
        case BlockNode():
          for (final childNode in node.children) {
            writeNode(childNode, parent);
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

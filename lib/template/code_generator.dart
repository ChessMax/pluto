import 'package:pluto/template/node.dart';

class CodeGenerator {
  String generate(Node node) {
    final sb = StringBuffer(
'''
import 'dart:isolate';

void main(List<String> args, dynamic message) {
  final replyTo = message[0] as SendPort;
  final model = message[1];
  String result = '';

''');

    void writeNode(Node node) {
      switch (node) {
        case ImplicitExpressionNode():
          sb.writeln('  result += ${node.expression}.toString();');
          break;
        case MarkupNode():
          sb.writeln('  result += \'${node.value}\';');
          break;
        case DocumentNode():
          for (final childNode in node.children) {
            writeNode(childNode);
          }
          break;
      }
    }

    writeNode(node);

    sb.writeln(
'''
  replyTo.send(result);
}''');
    return sb.toString();
  }
}
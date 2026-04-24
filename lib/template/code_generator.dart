
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
    final sb = StringBuffer(header);

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

    sb.write(footer);
    return sb.toString();
  }
}
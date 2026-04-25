sealed class Node {
  @override
  String toString();
}

class ImplicitExpressionNode extends Node {
  final String expression;

  ImplicitExpressionNode(this.expression);

  @override
  String toString() => '`$expression`';
}

class TextNode extends Node {
  final String value;

  TextNode(this.value);

  @override
  String toString() => value;
}

class DocumentNode extends Node {
  final List<Node> children;

  DocumentNode(this.children);

  @override
  String toString() => children.map((n) => n.toString()).join();
}
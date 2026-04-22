sealed class Node {
  @override
  String toString();
}

class ImplicitExpressionNode extends Node {
  final String expression;

  ImplicitExpressionNode(this.expression);

  @override
  String toString() => expression;
}

class MarkupNode extends Node {
  final String value;

  MarkupNode(this.value);

  @override
  String toString() => value;
}

class DocumentNode extends Node {
  final List<Node> children;

  DocumentNode(this.children);

  @override
  String toString() => children.map((n) => n.toString()).join();
}
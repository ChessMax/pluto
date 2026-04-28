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

class ExplicitExpressionNode extends Node {
  final String expression;

  ExplicitExpressionNode(this.expression);

  @override
  String toString() => '`$expression`';
}

class StatementExpressionNode extends Node {
  final String statement;

  StatementExpressionNode(this.statement);

  @override
  String toString() => '```$statement```';
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
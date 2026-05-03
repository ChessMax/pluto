sealed class Node {
  @override
  String toString();
}

class ExpressionNode extends Node {
  final String expression;

  ExpressionNode(this.expression);

  @override
  String toString() => '`$expression`';
}

class StatementNode extends Node {
  final String statement;

  StatementNode(this.statement);

  @override
  String toString() => '```$statement```';
}

class BlockNode extends Node {
  final List<Node> children;

  BlockNode(this.children);

  @override
  String toString() => '@{${ children.map((n) => n.toString()).join() }}';
}

class MarkupNode extends Node {
  final List<Node> children;

  MarkupNode(this.children);

  @override
  String toString() => children.map((n) => n.toString()).join();
}

class TextNode extends Node {
  final String value;

  TextNode(this.value);

  @override
  String toString() => value;
}

class IfNode extends Node {
  final Node condition;
  final Node ifStmt;
  final Node? elseStmt;

  IfNode(this.condition, this.ifStmt, this.elseStmt);

  @override
  String toString() {
    final elseStmt = this.elseStmt;
    return elseStmt != null ? 'if $condition $ifStmt else $elseStmt' : 'if $condition $ifStmt';
  }
}

class DocumentNode extends Node {
  final List<Node> children;

  DocumentNode(this.children);

  @override
  String toString() => children.map((n) => n.toString()).join();
}
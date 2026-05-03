class SourceView {
  final String source;
  int position;

  SourceView(this.source, [this.position = 0]);

  int get length => source.length - position;

  bool get isEmpty => length <= 0;

  bool get isNotEmpty => length > 0;

  int indexOf(Pattern pattern, [int start = 0]) =>
      switch (source.indexOf(pattern, start + position)) {
        -1 => -1,
        final index => index - position,
      };

  String operator [](int index) => source[position + index];

  String? peak() => position < source.length ? source[position] : null;

  String? peakNext([int value = 1]) =>
      position + value < source.length ? source[position + value] : null;

  void consume([int value = 1]) => position += value;

  String? tryConsumeChar(String value) {
    assert(value.length == 1);

    final char = peak();
    if (char != null && char == value) {
      consume();
      return char;
    }
    return null;
  }

  String consumeChar(String value) {
    return tryConsumeChar(value) ?? (throw 'Expected $value, but not found');
  }

  String? tryConsumeString(String value) {
    if (value.length > length) {
      return null;
    }

    for (var i = 0; i < value.length; ++i) {
      if (tryConsumeChar(value[i]) == null) {
        return null;
      }
    }

    return value;
  }

  String? tryConsume() {
    final result = peak();
    if (result != null) {
      consume();
      return result;
    }
    return null;
  }

  String consumeWhiteSpaces() {
    final start = position;

    for (
      var char = peak();
      char?.isWhiteSpace == true;
      ++position, char = peak()
    ) {}

    if (position > start) {
      return source.substring(start, position);
    }
    return '';
  }

  String substring(int start, [int? end]) =>
      source.substring(position + start, end != null ? position + end : null);

  @override
  String toString() {
    if (position < source.length) {
      return source.substring(position);
    }
    return '';
  }
}

extension on String {
  bool operator <=(String other) => codeUnitAt(0) <= other.codeUnitAt(0);

  bool operator >=(String other) => codeUnitAt(0) >= other.codeUnitAt(0);

  bool get isDigit => this >= '0' && this <= '9';

  bool get isAlpha => this >= 'a' && this <= 'z' || this >= 'A' && this <= 'Z';

  bool get isIdentifierStart => isAlpha || this == '_' || this == '\$';

  bool get isIdentifierContinue => isIdentifierStart || isDigit;

  bool get isWhiteSpace =>
      this == ' ' || this == '\n' || this == '\t' || this == '\r';
}

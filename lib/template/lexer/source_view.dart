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

  String? tryConsume() {
    final result = peak();
    if (result != null) {
      consume();
      return result;
    }
    return null;
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

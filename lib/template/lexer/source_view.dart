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

  String? peak([int offset = 0]) =>
      position + offset < source.length ? source[position + offset] : null;

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

extension SourceViewExtension on SourceView {
  String? tryConsumeIdentifier([int position = 0]) {
    var start = position;
    var char = peak(position);
    if (char != null && char.isIdentifierStart) {
      int p;
      for (p = position + 1; peakNext(p)?.isIdentifierContinue == true; ++p) {}
      var id = substring(start, p);
      consume(p - start);
      return id;
    }
    return null;
  }

  String consumeIdentifier() {
    final id = tryConsumeIdentifier();
    return id ?? (throw 'Expected identifier');
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

enum TagType { opening, closing, selfClosing }

class Tag {
  final String name;
  final TagType type;
  final List<({String key, String value})>? attributes;
  final String? content;

  Tag({required this.name, required this.type, this.attributes, this.content});

  @override
  String toString() {
    return switch (type) {
      .opening when attributes != null =>
        '<$name ${attributes!.map((a) => '${a.key}="${a.value}"').join(' ')}>',
      .opening => '<$name>',
      .selfClosing => '<$name/>',
      .closing => '</$name>',
    };
  }
}

class SourceView2 {
  final String source;
  int _position = 0;
  late String c = source.isNotEmpty ? source[0] : '';

  SourceView2(this.source);

  int get position => _position;

  set position(int value) {
    _position = value;
    c = value < source.length ? source[value] : '';
  }

  bool get isEmpty => position >= source.length;

  bool get isNotEmpty => position < source.length;

  void consume([int value = 1]) => position += value;

  String? peak() => position < source.length ? source[position] : null;

  String? peakNext() =>
      position + 1 < source.length ? source[position + 1] : null;

  String? peakNextNext() =>
      position + 2 < source.length ? source[position + 2] : null;

  String? readChar(String value) {
    assert(value.length == 1);

    if (peak() == value) {
      ++position;
      return value;
    }

    return null;
  }

  String? readString(String value) {
    final start = position;
    for (var i = 0; i < value.length; ++i) {
      if (readChar(value[i]) == null) {
        position = start;
        return null;
      }
    }

    return value;
  }

  bool startsWith(String value) {
    if (position + value.length >= source.length) return false;

    for (var i = 0; i < value.length; ++i) {
      if (source[position + i] != value[i]) {
        return false;
      }
    }

    return true;
  }

  bool startsWithAny(List<String> values) {
    for (final value in values) {
      if (!startsWith(value)) {
        return false;
      }
    }

    return true;
  }

  int? readPositionUntilChar(String value) {
    assert(value.length == 1);

    final start = position;

    while (position < source.length && source[position] != value) {
      position++;
    }

    if (position < source.length && source[position] == value) {
      return position;
    }

    position = start;
    return null;
  }

  String? readUntilChar(String value) {
    assert(value.length == 1);

    final start = position;
    final end = readPositionUntilChar(value);
    if (end != null) {
      return source.substring(start, end);
    }

    position = start;
    return null;
  }

  String? readUntilString(String value) {
    final start = position;

    do {
      final prefixPosition = readPositionUntilChar(value[0]);
      if (prefixPosition != null) {
        if (readString(value) == value) {
          position = prefixPosition;
          final result = source.substring(start, prefixPosition);
          return result;
        } else {
          position += 1;
        }
      } else {
        break;
      }
    } while (isNotEmpty);

    position = start;
    return null;
  }

  String? readUntilAny(List<String> values) {
    final start = position;

    for (final value in values) {
      if (readUntilString(value) != null) {
        // position -= value.length;
        return value;
      }
    }

    position = start;
    return null;
  }

  String? readUntilAnyExcept(List<String> values, List<String> exceptions) {
    final start = position;

    for (final value in values) {
      if (readUntilString(value) != null) {
        // position -= value.length;
        return value;
      }
    }

    position = start;
    return null;
  }

  String? readWhiteSpaces() {
    final start = position;

    while (position < source.length && source[position].isWhiteSpace) {
      position++;
    }

    return (position > start) ? source.substring(start, position) : null;
  }

  String? readWhile(int Function(SourceView2 source) predicate) {
    final start = position;

    // while (position < source.length && predicate(this)) {
    //   ++position;
    // }
    while (position < source.length) {
      final offset = predicate(this);
      if (offset <= 0) break;
      position += offset;
    }

    return (position > start) ? source.substring(start, position) : null;
  }

  String? readIdentifier() {
    final start = position;

    if (position < source.length && source[position].isIdentifierStart) {
      ++position;
    } else {
      return null;
    }

    while (position < source.length && source[position].isIdentifierContinue) {
      ++position;
    }

    return (position > start) ? source.substring(start, position) : null;
  }

  String? readAny(List<String> values) {
    for (final value in values) {
      final result = readString(value);
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  // <div id="myId">
  // String? readTag() {
  //   final start = position;
  //
  //   if (readChar('<') != null) {
  //     if (readString('div') != null) {
  //       if (readWhiteSpaces() != null) {
  //         final attribute = readIdentifier();
  //         if (attribute != null) {
  //           if (readChar('=') != null) {
  //             if (readChar('"') != null) {
  //               final value = readIdentifier();
  //               if (value != null) {
  //                 if (readChar('"') != null) {
  //                   if (readChar('>') != null) {
  //                     return '<div $attribute=$value>';
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //   }
  //
  //   position = start;
  //   return null;
  // }

  String consumeRest() {
    final result = toString();
    consume(result.length);
    return result;
  }

  String consumeChar(String value) {
    return readChar(value) ?? (throw 'Expected `$value` char');
  }

  String consumeString(String value) {
    return readString(value) ?? (throw 'Expected `$value` string');
  }

  String consumeWhiteSpaces() {
    return readWhiteSpaces() ?? '';
  }

  String consumeIdentifier() {
    return readIdentifier() ?? (throw 'Expected identifier');
  }

  String substring(int start, [int? end]) =>
      source.substring(position + start, end != null ? position + end : null);

  @override
  String toString() =>
      position < source.length ? source.substring(position) : '';
}

extension SourceView2Extension on SourceView2 {
  // <div>
  // <div id="header"></div>
  // <br/>
  Tag? readTag() {
    // < already consumed
    final source = this;
    // if (source.readChar('<') == null) return null;
    if (source.readChar('/') != null) {
      final name = source.readIdentifier();
      if (name == null) return null;
      if (source.readChar('>') == null) return null;
      return Tag(name: name, type: .closing);
    }
    final name = source.readIdentifier();

    if (name == null) return null;
    source.readWhiteSpaces();

    final attribute = source.readIdentifier();
    if (attribute != null) {
      if (source.readChar('=') == null) return null;
      if (source.readChar('"') == null) return null;
      final value = source.readIdentifier();
      if (value == null) return null;
      if (source.readChar('"') == null) return null;
      if (source.readChar('>') == null) return null;
      return Tag(
        name: name,
        type: .opening,
        attributes: [(key: attribute, value: value)],
      );
    }
    if (source.readChar('/') != null) {
      if (source.readChar('>') == null) return null;
      return Tag(name: name, type: .selfClosing);
    }

    if (source.readChar('>') == null) return null;
    return Tag(name: name, type: .opening);
  }
}

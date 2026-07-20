import 'package:pluto/extensions/string_extensions.dart';

/// One answer option, as written in a step's `## options` section.
///
/// Kept free of `lib/domain` so the markdown layer stays independent of the
/// authoring model; `SourceRepository` maps this to `ChoiceOption`.
class MdOption {
  final bool isCorrect;

  final String text;

  final String feedback;

  const MdOption({
    required this.isCorrect,
    required this.text,
    required this.feedback,
  });
}

/// A step's markdown body with its `## options` section lifted out.
class MdOptions {
  /// [source] with the options section removed, so it can be rendered as the
  /// step's text without the answers showing up in it.
  final String content;

  /// Null when the source had no options section at all — distinct from an
  /// empty list, which means the section was present but held no options.
  final List<MdOption>? options;

  const MdOptions({required this.content, required this.options});
}

/// Parses the checkbox-list options section:
///
/// ```md
/// ## options
///
/// - [x] The capital is **Paris**
///   > Right — capital since 987.
/// - [ ] Lyon
/// ```
///
/// A `- [x]`/`- [ ]` item opens an option. Lines indented under it continue its
/// text, except `>` blockquote lines, which are its feedback. Both stay plain
/// markdown, so option text can hold anything a step body can — including code
/// fences.
class OptionsParser {
  static final _headerRegExp = RegExp(r'^##[ \t]+options[ \t]*$');
  static final _otherHeaderRegExp = RegExp(r'^##[^#]');
  static final _optionRegExp = RegExp(r'^-[ \t]+\[([ xX])\][ \t]?(.*)$');
  static final _indentRegExp = RegExp(r'^[ \t]+');
  static final _quoteRegExp = RegExp(r'^>[ \t]?');

  const OptionsParser();

  MdOptions parse(String source) {
    final lines = source.splitByLines();

    final start = lines.indexWhere(_headerRegExp.hasMatch);
    if (start == -1) {
      return MdOptions(content: source, options: null);
    }

    var end = lines.length;
    for (var i = start + 1; i < lines.length; i++) {
      if (_otherHeaderRegExp.hasMatch(lines[i])) {
        end = i;
        break;
      }
    }

    final options = _parseOptions(lines, start + 1, end);

    final content = [
      ...lines.take(start),
      ...lines.skip(end),
    ].join('\n').trim();

    return MdOptions(content: content, options: options);
  }

  List<MdOption> _parseOptions(List<String> lines, int start, int end) {
    final options = <MdOption>[];

    var isCorrect = false;
    var text = <String>[];
    var feedback = <String>[];
    var isOpen = false;

    void flush() {
      if (!isOpen) return;
      options.add(
        MdOption(
          isCorrect: isCorrect,
          text: text.join('\n').trim(),
          feedback: feedback.join('\n').trim(),
        ),
      );
      text = <String>[];
      feedback = <String>[];
      isOpen = false;
    }

    for (var i = start; i < end; i++) {
      final line = lines[i];
      // Line numbers are 1-based and absolute, so parse errors can be reported
      // as a `path:line` an IDE console will linkify.
      final number = i + 1;

      final option = _optionRegExp.firstMatch(line);
      if (option != null) {
        flush();
        isOpen = true;
        isCorrect = switch (option.group(1)) {
          'x' || 'X' => true,
          _ => false,
        };
        text.add(option.group(2) ?? '');
        continue;
      }

      if (line.trim().isEmpty) {
        if (isOpen) {
          text.add('');
        }
        continue;
      }

      final indent = _indentRegExp.firstMatch(line);
      if (indent == null) {
        throw 'Unindented line $number in options section is not an option: '
            '`$line`. Options start with `- [ ]` or `- [x]`.';
      }
      if (!isOpen) {
        throw 'Indented line $number appears before the first option: `$line`.';
      }

      final rest = line.substring(indent.end);
      final quote = _quoteRegExp.firstMatch(rest);
      if (quote != null) {
        feedback.add(rest.substring(quote.end));
      } else {
        text.add(rest);
      }
    }

    flush();

    return options;
  }
}

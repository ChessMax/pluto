import 'package:pluto/domain/step.dart';
import 'package:pluto/extensions/string_extensions.dart';
import 'package:pluto/md/front_matter.dart';
import 'package:pluto/md/md_document.dart';
import 'package:pluto/md/md_parser.dart';
import 'package:pluto/md/options_parser.dart';
import 'package:pluto/template/lexer/source_view.dart';

/// The `step_NN.md` format: front matter, the author's markdown, and — by step
/// type — a `## options` section or `samples`/`tests`/`dart` fences.
///
/// Reading goes through [MdParser] rather than [MdDocument] because a step body
/// is the one body with structure in it; writing goes through [MdDocument] so
/// the front matter an author annotated survives.
class StepFormat {
  const StepFormat();

  /// Keys owned by one step type or another. Every write names all of them, so
  /// changing a step's type does not strand a flag that no longer applies.
  static const _typeFields = <String, Object?>{
    'is_always_correct': FrontMatter.absent,
    'preserve_order': FrontMatter.absent,
    'is_html_enabled': FrontMatter.absent,
    'manual_scoring': FrontMatter.absent,
    'is_attachments_enabled': FrontMatter.absent,
  };

  Step read(String source, {required int position}) {
    final md = const MdParser().parse(SourceView(source));
    final fm = md.frontMatter;

    final id = fm['id'] as int?;
    final label = fm['label'] as String?;

    /// The `## options` section, lifted out of the body so the answers are not
    /// rendered as part of the question.
    final choice = const OptionsParser().parse(md.content.trim());

    return switch (fm['type']) {
      'text' => TextStep(
        id: id,
        position: position,
        text: md.content.trim(),
        label: label,
      ),
      'single_choice' || 'multiple_choice' => ChoiceStep(
        id: id,
        position: position,
        text: choice.content,
        label: label,
        isMultipleChoice: fm['type'] == 'multiple_choice',
        isAlwaysCorrect: _bool(fm, 'is_always_correct', or: false),
        preserveOrder: _bool(fm, 'preserve_order', or: false),
        isHtmlEnabled: _bool(fm, 'is_html_enabled', or: true),
        options: choice.options?.map(_toChoiceOption).toList() ?? const [],
      ),
      'code' => CodeStep(
        id: id,
        position: position,
        text: md.content.trim(),
        label: label,
        // The newline before the closing backticks belongs to the fence, not to
        // the code; keeping it would make the model differ from what a write of
        // that same model produces.
        code: (md.getCodeContent('dart') ?? '').trimRight(),
        tests: _readTestCases(md.getCodeContent('tests') ?? ''),
        samples: _readTestCases(md.getCodeContent('samples') ?? ''),
        samplesCount: 1, // TODO:
      ),
      'free_answer' => FreeAnswerStep(
        id: id,
        position: position,
        text: md.content.trim(),
        label: label,
        manualScoring: _bool(fm, 'manual_scoring', or: false),
        isAttachmentsEnabled: _bool(fm, 'is_attachments_enabled', or: false),
        isHtmlEnabled: _bool(fm, 'is_html_enabled', or: true),
      ),
      _ => throw 'Unexpected step source type: ${fm['type']}',
    };
  }

  String write(Step step, {MdDocument base = MdDocument.empty}) {
    final label = step.label;

    return base.write({
      'id': step.id,
      'label': label == null || label.isEmpty ? FrontMatter.absent : label,
      'type': switch (step) {
        TextStep() => 'text',
        CodeStep() => 'code',
        ChoiceStep(:final isMultipleChoice) =>
          isMultipleChoice ? 'multiple_choice' : 'single_choice',
        FreeAnswerStep() => 'free_answer',
      },
      ..._typeFields,
      ...switch (step) {
        TextStep() || CodeStep() => const <String, Object?>{},
        ChoiceStep() => {
          'is_always_correct': step.isAlwaysCorrect,
          'preserve_order': step.preserveOrder,
          'is_html_enabled': step.isHtmlEnabled,
        },
        FreeAnswerStep() => {
          'manual_scoring': step.manualScoring,
          'is_attachments_enabled': step.isAttachmentsEnabled,
          'is_html_enabled': step.isHtmlEnabled,
        },
      },
    }, body: _writeBody(step));
  }

  /// The body: a blank line after the front matter, the author's markdown, then
  /// whatever the step type appends. Each part ends in a newline, so a step with
  /// no text at all does not open with a run of blank lines.
  String _writeBody(Step step) {
    final sb = StringBuffer('\n');
    if (step.text.isNotEmpty) sb.writeln(step.text);

    switch (step) {
      case TextStep():
      case FreeAnswerStep():
        break;
      case ChoiceStep(:final options):
        sb.writeln();
        sb.writeln('## options');
        sb.writeln();
        for (final option in options) {
          final lines = option.text.splitByLines();
          sb.writeln(
            '- [${option.isCorrect ? 'x' : ' '}] ${lines.firstOrNull ?? ''}',
          );
          // Continuation lines carry the two-space indent that keeps them part
          // of the item; blank lines stay blank so trailing whitespace is not
          // written into the file.
          for (final line in lines.skip(1)) {
            sb.writeln(line.isEmpty ? '' : '  $line');
          }
          for (final line in option.feedback.splitByLines()) {
            sb.writeln('  > $line');
          }
        }
      case CodeStep(:final samples, :final tests, :final code):
        _writeFence(
          sb,
          'samples',
          [
            for (final sample in samples) ...[sample.input, sample.output],
          ].join('\n'),
        );
        _writeFence(
          sb,
          'tests',
          [
            for (final test in tests) ...[test.input, test.output],
          ].join('\n'),
        );
        _writeFence(sb, 'dart', code);
    }

    return sb.toString();
  }

  /// Fences are separated from the body — and from each other — by a blank
  /// line, so a body that does not end in a newline cannot glue itself to the
  /// opening backticks.
  void _writeFence(StringBuffer sb, String lang, String content) {
    sb.writeln();
    sb.writeln('```$lang');
    // The fence itself supplies the closing newline; a value that already ends
    // in one would otherwise leave a blank line before the backticks and grow
    // the file by a line on every write.
    if (content.trimRight().isNotEmpty) sb.writeln(content.trimRight());
    sb.writeln('```');
  }

  static ChoiceOption _toChoiceOption(MdOption option) => ChoiceOption(
    text: option.text,
    feedback: option.feedback,
    isCorrect: option.isCorrect,
  );

  static bool _bool(dynamic frontMatter, String key, {required bool or}) {
    return switch (frontMatter[key]) {
      true => true,
      false => false,
      null => or,
      final value => throw 'Unexpected step source $key value: $value',
    };
  }

  static List<TestCase> _readTestCases(String tests) {
    final lines = tests.splitByLines();
    if (lines.length % 2 != 0) throw 'Unbalanced input output tests';
    return [
      for (var i = 0; i < lines.length; i += 2)
        TestCase(input: lines[i], output: lines[i + 1]),
    ];
  }
}

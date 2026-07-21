import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/md/front_matter.dart';
import 'package:pluto/md/md_document.dart';

/// The `abbreviations.md` format: a file of nothing but front matter, every
/// top-level key a term.
///
/// Because the terms are the keys, this is the one format that cannot name what
/// it owns up front — it replaces the block wholesale, keeping only the
/// comments and blank lines around it.
class AbbreviationsFormat {
  const AbbreviationsFormat();

  Abbreviations read(MdDocument document) =>
      Abbreviations.fromYaml(document.frontMatter.values);

  /// Empty when nothing is declared — a course without acronyms gets no file at
  /// all, which is what the reader treats as absent anyway.
  String write(
    Abbreviations abbreviations, {
    MdDocument base = MdDocument.empty,
  }) {
    if (abbreviations.isEmpty) return '';

    return base.write({
      for (final key in base.frontMatter.values.keys) key: FrontMatter.absent,
      ...abbreviations.values,
    });
  }
}

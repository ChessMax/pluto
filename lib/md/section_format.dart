import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/md/front_matter.dart';
import 'package:pluto/md/md_document.dart';

/// The `section_NN.md` format: front matter only.
///
/// `position` is deliberately not a field: it comes from the `section_NN`
/// directory name, so writing it would let the two disagree.
class SectionFormat {
  const SectionFormat();

  Section read(
    MdDocument document, {
    required int position,
    required List<Unit> units,
  }) {
    final fm = document.frontMatter;
    return Section(
      id: fm['id'] as int?,
      position: position,
      units: units,
      title: fm['title'] as String,
      description: fm['description'] as String? ?? '',
    );
  }

  String write(Section section, {MdDocument base = MdDocument.empty}) {
    return base.write({
      'id': section.id,
      'title': section.title,
      'description': section.description.isEmpty
          ? FrontMatter.absent
          : section.description,
    });
  }
}

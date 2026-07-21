import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/unit.dart';
import 'package:pluto/md/md_document.dart';

/// The `unit_NN.md` format: front matter only.
///
/// `position` is deliberately not a field: it comes from the `unit_NN`
/// directory name, so writing it would let the two disagree.
class UnitFormat {
  const UnitFormat();

  Unit read(
    MdDocument document, {
    required int position,
    required Lesson lesson,
  }) {
    return Unit(
      id: document.frontMatter['id'] as int?,
      position: position,
      lesson: lesson,
    );
  }

  String write(Unit unit, {MdDocument base = MdDocument.empty}) {
    return base.write({'id': unit.id});
  }
}

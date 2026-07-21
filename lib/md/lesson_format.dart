import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/md/md_document.dart';

/// The `lesson_NN.md` format: front matter only. The lesson's steps are
/// separate `step_NN.md` files.
class LessonFormat {
  const LessonFormat();

  Lesson read(MdDocument document, {required List<Step> steps}) {
    final fm = document.frontMatter;
    return Lesson(
      id: fm['id'] as int?,
      title: fm['title'] as String,
      steps: steps,
    );
  }

  String write(Lesson lesson, {MdDocument base = MdDocument.empty}) {
    return base.write({'id': lesson.id, 'title': lesson.title});
  }
}

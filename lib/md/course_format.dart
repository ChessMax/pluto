import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/md/md_document.dart';

/// The `course.md` format: front matter only.
///
/// The course's prose fields are not in it — each lives in its own
/// `source/<field>.md`, because each is markdown an editor should preview and
/// an author should not have to escape. [proseFields] names them, so reading
/// and writing cannot drift apart.
class CourseFormat {
  const CourseFormat();

  static const List<String> proseFields = [
    'summary',
    'acquired_assets',
    'description',
    'target_audience',
    'requirements',
    'learning_format',
    'acquired_skills',
  ];

  /// The value each name in [proseFields] refers to.
  static String? prose(Course course, String field) => switch (field) {
    'summary' => course.summary,
    'acquired_assets' => course.acquiredAssets,
    'description' => course.description,
    'target_audience' => course.targetAudience,
    'requirements' => course.requirements,
    'learning_format' => course.learningFormat,
    'acquired_skills' => course.acquiredSkills,
    _ => throw 'Unknown course field `$field`',
  };

  Course read(
    MdDocument document, {
    required List<Section> sections,
    required Map<String, String?> prose,
    required Abbreviations abbreviations,
  }) {
    final fm = document.frontMatter;
    return Course(
      id: fm['id'] as int?,
      title: fm['title'] as String,
      titleEn: fm['title_en'] as String?,
      sections: sections,
      summary: prose['summary'],
      acquiredAssets: prose['acquired_assets'],
      description: prose['description'],
      targetAudience: prose['target_audience'],
      requirements: prose['requirements'],
      learningFormat: prose['learning_format'],
      acquiredSkills: prose['acquired_skills'],
      config: CourseConfig.fromYaml(fm['config']),
      abbreviations: abbreviations,
    );
  }

  String write(Course course, {MdDocument base = MdDocument.empty}) {
    return base.write({
      'id': course.id,
      'title': course.title,
      'title_en': course.titleEn,
      'config': course.config.values,
    });
  }
}

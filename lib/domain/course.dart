import 'package:pluto/domain/section.dart';

class Course {
  final int? id;
  final String title;
  final String? titleEn;
  final List<Section> sections;

  final String? summary;
  final String? acquiredAssets;

  final String? description;
  final String? targetAudience;
  final String? requirements;
  final String? learningFormat;
  final String? acquiredSkills;

  Course({
    required this.id,
    required this.title,
    this.titleEn,
    this.sections = const [],
    this.summary,
    this.acquiredAssets,
    this.description,
    this.targetAudience,
    this.requirements,
    this.learningFormat,
    this.acquiredSkills,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEn': titleEn,
      'sections': sections.map((section) => section.toJson()).toList(),
      'summary': summary,
      'acquiredAssets': acquiredAssets,
      'description': description,
      'targetAudience': targetAudience,
      'requirements': requirements,
      'learningFormat': learningFormat,
      'acquiredSkills': acquiredSkills,
    };
  }
}

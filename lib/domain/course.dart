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

  Course copyWith({
    int? id,
    String? title,
    String? titleEn,
    List<Section>? sections,
    String? summary,
    String? acquiredAssets,
    String? description,
    String? targetAudience,
    String? requirements,
    String? learningFormat,
    String? acquiredSkills,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      sections: sections ?? this.sections,
      summary: summary ?? this.summary,
      acquiredAssets: acquiredAssets ?? this.acquiredAssets,
      description: description ?? this.description,
      targetAudience: targetAudience ?? this.targetAudience,
      requirements: requirements ?? this.requirements,
      learningFormat: learningFormat ?? this.learningFormat,
      acquiredSkills: acquiredSkills ?? this.acquiredSkills,
    );
  }

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

  Map<String, dynamic> toDto() {
    return {
      'id': id,
      'is_public': false,
      'is_enabled': false,

      'title': title,
      'titleEn': titleEn,

      'sections': [
        for (final section in sections)
          if (section.id != null) section.id,
      ],
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

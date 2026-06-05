import 'package:pluto/data/json.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';

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

  Map<String, dynamic> toDto([JsonObject? base]) {
    return {
      ...?base,
      if (id != null) 'id': id,
      'is_public': false,
      'is_enabled': false,

      'title': title,
      if (titleEn != null) 'title_en': titleEn,

      if (sections.any((section) => section.id != null))
        'sections': [
          for (final section in sections)
            if (section.id != null) section.id,
        ],
      // TODO:
      // 'summary': summary,
      if (acquiredAssets != null) 'acquired_assets': acquiredAssets,
      if (description != null) 'description': description,
      if (targetAudience != null) 'target_audience': targetAudience,
      if (requirements != null) 'requirements': requirements,
      if (learningFormat != null) 'learning_format': learningFormat,
      if (acquiredSkills != null) 'acquired_skills': acquiredSkills,
    };
  }

  Course copyWithSection(Section section, Section Function(Section) update) {
    return copyWith(
      sections: sections.replace(section, update),
    );
  }

  Section getSectionWithUnit(Unit unit) {
    for (var i = 0; i < sections.length; ++i) {
      final section = sections[i];
      final index = section.units.indexOf(unit);
      if (index != -1) {
        return section;
      }
    }

    throw 'Expected section not found';
  }

  (Section, Unit) getSectionAndUnitWithLesson(Lesson lesson) {
    for (var i = 0; i < sections.length; ++i) {
      final section = sections[i];

      for (var j = 0; j < section.units.length; ++j) {
        final unit = section.units[j];
        if (unit.lesson == lesson) {
          return (section, unit);
        }
      }
    }

    throw 'Expected section not found';
  }

  (Section, Unit) getSectionAndUnitWithStepSource(Step stepSource) {
    for (var i = 0; i < sections.length; ++i) {
      final section = sections[i];

      for (var j = 0; j < section.units.length; ++j) {
        final unit = section.units[j];
        for (var k=0;k<unit.lesson.steps.length;++k) {
          final step = unit.lesson.steps[k];
          if (step == stepSource) {
            return (section, unit);
          }
        }
      }
    }

    throw 'Expected section not found';
  }

  Course copyWithUnit(Unit unit, Unit Function(Unit) update) {
    final section = getSectionWithUnit(unit);

    return copyWithSection(
      section,
      (section) => section.copyWith(
        units: section.units.replace(unit, update),
      ),
    );
  }

  Course copyWithLesson(Lesson lesson, Lesson Function(Lesson) update) {
    final (section, unit) = getSectionAndUnitWithLesson(lesson);

    return copyWithUnit(
      unit,
      (unit) => unit.copyWith(
        lesson: update(lesson),
      ),
    );
  }

  Course copyWithStepSource(Step stepSource, Step Function(Step) update) {
    final (section, unit) = getSectionAndUnitWithStepSource(stepSource);

    return copyWithLesson(unit.lesson, (lesson) => lesson.copyWith(
      steps: lesson.steps.replace(stepSource, update),
    ));
  }
}

extension<T> on List<T> {
  List<T> replace(T item, T Function(T) replace) {
    final index = indexOf(item);
    return [
      for (var i = 0; i < index; ++i) this[i],
      replace(this[index]),
      for (var i = index + 1; i < length; ++i) this[i],
    ];
  }
}

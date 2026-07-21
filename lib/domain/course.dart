import 'package:pluto/data/json.dart';
import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/domain/lesson.dart';
import 'package:pluto/domain/section.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/unit.dart';

// TODO: additional class like CourseSource & Course or Course & RenderedCourse?
class Course {
  final int? id;
  final String title;
  final String? titleEn;
  final List<Section> sections;

  final String? summary;
  final String? summaryRendered;

  final String? acquiredAssets;

  final String? description;
  final String? targetAudience;
  final String? requirements;
  final String? learningFormat;
  final String? acquiredSkills;

  /// Author-defined values referenced from step Markdown as
  /// `{{config.<key>}}`. Local to the source; never pushed to Stepik.
  final CourseConfig config;

  /// Acronyms expanded to `<abbr>` when a step is rendered. Local to the
  /// source; never pushed to Stepik.
  final Abbreviations abbreviations;

  /// Whether the course is published on Stepik. A read-only mirror of the
  /// remote flag, filled in per run from the fetched course and used only to
  /// report state — it is deliberately absent from [toDto] and from the
  /// `course.md` template, so publication stays Stepik's to own and no local
  /// value can drift out of sync with it.
  final bool isPublic;

  Course({
    required this.id,
    required this.title,
    this.titleEn,
    this.sections = const [],
    this.config = CourseConfig.empty,
    this.abbreviations = Abbreviations.empty,
    this.isPublic = false,
    this.summary,
    this.summaryRendered,
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
    String? summaryRendered,
    String? acquiredAssets,
    String? description,
    String? targetAudience,
    String? requirements,
    String? learningFormat,
    String? acquiredSkills,
    CourseConfig? config,
    Abbreviations? abbreviations,
    bool? isPublic,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      sections: sections ?? this.sections,
      summary: summary ?? this.summary,
      summaryRendered: summaryRendered ?? this.summaryRendered,
      acquiredAssets: acquiredAssets ?? this.acquiredAssets,
      description: description ?? this.description,
      targetAudience: targetAudience ?? this.targetAudience,
      requirements: requirements ?? this.requirements,
      learningFormat: learningFormat ?? this.learningFormat,
      acquiredSkills: acquiredSkills ?? this.acquiredSkills,
      config: config ?? this.config,
      abbreviations: abbreviations ?? this.abbreviations,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  /// Model for the `course.md` template, which reads scalars only.
  ///
  /// Front matter only: the prose fields each live in their own
  /// `source/<field>.md`, written by `SourceRepository`.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEn': titleEn,
      // The template engine has no loops, so the block arrives pre-formatted.
      'configBlock': config.toFrontMatterBlock(),
    };
  }

  Map<String, dynamic> toDto([JsonObject? base]) {
    return {
      ...?base,
      if (id != null) 'id': id,
      // Omitting these publishes the course — Stepik reads an absent flag as
      // true. Always sent, always mirroring the remote value: pluto never
      // changes publication state, and an unknown state falls back to
      // unpublished rather than going live by accident.
      'is_public': base?['is_public'] ?? false,
      'is_enabled': base?['is_enabled'] ?? false,

      'title': title,
      if (titleEn != null) 'title_en': titleEn,

      if (sections.any((section) => section.id != null))
        'sections': [
          for (final section in sections)
            if (section.id != null) section.id,
        ],
      // TODO: use markdown to eliminate extra line breaks?
      'summary': summaryRendered ?? '',
      if (acquiredAssets != null) 'acquired_assets': _toLines(acquiredAssets),
      if (description != null) 'description': description,
      if (targetAudience != null) 'target_audience': targetAudience,
      if (requirements != null) 'requirements': requirements,
      if (learningFormat != null) 'learning_format': learningFormat,
      if (acquiredSkills != null) 'acquired_skills': _toLines(acquiredSkills),
    };
  }

  /// Stepik stores these fields as a list of bullet points, one per line.
  static List<String> _toLines(String? value) => [
    for (final line in (value ?? '').split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  Course copyWithSection(Section section, Section Function(Section) update) {
    return copyWith(
      sections: sections.replace(section, update),
    );
  }

  Course copyWithUnit(
    int sectionIndex,
    int unitIndex,
    Unit Function(Unit) update,
  ) {
    final section = sections[sectionIndex];
    final unit = section.units[unitIndex];

    return copyWithSection(
      section,
      (section) => section.copyWith(
        units: section.units.replace(unit, update),
      ),
    );
  }

  Course copyWithLesson(
    int sectionIndex,
    int unitIndex,
    Lesson Function(Lesson) update,
  ) {
    return copyWithUnit(
      sectionIndex,
      unitIndex,
      (unit) => unit.copyWith(
        lesson: update(unit.lesson),
      ),
    );
  }

  Course copyWithStep(
    int sectionIndex,
    int unitIndex,
    int stepIndex,
    Step Function(Step) update,
  ) {
    final section = sections[sectionIndex];
    final unit = section.units[unitIndex];
    final lesson = unit.lesson;
    final step = lesson.steps[stepIndex];

    return copyWithLesson(
      sectionIndex,
      unitIndex,
      (lesson) => lesson.copyWith(
        steps: lesson.steps.replace(step, update),
      ),
    );
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

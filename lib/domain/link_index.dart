import 'package:pluto/domain/course.dart';
import 'package:pluto/domain/course_ids.dart';

/// Scheme of an in-course link written in Markdown, e.g.
/// `[the intro](ref:section_01/unit_01/step_02)`.
const String refScheme = 'ref';

/// A step a `ref:` link points at.
class LinkTarget {
  final int lessonId;
  final int unitId;
  final int stepPosition;

  /// Whether the ids are real Stepik ids, i.e. whether [url] is valid on
  /// stepik.org rather than only inside the local preview.
  final bool isRemote;

  const LinkTarget({
    required this.lessonId,
    required this.unitId,
    required this.stepPosition,
    required this.isRemote,
  });

  /// Stepik's own URL shape, kept relative so it resolves against whichever
  /// origin serves it — stepik.org in a pushed course, the preview server
  /// locally. See [PreviewLesson.urlOfStep].
  String get url => '/lesson/$lessonId/step/$stepPosition?unit=$unitId';
}

/// Resolves `ref:` links to the steps they point at.
///
/// Two ways to name a step:
/// - by source location — `section_01/unit_01/step_02`, or
///   `section_01/unit_01` for the unit's first step;
/// - by label — `intro-variables`, declared as `label:` in the step's front
///   matter, which survives renumbering and moving the file.
class LinkIndex {
  final Map<String, LinkTarget> _byLocation;
  final Map<String, LinkTarget> _byLabel;

  /// Labels declared on more than one step; ambiguous, so they resolve to
  /// nothing and are reported by validation.
  final List<String> duplicateLabels;

  const LinkIndex._(this._byLocation, this._byLabel, this.duplicateLabels);

  LinkTarget? resolve(String ref) {
    final trimmed = ref.trim();
    if (trimmed.isEmpty) return null;

    final segments = trimmed.split('/');
    return switch (segments) {
      [final label] => _byLabel[label],
      [final section, final unit] => _lookup(section, unit, 1),
      [final section, final unit, final step] => switch (_stepPosition(step)) {
        final position? => _lookup(section, unit, position),
        null => null,
      },
      _ => null,
    };
  }

  LinkTarget? _lookup(String section, String unit, int stepPosition) {
    final location = parseUnitLocation(section, unit);
    if (location == null) return null;
    return _byLocation['$location/step_$stepPosition'];
  }

  static int? _stepPosition(String segment) {
    if (!segment.startsWith('step_')) return null;
    return int.tryParse(segment.substring(5));
  }

  /// Indexes every step of [course].
  ///
  /// With [allowSynthetic] the ids of a never-pushed unit are stood in for, so
  /// links work in preview before the course exists on Stepik. A push must
  /// leave it `false`: a synthetic id would render as a link to somebody else's
  /// lesson. Unresolvable refs are reported by validation rather than guessed at.
  static LinkIndex build(Course course, {bool allowSynthetic = false}) {
    final byLocation = <String, LinkTarget>{};
    final byLabel = <String, LinkTarget>{};
    final duplicateLabels = <String>[];

    final ids = assignUnitIds(course);
    var flatIndex = 0;

    for (final section in course.sections) {
      for (final unit in section.units) {
        final unitIds = ids[flatIndex++];
        if (!unitIds.isRemote && !allowSynthetic) continue;

        final location = unitLocationKey(section.position, unit.position);

        for (final step in unit.lesson.steps) {
          final target = LinkTarget(
            lessonId: unitIds.lessonId,
            unitId: unitIds.unitId,
            stepPosition: step.position,
            isRemote: unitIds.isRemote,
          );

          byLocation['$location/step_${step.position}'] = target;

          final label = step.label;
          if (label == null || label.isEmpty) continue;
          if (byLabel.containsKey(label)) {
            duplicateLabels.add(label);
          } else {
            byLabel[label] = target;
          }
        }
      }
    }

    for (final label in duplicateLabels) {
      byLabel.remove(label);
    }

    return LinkIndex._(byLocation, byLabel, duplicateLabels);
  }
}

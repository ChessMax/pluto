import 'package:pluto/domain/course.dart';

/// Ids of one unit and its lesson: the real Stepik ones when the source carries
/// them, stable synthetic stand-ins otherwise.
class UnitIds {
  final int lessonId;
  final int unitId;

  /// Whether both ids came from the source rather than being synthesised, which
  /// decides whether a URL built from them is valid on stepik.org.
  final bool isRemote;

  const UnitIds({
    required this.lessonId,
    required this.unitId,
    required this.isRemote,
  });
}

/// Location of a unit in the source tree, e.g. `section_1/unit_2`.
///
/// `Section.position` and `Unit.position` come from the directory names
/// (`section_NN`, `unit_NN`), so this identifies a unit without the model
/// having to carry its path. Positions are unpadded here; [parseUnitLocation]
/// normalises padded input to match.
String unitLocationKey(int sectionPosition, int unitPosition) =>
    'section_$sectionPosition/unit_$unitPosition';

/// Parses `section_NN/unit_NN` (padded or not) back into a [unitLocationKey].
String? parseUnitLocation(String sectionSegment, String unitSegment) {
  final section = _positionOf(sectionSegment, 'section');
  final unit = _positionOf(unitSegment, 'unit');
  if (section == null || unit == null) return null;
  return unitLocationKey(section, unit);
}

int? _positionOf(String segment, String prefix) {
  if (!segment.startsWith('${prefix}_')) return null;
  return int.tryParse(segment.substring(prefix.length + 1));
}

/// Assigns [UnitIds] to every unit of [course] in course order — the order a
/// flat `sections -> units` walk produces.
///
/// Everything that turns a unit into a URL must consume this one assignment:
/// preview routing and `ref:` link resolution have to agree, and the fallback
/// used on a synthetic-id collision depends on the order ids are claimed.
List<UnitIds> assignUnitIds(Course course) {
  final taken = <int>{};

  // Real ids are claimed up front, across the whole course, so a synthetic id
  // can never collide with a real one that appears later.
  for (final section in course.sections) {
    for (final unit in section.units) {
      final lessonId = unit.lesson.id;
      final unitId = unit.id;
      if (lessonId != null) taken.add(lessonId);
      if (unitId != null) taken.add(unitId);
    }
  }

  final result = <UnitIds>[];
  for (final section in course.sections) {
    for (final unit in section.units) {
      final key = unitLocationKey(section.position, unit.position);
      final lessonId = unit.lesson.id;
      final unitId = unit.id;

      result.add(
        UnitIds(
          lessonId: lessonId ?? _syntheticId('lesson:$key', taken),
          unitId: unitId ?? _syntheticId('unit:$key', taken),
          isRemote: lessonId != null && unitId != null,
        ),
      );
    }
  }

  return result;
}

/// A stable 7-digit id derived from [key], so URLs keep Stepik's shape before
/// the course has ever been pushed (ids in the source are null until a push
/// writes them back).
///
/// Deriving it from the source location rather than an ordinal keeps URLs valid
/// across edits and across inserting new sections; only renaming a directory
/// moves a lesson's URL, which is a real change of identity.
int _syntheticId(String key, Set<int> taken) {
  var id = _fnv1a(key);
  for (var salt = 0; !taken.add(id); ++salt) {
    id = _fnv1a('$key#$salt');
  }
  return id;
}

int _fnv1a(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  // Keep it in Stepik's visual range: a 7-digit number.
  return 1000000 + hash % 9000000;
}

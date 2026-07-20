import 'package:pluto/data/json.dart';
import 'package:pluto/domain/lesson.dart';

class Unit {
  final int? id;
  final int position;
  final Lesson lesson;

  // TODO: assignments?

  Unit({required this.id, required this.position, required this.lesson});

  Unit copyWith({
    int? id,
    int? position,
    Lesson? lesson,
  }) {
    return Unit(
      id: id ?? this.id,
      lesson: lesson ?? this.lesson,
      position: position ?? this.position,
    );
  }

  /// Model for the `unit_NN.md` template, which reads scalars only.
  ///
  /// [position] is deliberately absent: it is derived from the `unit_NN`
  /// directory name when read back, so writing it would let the two disagree.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  Map<String, dynamic> toDto(int sectionId, int? lessonId, [JsonObject? base]) {
    assert(position > 0);

    return {
      ...?base,
      if (id != null) 'id': id,
      'lesson': lessonId ?? lesson.id,
      'position': position,
      'section': sectionId,
    };
  }
}

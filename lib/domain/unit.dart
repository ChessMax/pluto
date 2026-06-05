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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson': lesson.toJson(),
      'position': position,
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

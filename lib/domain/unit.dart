import 'package:pluto/domain/lesson.dart';

class Unit {
  final int? id;
  final int position;
  final Lesson lesson;

  // TODO: assignments?

  Unit({required this.id, required this.position, required this.lesson});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson': lesson.toJson(),
      'position': position,
    };
  }

  Map<String, dynamic> toDto(int sectionId, [int? lessonId]) {
    return {
      'id': id,
      'lesson': lessonId ?? lesson.id,
      'position': position,
      'section': sectionId,
    };
  }
}

import 'package:pluto/data/json.dart';
import 'package:pluto/domain/step.dart';

// TODO: move somewhere and add check to validation process that it's correct
const maxStepsPerLesson = 16;

class Lesson {
  final int? id;
  final String title;
  final List<Step> steps;

  Lesson({required this.id, required this.title, required this.steps});

  Lesson copyWith({
    int? id,
    String? title,
    List<Step>? steps,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toDto([JsonObject? base]) {
    return {
      ...?base,
      if (id != null) 'id': id,
      'title': title,
      if (steps.any((step) => step.id != null))
        'steps': [
          for (final step in steps)
            if (step.id != null) step.id,
        ],
    };
  }
}

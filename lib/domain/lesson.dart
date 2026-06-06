import 'package:pluto/data/json.dart';
import 'package:pluto/domain/step_source.dart';

class Lesson {
  final int? id;
  final String title;
  final List<StepSource> steps;

  Lesson({required this.id, required this.title, required this.steps});

  Lesson copyWith({
    int? id,
    String? title,
    List<StepSource>? steps,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
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

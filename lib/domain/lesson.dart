import 'package:pluto/domain/step.dart';

class Lesson {
  final int? id;
  final String title;
  final List<Step> steps;

  Lesson({required this.id, required this.title, required this.steps});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  Map<String, dynamic> toDto() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'steps': [
        for (final step in steps)
          if (step.id != null) step.id,
      ],
    };
  }
}

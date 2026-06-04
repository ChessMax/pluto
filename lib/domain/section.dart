import 'package:pluto/data/json.dart';
import 'package:pluto/domain/unit.dart';

class Section {
  final int? id;
  final int position;
  final String title;
  final String description;
  final List<Unit> units;

  Section({
    required this.id,
    required this.position,
    required this.units,
    required this.description,
    required this.title,
  });

  Section copyWith({
    int? id,
    int? position,
    String? title,
    String? description,
    List<Unit>? units,
  }) {
    return Section(
      id: id ?? this.id,
      title: title ?? this.title,
      units: units ?? this.units,
      position: position ?? this.position,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'units': units.map((unit) => unit.toJson()).toList(),
      'position': position,
      'description': description,
    };
  }

  Map<String, dynamic> toDto(int courseId, [JsonObject? base]) {
    assert(position > 0);

    return {
      ...?base,
      if (id != null) 'id': id,
      'title': title,
      if (units.any((unit) => unit.id != null))
        'units': [
          for (final unit in units)
            if (unit.id != null) unit.id,
        ],
      'course': courseId,
      'position': position,
      if (description.isNotEmpty) 'description': description,
    };
  }
}

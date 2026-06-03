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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'units': units.map((unit) => unit.toJson()).toList(),
      'position': position,
      'description': description,
    };
  }

  Map<String, dynamic> toDto(int courseId) {
    return {
      if (id != null) 'id': id,
      'title': title,
      'units':[
        for (final unit in units) {
          if (unit.id != null) unit.id,
        }
      ],
      'courseId': courseId,
      'position': position,
      'description': description,
    };
  }
}

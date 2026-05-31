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
}

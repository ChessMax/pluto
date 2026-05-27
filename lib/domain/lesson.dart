import 'package:pluto/domain/step.dart';

class Lesson {
  final int? id;
  final String title;
  final List<Step> steps;

  Lesson({required this.id, required this.title, required this.steps});
}
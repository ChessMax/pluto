class Step {
  final int? id;
  final int position;
  final StepBlock block;

  Step({required this.id, required this.position, required this.block});
}

enum StepBlockType {
  text
  ;

  static StepBlockType parse(String value) =>
      StepBlockType.values.firstWhere((type) => type.name == value);
}

class StepBlock {
  final StepBlockType name;
  final String text;

  StepBlock({required this.name, required this.text});
}

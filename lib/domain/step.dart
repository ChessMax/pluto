class Step {
  final int? id;
  final int position;
  final StepBlock block;

  Step({required this.id, required this.position, required this.block});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position' : position,
      'block': block.toJson(),
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'name': name.name,
      'text' : text,
    };
  }
}

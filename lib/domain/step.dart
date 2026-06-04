// TODO: rename to stepSource??
import 'package:pluto/data/json.dart';

class Step {
  final int? id;
  final int position;
  final StepBlock block;

  Step({required this.id, required this.position, required this.block});

  Step copyWith({
    int? id,
    int? position,
    StepBlock? block,
  }) {
    return Step(
      id: id ?? this.id,
      block: block ?? this.block,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'block': block.toJson(),
    };
  }

  Map<String, dynamic> toDto(int lessonId, [JsonObject? base]) {
    assert(position > 0);

    return {
      ...?base,
      if (id != null) 'id': id,
      'position': position,
      'block': block.toDto(),
      'lesson': lessonId,
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
      'text': text,
    };
  }

  Map<String, dynamic> toDto() {
    return {
      'name': name.name,
      'text': text,
    };
  }
}

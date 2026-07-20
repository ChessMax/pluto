import 'package:pluto/commands/add/add_step_command.dart';
import 'package:pluto/domain/step.dart';

class AddTextStepCommand extends AddStepCommand {
  @override
  String get name => 'step';

  @override
  String get description => 'Adds a text step to a lesson.';

  @override
  String get defaultText => 'Source of your step';

  @override
  TextStep buildStep(String text, int position) =>
      TextStep(id: null, position: position, text: text);
}

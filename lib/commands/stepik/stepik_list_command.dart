import 'package:args/command_runner.dart';
import 'package:pluto/data/initialize_stepik_client.dart';

class StepikListCommand extends Command<void> {
  @override
  String get name => 'list';

  @override
  String get description => 'Lists stepik courses.';

  StepikListCommand();

  @override
  Future<void> run() async {
    final r = await initializeStepikClient();
    final api = r.api;

    print('Request course list: ');

    final courses = await api.course.fetch();

    for (final course in courses!) {
      print('Course [${course.id}]: ${course.title}');
    }
  }
}
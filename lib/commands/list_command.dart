import 'package:pluto/stepik_api/stepik_api.dart';

class ListCommand {
  final StepikApi _api;

  ListCommand({required StepikApi api}) : _api = api;

  Future<void> execute() async {
    print('Request course list: ');

    final courses = await _api.course.fetch();

    for (final course in courses!) {
      print('Course [${course.id}]: ${course.title}');
    }
  }
}
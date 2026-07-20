import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pluto/data/initialize_stepik_client.dart';
import 'package:pluto/data/source_repository.dart';
import 'package:pluto/domain/diff.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/markdown/render_repository.dart';
import 'package:pluto/domain/stepik_repository.dart';
import 'package:pluto/domain/validation_repository.dart';

class StatusCommand extends Command<void> {
  @override
  String get name => 'status';

  @override
  String get description => 'Shows course status';

  StatusCommand();

  @override
  Future<void> run() async {
    final courseDir = argResults!.rest.isNotEmpty
        ? argResults!.rest[0]
        : Directory.current.path;

    print('Evaluating course status: $courseDir');

    const sourceRepository = SourceRepository();

    final courseSource = await sourceRepository.readCourseSource(courseDir);
    final localCourse = courseSource.course;
    final courseId = localCourse.id;

    final rawApi = (await initializeStepikClient()).rawApi;
    final stepikRepository = StepikRepository(rawApi);

    final remoteCourse = courseId != null
        ? await stepikRepository.readCourse(courseId)
        : null;

    final diffs = Diff.create(remoteCourse, localCourse).toList();

    print('Course diff: ');
    diffs.dump();

    // report validation
    //
    // Synthetic ids are allowed: status answers "does this ref name a step that
    // exists", which holds before the course has ever been pushed. Whether the
    // target exists *remotely* is push's concern, and push rebuilds the index
    // without them.
    final links = LinkIndex.build(localCourse, allowSynthetic: true);
    final renderedCourse = const RenderRepository().render(
      localCourse,
      links: links,
    );
    final validation = const ValidationRepository().validate(
      renderedCourse,
      sources: courseSource.files,
      links: links,
    );
    if (validation.isValid) {
      print('HTML validation: OK');
    } else {
      print('HTML validation: ${validation.violations.length} issue(s):');
      for (final violation in validation.violations) {
        print('  - $violation');
      }
    }

    // Not errors here, but worth knowing about ahead of a push: links that only
    // resolve because status allows synthetic ids, and abbreviations declared
    // but never used.
    final warnings = validation.warnings;
    if (warnings.isNotEmpty) {
      print('Warnings: ${warnings.length}:');
      for (final warning in warnings) {
        print('  - $warning');
      }
    }

    // report markers (TODO/FIXME) with precise file:line:column locations.
    final markers = validation.markers;
    if (markers.isEmpty) {
      print('Markers: none');
    } else {
      print('Markers: ${markers.length} found:');
      for (final marker in markers) {
        print('  $marker');
      }
    }
  }
}

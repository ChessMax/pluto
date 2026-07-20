import 'dart:convert';

import 'package:pluto/domain/link_index.dart';
import 'package:pluto/domain/marker_scanner.dart';
import 'package:pluto/domain/step.dart';
import 'package:pluto/domain/validation_repository.dart';
import 'package:pluto/preview/preview_assets.dart';
import 'package:pluto/preview/preview_index.dart';

/// Renders the preview pages: the Stepik-like course chrome around one rendered
/// step, plus the standalone notice pages (404 / read failure).
class PreviewPage {
  static const _validation = ValidationRepository();
  static const _markers = MarkerScanner();

  const PreviewPage();

  String stepPage(PreviewIndex index, PreviewLesson lesson, int stepNumber) {
    final step = lesson.steps[stepNumber - 1];
    final course = index.course;

    return _document(
      title: '${lesson.lesson.title} — ${course.title}',
      body: [
        _topbar(index, lesson),
        '<div class="layout">',
        _sidebar(index, lesson),
        '<div class="content">',
        _lessonHead(lesson),
        _stepTabs(lesson, stepNumber),
        '<div class="card">',
        _diagnostics(step),
        _stepBody(step),
        '</div>',
        _pager(index, lesson, stepNumber),
        '</div></div>',
      ].join(),
    );
  }

  String notFoundPage(PreviewIndex index) {
    final entry = index.entryUrl;
    return _document(
      title: 'Not found',
      body:
          '<div class="notice">'
          '<h1>No such lesson or step</h1>'
          '<p>It may have been renumbered or renamed since this page was '
          'opened.</p>'
          '${entry != null ? '<p><a href="$entry">Go to the first step</a></p>' : ''}'
          '</div>',
    );
  }

  /// Shown instead of killing the server when the course fails to read or
  /// render, so a syntax slip in one file is a red page you can fix and watch
  /// recover rather than a dead process.
  String errorPage(Object error) {
    return _document(
      title: 'Course error',
      body:
          '<div class="notice">'
          '<h1>Could not read the course</h1>'
          '<pre>${_escape(error.toString())}</pre>'
          '<p>Fix the source and this page reloads by itself.</p>'
          '</div>',
    );
  }

  String emptyPage() {
    return _document(
      title: 'Empty course',
      body:
          '<div class="notice">'
          '<h1>This course has no steps yet</h1>'
          '<p>Add one with <code>pluto add section</code>, then this page '
          'reloads by itself.</p>'
          '</div>',
    );
  }

  String _document({required String title, required String body}) {
    return '<!doctype html>'
        '<html lang="en"><head>'
        '<meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        '<title>${_escape(title)}</title>'
        '<link rel="stylesheet" href="/assets/preview.css">'
        '</head><body>'
        '$body'
        '<script>${PreviewAssets.reloadScript}</script>'
        '</body></html>';
  }

  String _topbar(PreviewIndex index, PreviewLesson lesson) {
    // Flag preview-local ids so a URL that cannot be opened on stepik.org is
    // never mistaken for one that can.
    final badge = lesson.hasRemoteIds
        ? '<span class="badge">stepik ids</span>'
        : '<span class="badge">preview ids &middot; not yet pushed</span>';

    return '<div class="topbar">'
        '<span class="brand">pluto</span>'
        '<span class="course-title">${_escape(index.course.title)}</span>'
        '<span class="spacer"></span>'
        '$badge'
        '</div>';
  }

  String _sidebar(PreviewIndex index, PreviewLesson current) {
    final buffer = StringBuffer('<nav class="sidebar">');

    var sectionIndex = -1;
    for (final lesson in index.lessons) {
      if (lesson.sectionIndex != sectionIndex) {
        if (sectionIndex != -1) buffer.write('</div>');
        sectionIndex = lesson.sectionIndex;
        buffer
          ..write('<div class="section">')
          ..write(
            '<div class="section-title">'
            '${lesson.sectionIndex + 1}. ${_escape(lesson.section.title)}'
            '</div>',
          );
      }

      final isCurrent =
          lesson.lessonId == current.lessonId &&
          lesson.unitId == current.unitId;
      final stepCount = lesson.steps.length;

      buffer.write(
        '<a class="unit${isCurrent ? ' current' : ''}" '
        'href="${lesson.urlOfStep(1)}">'
        '<span class="num">${lesson.unitIndex + 1}</span>'
        '<span>${_escape(lesson.lesson.title)}'
        '<span class="steps"> · $stepCount step${stepCount == 1 ? '' : 's'}</span>'
        '</span></a>',
      );
    }

    if (sectionIndex != -1) buffer.write('</div>');
    buffer.write('</nav>');
    return buffer.toString();
  }

  String _lessonHead(PreviewLesson lesson) {
    return '<div class="lesson-head">'
        '<h1>${_escape(lesson.lesson.title)}</h1>'
        '<span class="crumb">${_escape(lesson.section.title)}</span>'
        '</div>';
  }

  String _stepTabs(PreviewLesson lesson, int current) {
    final buffer = StringBuffer('<div class="steps">');

    for (var i = 0; i < lesson.steps.length; ++i) {
      final number = i + 1;
      buffer.write(
        '<a class="step${number == current ? ' current' : ''}" '
        'href="${lesson.urlOfStep(number)}">'
        '<span class="icon">${_icon(lesson.steps[i])}</span>'
        '<span>$number</span></a>',
      );
    }

    buffer.write('</div>');
    return buffer.toString();
  }

  String _icon(Step step) => switch (step) {
    TextStep() => '&#8801;',
    CodeStep() => '{}',
    ChoiceStep(:final isMultipleChoice) =>
      isMultipleChoice ? '&#9745;' : '&#9673;',
    FreeAnswerStep() => '&#9998;',
  };

  String _stepBody(Step step) {
    final text = step.renderedText ?? '';

    return switch (step) {
      TextStep() => text,
      CodeStep(:final code) =>
        '$text<div class="quiz">'
            '<div class="quiz-title">Code template</div>'
            '<pre><code>${_escape(code)}</code></pre>'
            '</div>',
      ChoiceStep(:final options, :final isMultipleChoice) =>
        '$text${_choices(options, isMultipleChoice)}',
      FreeAnswerStep() =>
        '$text<div class="quiz">'
            '<div class="quiz-title">Free answer</div>'
            '<textarea disabled placeholder="Student answer"></textarea>'
            '</div>',
    };
  }

  String _choices(List<ChoiceOption> options, bool isMultiple) {
    final buffer = StringBuffer('<div class="quiz">')
      ..write(
        '<div class="quiz-title">'
        'Select ${isMultiple ? 'all correct options' : 'one option'}</div>',
      );

    for (final option in options) {
      // Sources spell "no feedback" as a bare quote pair rather than an empty
      // line, so rendering it verbatim would put a stray '' under every option.
      final feedback = option.feedback.trim();
      final hasFeedback = feedback.isNotEmpty && feedback != "''";

      buffer.write(
        '<div class="option${option.isCorrect ? ' correct' : ''}">'
        '<input type="${isMultiple ? 'checkbox' : 'radio'}" disabled'
        '${option.isCorrect ? ' checked' : ''}>'
        '<span>${_escape(option.text)}'
        '${hasFeedback ? '<span class="feedback">${_escape(feedback)}</span>' : ''}'
        '</span>'
        '${option.isCorrect ? '<span class="mark">&#10003;</span>' : ''}'
        '</div>',
      );
    }

    buffer.write('</div>');
    return buffer.toString();
  }

  /// HTML violations and reminder markers for this step, surfaced inline so
  /// they are caught while authoring rather than at push time.
  String _diagnostics(Step step) {
    final buffer = StringBuffer();

    final violations = _validation.validateHtml(
      step.renderedText,
      location: 'step ${step.position}',
    );

    // A `ref:` that survived rendering names no step, which is an authoring
    // mistake rather than bad HTML — reported apart so the fix is obvious.
    final brokenLinks = violations
        .where((v) => v.kind == .unresolvedLink)
        .toList();
    if (brokenLinks.isNotEmpty) {
      buffer.write(
        _banner(
          'error',
          'Broken links',
          brokenLinks.map(
            (v) =>
                '<code>${_escape('$refScheme:${v.detail}')}</code> '
                'matches no step in this course',
          ),
        ),
      );
    }

    final htmlViolations = violations
        .where((v) => v.kind != .unresolvedLink)
        .toList();
    if (htmlViolations.isNotEmpty) {
      buffer.write(
        _banner(
          'error',
          'Stepik will reject this HTML',
          htmlViolations.map((v) => _escape(v.toString())),
        ),
      );
    }

    // Scanned from this step's own raw text, which sidesteps needing a
    // step-to-source-file mapping the domain model does not carry.
    final markers = _markers.scanText(step.text, 'step');
    if (markers.isNotEmpty) {
      buffer.write(
        _banner(
          markers.any((m) => m.severity == .error) ? 'error' : 'warn',
          'Markers',
          markers.map(
            (m) =>
                '<code>${m.kind.keyword}</code> '
                '${_escape(m.message)} '
                '<span class="feedback">line ${m.location.line}</span>',
          ),
        ),
      );
    }

    return buffer.toString();
  }

  String _banner(String kind, String title, Iterable<String> items) {
    return '<div class="banner $kind">'
        '<div class="banner-title">${_escape(title)}</div>'
        '<ul>${items.map((item) => '<li>$item</li>').join()}</ul>'
        '</div>';
  }

  String _pager(PreviewIndex index, PreviewLesson lesson, int stepNumber) {
    String? previous;
    if (stepNumber > 1) {
      previous = lesson.urlOfStep(stepNumber - 1);
    } else {
      final before = index.lessonBefore(lesson);
      previous = before?.urlOfStep(before.steps.length);
    }

    String? next;
    if (stepNumber < lesson.steps.length) {
      next = lesson.urlOfStep(stepNumber + 1);
    } else {
      next = index.lessonAfter(lesson)?.urlOfStep(1);
    }

    return '<div class="pager">'
        '${previous != null ? '<a href="$previous">&larr; Previous</a>' : '<span>&larr; Previous</span>'}'
        '${next != null ? '<a href="$next">Next &rarr;</a>' : '<span>Next &rarr;</span>'}'
        '</div>';
  }

  String _escape(String value) => const HtmlEscape().convert(value);
}

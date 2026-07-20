/// Static assets served by the preview server. Kept as Dart strings so the
/// command works from a compiled `pluto` executable with no asset files beside
/// it.
abstract final class PreviewAssets {
  /// Styled after the stepik.org course view so the preview reads the same way
  /// the published course will.
  static const css = r'''
* { box-sizing: border-box; }

:root {
  --bg: #f5f6f8;
  --surface: #ffffff;
  --border: #e3e6e8;
  --text: #38434f;
  --muted: #8a949e;
  --accent: #4c9ee0;
  --accent-dark: #398bc8;
  --correct: #57a75a;
  --warn-bg: #fff8e6;
  --warn-border: #f0c674;
  --error-bg: #fdeded;
  --error-border: #e07a7a;
}

html, body {
  margin: 0;
  padding: 0;
  height: 100%;
}

body {
  background: var(--bg);
  color: var(--text);
  font: 15px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      Helvetica, Arial, sans-serif;
}

a { color: var(--accent-dark); text-decoration: none; }
a:hover { text-decoration: underline; }

/* header */

.topbar {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  gap: 12px;
  height: 52px;
  padding: 0 20px;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
}

.topbar .brand {
  font-weight: 700;
  color: var(--accent-dark);
  letter-spacing: .5px;
}

.topbar .course-title {
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.topbar .spacer { flex: 1; }

.badge {
  font-size: 12px;
  color: var(--muted);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 2px 10px;
  white-space: nowrap;
}

/* layout */

.layout {
  display: flex;
  align-items: flex-start;
  gap: 24px;
  max-width: 1180px;
  margin: 0 auto;
  padding: 24px 20px 64px;
}

/* sidebar */

.sidebar {
  position: sticky;
  top: 76px;
  flex: 0 0 280px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 6px;
  overflow: hidden;
}

.sidebar .section {
  border-bottom: 1px solid var(--border);
}
.sidebar .section:last-child { border-bottom: 0; }

.sidebar .section-title {
  padding: 12px 16px 8px;
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: .4px;
  color: var(--muted);
}

.sidebar .unit {
  display: flex;
  gap: 10px;
  padding: 9px 16px;
  border-left: 3px solid transparent;
  color: var(--text);
}
.sidebar .unit:hover { background: #f7f9fb; text-decoration: none; }

.sidebar .unit.current {
  background: #eef6fc;
  border-left-color: var(--accent);
  font-weight: 600;
}

.sidebar .unit .num { color: var(--muted); font-variant-numeric: tabular-nums; }
.sidebar .unit .steps { color: var(--muted); font-size: 12px; }

/* content */

.content { flex: 1; min-width: 0; }

.lesson-head {
  display: flex;
  align-items: baseline;
  gap: 10px;
  margin-bottom: 12px;
}
.lesson-head h1 { font-size: 22px; margin: 0; }
.lesson-head .crumb { color: var(--muted); font-size: 13px; }

/* step tabs */

.steps {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: -1px;
}

.steps .step {
  display: flex;
  align-items: center;
  gap: 6px;
  min-width: 40px;
  height: 36px;
  padding: 0 12px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-bottom-color: transparent;
  border-radius: 6px 6px 0 0;
  color: var(--muted);
  font-size: 13px;
  font-variant-numeric: tabular-nums;
}
.steps .step:hover { color: var(--text); text-decoration: none; }

.steps .step.current {
  color: var(--text);
  font-weight: 600;
  box-shadow: inset 0 3px 0 var(--accent);
}

.steps .step .icon { font-size: 12px; }

/* step body */

.card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 0 6px 6px 6px;
  padding: 28px 32px;
}

.card > :first-child { margin-top: 0; }
.card > :last-child { margin-bottom: 0; }

.card h1, .card h2, .card h3 { line-height: 1.3; }
.card h1 { font-size: 24px; }
.card h2 { font-size: 20px; }
.card h3 { font-size: 17px; }

.card img { max-width: 100%; }

.card blockquote {
  margin: 16px 0;
  padding: 4px 16px;
  border-left: 3px solid var(--border);
  color: #5b6773;
}

.card table {
  border-collapse: collapse;
  width: 100%;
  margin: 16px 0;
}
.card th, .card td {
  border: 1px solid var(--border);
  padding: 8px 12px;
  text-align: left;
}
.card th { background: #f7f9fb; }

.card code {
  background: #f2f4f6;
  border-radius: 3px;
  padding: 2px 5px;
  font: 13px/1.5 "SF Mono", Menlo, Consolas, monospace;
}

.card pre {
  background: #f7f9fb;
  border: 1px solid var(--border);
  border-radius: 5px;
  padding: 14px 16px;
  overflow-x: auto;
}
.card pre code { background: none; padding: 0; }

/* quiz */

.quiz { margin-top: 24px; border-top: 1px solid var(--border); padding-top: 20px; }
.quiz .quiz-title { font-weight: 600; margin-bottom: 12px; }

.quiz .option {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 9px 12px;
  border: 1px solid var(--border);
  border-radius: 5px;
  margin-bottom: 8px;
}
.quiz .option.correct {
  border-color: var(--correct);
  background: #f2f9f2;
}
.quiz .option .mark { color: var(--correct); font-weight: 700; }
.quiz .option .feedback {
  display: block;
  color: var(--muted);
  font-size: 13px;
  margin-top: 2px;
}

.quiz textarea {
  width: 100%;
  min-height: 110px;
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: 5px;
  background: #fbfcfd;
  font: inherit;
  resize: vertical;
}

/* banners */

.banner {
  border-radius: 5px;
  padding: 12px 16px;
  margin-bottom: 12px;
  font-size: 14px;
}
.banner .banner-title { font-weight: 600; margin-bottom: 6px; }
.banner ul { margin: 0; padding-left: 20px; }
.banner li { margin: 2px 0; }
.banner code { font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 13px; }

.banner.warn { background: var(--warn-bg); border: 1px solid var(--warn-border); }
.banner.error { background: var(--error-bg); border: 1px solid var(--error-border); }

/* footer nav */

.pager {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-top: 20px;
}

.pager a, .pager span {
  padding: 9px 18px;
  border-radius: 5px;
  border: 1px solid var(--border);
  background: var(--surface);
  font-size: 14px;
}
.pager a:hover { border-color: var(--accent); text-decoration: none; }
.pager span { color: #c3cad1; }

/* empty / error pages */

.notice {
  max-width: 640px;
  margin: 80px auto;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 32px;
  text-align: center;
}
.notice h1 { font-size: 20px; margin-top: 0; }
.notice pre {
  text-align: left;
  background: #f7f9fb;
  border: 1px solid var(--border);
  border-radius: 5px;
  padding: 14px;
  overflow-x: auto;
  font-size: 13px;
}
''';

  /// Subscribes to the server's change stream and reloads on rebuild.
  ///
  /// `EventSource` reconnects on its own, so a server restart also brings the
  /// page back rather than leaving it stale.
  static const reloadScript = r'''
(function () {
  var source = new EventSource('/__reload');
  source.addEventListener('rebuild', function () { location.reload(); });

  // A page kept alive in the back/forward cache holds its EventSource socket
  // open, and Chrome allows only ~6 connections per origin: without this, a few
  // navigations leave the next one with no socket left and it stalls.
  window.addEventListener('pagehide', function () { source.close(); });

  // Restoring from the bfcache brings back a page whose stream is now closed,
  // so reload to get both fresh content and a fresh subscription.
  window.addEventListener('pageshow', function (event) {
    if (event.persisted) location.reload();
  });
})();
''';
}

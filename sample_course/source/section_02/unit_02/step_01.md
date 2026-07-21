---
id:
type: text
---

## Marks

Inline reminders, written `[[KEYWORD: message]]` and scanned from the raw
source so each is reported with a `file:line:column` an IDE console will
linkify.

They are deliberately kept in their own unit, because the `FIXME` below blocks
a push by design — that is the feature, not a mistake in this course.

`NOTE` is the author-only one: reported, never blocking, and stripped from the
HTML so it never reaches a student. [[NOTE: reviewed against COURSE_SYNTAX.md]]

`TODO` is a warning. It reaches students as a ⚠️ badge, on purpose — an
unfinished step should look unfinished. [[TODO: add a diagram of the pipeline]]

`FIXME` is an error. It renders as a ⛔ badge and stops `pluto push` until it is
resolved. [[FIXME: this is the mark that keeps this course preview-only]]

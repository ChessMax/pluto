---
id:
type: single_choice
is_always_correct: false
preserve_order: false
is_html_enabled: true
---

A `single_choice` step asks a question with exactly one right answer.

The answers live in a `## options` section, which is lifted out of the body
before rendering — so what you write below never shows up inside the question.

Which file holds a unit's lesson?

## options

- [x] `unit_03/lesson_03.md`
  > Right — the lesson file is named after **its unit**, not after its own
  > position in the course.
- [ ] `unit_03/lesson_01.md`
  > No — that would be the first lesson of the course, not of this unit.
- [ ] `lesson_03/lesson.md`
  > No — lessons are files inside a unit directory, never directories.

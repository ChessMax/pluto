---
id:
type: multiple_choice
is_always_correct: false
preserve_order: true
is_html_enabled: true
---

A `multiple_choice` step differs from the previous one only in its `type:` —
the options section is written exactly the same way.

This step also sets `preserve_order: true`, so Stepik shows the options in the
order written instead of shuffling them. That matters here, because the last
option refers to the ones above it.

Which of these are true of the `## options` section?

## options

- [x] Indented lines continue an option's text
  > Correct — including fenced code, so an option can hold anything a step
  > body can:
  >
  > ```dart
  > final answer = 42;
  > ```
- [x] Indented `>` lines are that option's feedback
  > Correct — like this one.
- [ ] An unindented stray line is silently dropped
  > No — it is an error. Failing loudly beats losing text an author wrote.
- [x] All of the correct ones above
  > This is why `preserve_order: true` is set on this step.

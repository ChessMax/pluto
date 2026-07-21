---
id:
type: text
---

## Markdown gallery

Everything on this page is plain Markdown that survives Stepik's HTML
whitelist. Anything outside it is reported by `pluto status` and blocks a push.

Inline: **bold**, *italic*, ~~struck through~~ (rewritten from `<del>` to
`<strike>` on the way out), `inline code`, a [link](https://stepik.org), an
autolink <https://stepik.org>, an emoji :rocket:, and colour swatches `#ff0000`
and `rgb(0, 255, 0)`.

A table:

| Fence | Purpose | Required |
| --- | --- | --- |
| `samples` | shown to the student | no |
| `tests` | checked against | yes |
| `dart` | starter template | no |

An ordered list, a nested one, and a task list:

1. First
2. Second
   - nested
   - also nested
3. Third

- [x] Written
- [ ] Reviewed

A blockquote and the alert forms of one:

> An ordinary quote.

> [!NOTE]
> Useful information a reader should notice.

> [!WARNING]
> Something that will bite if ignored.

A footnote[^1] hangs off the bottom of the step.

[^1]: Like this — the definition can sit anywhere in the file.

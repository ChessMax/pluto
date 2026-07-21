# Course source syntax

How a `pluto` course is written on disk, and what each piece turns into on Stepik.

A course is a directory tree of Markdown files under `source/`. Every file has
optional YAML front matter for scalar fields and a Markdown body for content.
`pluto push` renders the bodies to HTML, diffs against the remote course, and
uploads what changed.

- [1. Directory layout](#1-directory-layout)
- [2. Files and their fields](#2-files-and-their-fields)
- [3. Step types](#3-step-types)
- [4. Body Markdown](#4-body-markdown)
- [5. Marks — TODO / FIXME / NOTE](#5-marks--todo--fixme--note)
- [6. In-course links (`ref:`)](#6-in-course-links-ref)
- [7. Config variables](#7-config-variables)
- [8. Abbreviations](#8-abbreviations)
- [9. Rendering quirks worth knowing](#9-rendering-quirks-worth-knowing)
- [10. A complete step, end to end](#10-a-complete-step-end-to-end)

## 1. Directory layout

```
my_course/
└── source/
    ├── course.md              # course front matter + config
    ├── abbreviations.md       # optional: acronym → expansion
    ├── summary.md             # long-form course fields, one file each
    ├── description.md
    ├── requirements.md
    └── section_01/
        ├── section_01.md      # section front matter
        └── unit_01/
            ├── unit_01.md     # unit front matter
            ├── lesson_01.md   # lesson front matter — number matches the unit
            ├── step_01.md
            ├── step_02.md
            └── step_03.md
```

Ordering is taken from the zero-padded number in the name, never from a
`position:` field — `section_(\d+)`, `unit_(\d+)`, `step_(\d+).md`. Renumbering
a course means renaming files. Directories and files that do not match these
patterns are ignored, so drafts and notes can sit alongside the real thing.

The lesson file is named after **its unit**: `unit_03/` holds `lesson_03.md`.

## 2. Files and their fields

### `course.md`

```md
---
id: null                 # filled in by the first push; leave null when authoring
title: Dart from scratch # max 64 chars
title_en: Dart from scratch
config:
  support_email: help@example.com
  year: 2026
---
```

`id: null` means "not on Stepik yet". After a push, `pluto` writes the real id
back — don't edit it by hand.

The seven long-form fields live in their own files next to `course.md`, so an
editor previews them and nothing needs escaping:

| File | Stepik field |
| --- | --- |
| `summary.md` | Краткое описание (100–512 chars) |
| `acquired_assets.md` | Чему вы научитесь |
| `description.md` | О курсе |
| `target_audience.md` | Для кого этот курс |
| `requirements.md` | Начальные требования |
| `learning_format.md` | Как проходит обучение |
| `acquired_skills.md` | Что вы получаете |

A missing file leaves the field unset. Older courses put these in fenced blocks
inside `course.md` (```` ```summary ````); that still reads, but the file wins
when both exist.

### `abbreviations.md`

Optional, and unusual in having no body at all — just front matter, one term per
line:

```md
---
ЯП: язык программирования
PL: Programming Language
---
```

Each term is marked up with `<abbr>` where it appears in step text. Full rules in
[§8](#8-abbreviations).

### `section_NN.md`

```md
---
id: null
title: Getting started
description: Optional blurb shown under the section title.
---
```

### `unit_NN.md`

```md
---
id: null
---
```

### `lesson_NN.md`

```md
---
id: null
title: Variables and constants
---
```

### `step_NN.md`

```md
---
id: null
label: intro-variables   # optional, stable link target — see §6
type: text               # required
---

Body Markdown goes here.
```

## 3. Step types

`type:` selects the step kind and which extra front-matter keys apply.

### `text`

Content only. No extra keys.

### `single_choice` / `multiple_choice`

```md
---
id: null
type: multiple_choice
is_always_correct: false   # default false — accept any answer
preserve_order: false      # default false — keep options in written order
is_html_enabled: true      # default true
---

Which of these are Dart keywords?

## options

- [x] `sealed`
  > Added in Dart 3.
- [x] `mixin`
- [ ] `interface{{ }}`
  > Close — `interface` is a modifier, not a standalone keyword.
```

The `## options` section is lifted out of the body before rendering, so the
answers never show up in the question. Rules:

- `- [x]` marks a correct option, `- [ ]` an incorrect one.
- Indented lines under an item continue its **text** — including code fences,
  so an option can hold anything a step body can.
- Indented `>` lines are that option's **feedback**.
- The section ends at the next `##` heading, or at end of file.

An unindented non-option line inside the section is an error, not silently
dropped text.

### `code`

````md
---
id: null
type: code
---

Print the sum of two numbers.

```samples
2 3
5
```

```tests
10 20
30
7 8
15
```

```dart
void main() {
  // your code here
}
```
````

`samples` and `tests` are line pairs — input line, then expected output line.
An odd number of lines is an error. `dart` is the starter template the student
sees.

### `free_answer`

```md
---
id: null
type: free_answer
manual_scoring: false
is_attachments_enabled: false
is_html_enabled: true
---

Describe, in your own words, what a `sealed` class buys you.
```

## 4. Body Markdown

Everything below the front matter is Markdown, rendered by a GitHub-flavoured
subset chosen to fit Stepik's HTML whitelist.

Supported:

- **Blocks** — fenced code, setext headings, tables, ordered/unordered lists
  (including task lists), blockquotes, footnotes, GitHub alerts
  (`> [!NOTE]`, `> [!WARNING]`, …).
- **Inline** — emphasis, strikethrough (`~~gone~~`), inline code, links,
  autolinks, `:emoji:`, colour swatches (`` `#ff0000` ``, `` `rgb(0,255,0)` ``),
  and raw inline HTML.

Only whitelisted tags survive: `a abbr audio b blockquote br code details em h1
h2 h3 i iframe img li ol p pre span strike strong summary table tbody td th
thead tr ul`. Anything else — and any attribute not allowed on its tag — is
reported by `pluto status` and blocks a push. `<del>` is rewritten to
`<strike>` automatically.

A fenced code block renders as `<pre><code class="language-dart">`, matching
what Stepik's own lesson editor produces — see
[HTML_TAG_ATTRIBUTE_WHITE_LIST.md](HTML_TAG_ATTRIBUTE_WHITE_LIST.md), which
records the editor output the whitelist is checked against.

## 5. Marks — TODO / FIXME / NOTE

Inline reminders written as `[[KEYWORD: message]]`. They are scanned from the
raw source, so every one is reported with an exact `file:line:column` an IDE
console will linkify.

```md
Dart has sound null safety. [[TODO: add a diagram here]]

The compiler rejects this. [[FIXME: verify against Dart 3.9]]

[[NOTE: this section was reviewed on 2026-05-01]]
```

| Keyword | Severity | Reported | Blocks push | Reaches students |
| --- | --- | --- | --- | --- |
| `NOTE` | info | yes | no | **no** — stripped from the HTML |
| `TODO` | warning | yes | no | yes, as a ⚠️ badge |
| `FIXME` | error | yes | **yes** | yes, as a ⛔ badge |

`NOTE` is the author-only one: use it for editorial notes that must never leak.
`TODO` and `FIXME` render visibly on purpose — an unfinished step should look
unfinished in preview.

## 6. In-course links (`ref:`)

Link to another step without hardcoding Stepik ids:

```md
We covered this in [the intro](ref:section_01/unit_01/step_02).
Or jump to [the unit's first step](ref:section_02/unit_01).
Or by label: [see variables](ref:intro-variables).
```

Two ways to name a target:

- **By location** — `section_01/unit_01/step_02`, or `section_01/unit_01` for
  the unit's first step. Simple, but breaks when you renumber.
- **By label** — the `label:` declared in the target step's front matter.
  Survives renaming, renumbering and moving the file. Prefer this for anything
  you link to more than once.

A ref resolves to `/lesson/<id>/step/<n>?unit=<id>`, kept relative so the same
link works on stepik.org and in the local preview server.

Failure modes are deliberate rather than silent:

- **Unresolvable ref** — left as written (`ref:` is not a valid URL scheme, so
  it can't slip through) and reported against the step it appears in.
- **Target not pushed yet** — resolves to a synthetic id in preview so you can
  click through while drafting, but `push` refuses it: a synthetic id would
  point at somebody else's lesson.
- **Duplicate label** — ambiguous, so it resolves to nothing and is reported.

## 7. Config variables

Values declared once in `course.md`, referenced anywhere in step Markdown:

```md
---
id: null
title: Dart from scratch
config:
  support_email: help@example.com
  chat_url: https://t.me/example
  year: 2026
---
```

```md
Questions? Write to {{config.support_email}} or join
[the chat]({{config.chat_url}}).

© {{config.year}} — [contact us](mailto:{{config.support_email}}).
```

Rules:

- Keys are letters, digits and underscore, not starting with a digit.
- Values must be scalars — `year: 2026` needs no quotes, but maps and lists are
  rejected, since a reference expands to inline text.
- A null value is dropped rather than rendered as the text "null".
- **References inside code are never expanded.** A course about programming is
  full of `{{ }}` in Vue, Jinja and Handlebars samples, and those stay verbatim
  in both fenced blocks and inline code spans — no escaping needed.
- References work in link destinations (`href`, `src`), including `mailto:`.
- An **unknown key is left visible** as `{{config.whatever}}` and reported,
  rather than blanked — a visible typo is fixable, a silently empty support
  address is not.
- Spaces inside a link destination break Markdown's link parsing, so write
  `[x]({{config.url}})`, never `[x]({{ config.url }})`.

## 8. Abbreviations

Acronyms declared once in `abbreviations.md`, marked up wherever they appear in
step text — you write `ЯП`, the reader gets the full wording on hover:

```md
---
ЯП: язык программирования
ПО: программное обеспечение
PL: Programming Language
HTTP/2: вторая версия протокола
---
```

Nothing is written in the step itself. This:

```md
Каждый ЯП решает свои задачи. Второй ЯП учить проще.
```

renders as:

```html
<p>Каждый <abbr title="язык программирования">ЯП</abbr> решает свои задачи.
Второй ЯП учить проще.</p>
```

Note the second `ЯП` is left plain — see the first rule below.

Rules:

- **Only the first use in a step is marked.** A page where every `ЯП` carries a
  tooltip is noisier than it is helpful. "First" is per step, so each step marks
  its own first occurrence.
- **Matching is case-sensitive and whole-word.** `PL` is marked, `pl` is not, and
  neither `ЯПы` nor `вЯП` counts — a term has to stand alone. Case-sensitivity
  keeps a term like `IT` from swallowing every ordinary "it".
- **Any script works.** `ЯП` and `PL` are marked the same way.
- **The longest matching term wins**, so declaring both `HTTP` and `HTTPS` marks
  `HTTPS` as itself rather than as `HTTP` with a stray `S`.
- **Terms in code are never marked**, in fenced blocks and inline spans alike —
  and a term appearing in code does not consume the step's first use, so
  ``` `ЯП` — это язык, и ЯП бывают разные ``` still marks the prose one.
- Text that is already emphasised (`**жирный**`, `*курсив*`) is left alone.
- A term is letters and digits of any script, optionally joined by `.`, `/`, `-`
  or `_` — so `HTTP/2` and `well-known` work, while `C++` and multi-word terms
  are **rejected with an error** when the file is read. They could never match on
  a word boundary, and failing loudly beats a term that silently never fires.
- Expansions must be scalars; a term with no value is dropped rather than
  rendered as the text "null".
- A Latin term is italicised inside the tag
  (`<abbr title="…"><em>PL</em></abbr>`), a Cyrillic one is not — see
  [§9](#9-rendering-quirks-worth-knowing).
- **A declared term that no step uses is reported** by `pluto status` as a
  warning. It never blocks a push: an unused abbreviation is untidy, not broken.

## 9. Rendering quirks worth knowing

Two transformations happen that you did not write, and both surprise people the
first time:

**Latin words are auto-italicised.** Runs of Latin letters and numbers get
wrapped in `<em>` automatically, so English terms and versions stand out in a
Russian-language course without any markup: `HTTP/2`, `v2.0`, `well-known` and
`3.14` each stay in one piece. Cyrillic is never wrapped, and nothing inside
`code`, `pre`, `em`, `i`, `strong` or `b` is touched.

This is why an abbreviation ([§8](#8-abbreviations)) comes out italic in one
script and not the other: `<abbr title="…"><em>PL</em></abbr>` but
`<abbr title="…">ЯП</abbr>`. The tag follows whatever the surrounding text does,
so a Cyrillic term is not made the only italic Cyrillic on the page.

**Headings are centred and spaced.** A first-line `h1` renders as
`<h1 style="text-align:center">…</h1>` followed by a spacer paragraph; later
headings get the spacer before them instead. Headings nested in a blockquote or
list item are left alone — they title a fragment, not the step.

## 10. A complete step, end to end

```md
---
id: null
label: null-safety-intro
type: single_choice
is_html_enabled: true
---

# Sound null safety

Dart 2.12 made null safety *sound*: the compiler proves a non-nullable
variable can never hold `null`, so there is no runtime check to pay for.

> [!NOTE]
> Mixed-version programs are unsound until every dependency migrates.

[[TODO: add the migration diagram]]

Read more in [the intro](ref:section_01/unit_01/step_01), or ask at
{{config.support_email}}.

## options

- [x] The compiler rejects `String s = null;`
  > Correct — `String` is non-nullable, so this never compiles.
- [ ] It only warns at runtime
  > No — the point of *sound* null safety is that there is no runtime check.
```

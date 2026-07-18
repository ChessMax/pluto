<div align="center">

# 🪐 Pluto

**A static course generator for [Stepik](https://stepik.org).**

Author your course as plain Markdown files, keep it in Git, and push it to Stepik with a single command.

[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)

</div>

---

## ✨ What is Pluto?

Pluto treats an online course the way a static site generator treats a website. Instead of clicking through Stepik's web editor, you write your course as a **directory of Markdown files and other files**, version it with Git, and let Pluto **render** and **sync** it to Stepik through the official API.

```
Source files (md, dart, etc...)  →  Domain model  →  Render (Markdown → HTML)  →  Stepik API
                                  ↘  Diff against remote  ↗  →  Upload to Stepik
```

- 📝 **Author in Markdown** — front matter for metadata, fenced blocks for content.
- 🗂 **Structured on disk** — sections, units, lessons, and steps map to folders and files.
- 🔍 **Diff before you push** — see exactly what changed between your files and the live course.
- 🚀 **One-command sync** — create and update courses without leaving the terminal.

## 📦 Requirements

- [Dart SDK](https://dart.dev/get-dart) **3.10 or newer**
- A [Stepik](https://stepik.org) account with API credentials:
  - [Stepik Applications](https://stepik.org/oauth2/applications/) to obtain CLIENT_ID & STEPIK_CLIENT_SECRET key 

## 🚀 Getting started

```bash
git clone <this-repo> pluto && cd pluto
dart pub get

export STEPIK_CLIENT_ID=your_client_id
export STEPIK_CLIENT_SECRET=your_client_secret

dart run bin/pluto.dart --help
```

> 💡 Create API credentials at **stepik.org → Settings → OAuth apps**.

## 🛠 Usage

Pluto is organized as a set of subcommands. Most operate on a **course directory** (defaulting to the current directory).

| Command | Description |
| --- | --- |
| `init course <name>` | Scaffold a new course directory. |
| `add section` | Add a new section to an existing course. |
| `copy` | Copy a course from one directory to another. |
| `status` | Show the diff between your local course and the remote one. |
| `push course <dir>` | Push (create/update) the course to Stepik. |
| `stepik list` | List your courses on Stepik. |

### Examples

```bash
# Scaffold a new course
dart run bin/pluto.dart init course my_course

# Add a section (options: -p path, -t title, -d description)
dart run bin/pluto.dart add section -p my_course -t "Getting Started"

# See what would change before pushing
dart run bin/pluto.dart status my_course

# Push the course to Stepik
dart run bin/pluto.dart push course my_course

# List your Stepik courses
dart run bin/pluto.dart stepik list
```

## 📂 Course layout

A course is a tree of files (md, dart, and other formats) under `source/`. Ordering comes from the zero-padded numeric suffix in each name:

```
my_course/
└── source/
    ├── course.md                      # course-level metadata & description
    ├── section_01/
    │   ├── section_01.md              # section metadata
    │   └── unit_01/
    │       ├── unit_01.md
    │       ├── lesson_01.md
    │       ├── step_01.md             # individual steps (text, quiz, …)
    │       └── step_02.md
    └── section_02/
        └── section_02.md
```

Each file uses **YAML front matter** for scalar fields and **fenced code blocks named after a field** for multi-line content. For example, in `course.md`:

````markdown
---
id: null
title: My Practical Course       # max 64 chars
title_en: My Practical Course
---

```summary
This is the *summary* of the course (100–512 characters).
```

```description
A longer description of what this course covers.
```
````

The block's language tag (` ```summary `, ` ```description `) is the field name. See [`my_second_course/`](my_second_course) for a complete worked example.

## 🧑‍💻 Development

```bash
dart test                          # run all tests
dart test test/lexer_test.dart     # run a single test file
dart analyze                       # static analysis (strict lints)
dart format .                      # format code
./build_runner.sh                  # regenerate *.g.dart (JSON serialization)
```

Run `./build_runner.sh` after editing any `@JsonSerializable` DTO in `lib/data/`.

### Project structure

| Path | Responsibility |
| --- | --- |
| `bin/pluto.dart` | CLI entry point (`CommandRunner`). |
| `lib/commands/` | Subcommand implementations. |
| `lib/domain/` | Pure model (`Course → Section → Unit → Lesson → StepSource`) and repositories. |
| `lib/data/` | JSON DTOs, Dio HTTP client, serialization. |
| `lib/stepik_api/` | Typed and raw wrappers over the Stepik REST API. |
| `lib/template/` | Custom templating engine used to scaffold course files. |
| `lib/md/` | Markdown parsing (front matter + fenced blocks). |
| `test/` | Unit tests for the lexer, parser, and template engine. |

## 📄 License

Released under the [MIT License](LICENSE).

---
id:
type: text
---

## In-course links

Linking to another step by its Stepik id would mean editing the link every time
the course is rebuilt, so `ref:` links name the target instead.

By location — [the code step](ref:section_01/unit_01/step_04), or
[the first step of a unit](ref:section_01/unit_01) when the step is left off.
Simple to write, but it breaks the moment a file is renumbered.

By label — [the introduction](ref:intro), which points at the step declaring
`label: intro`. This survives renaming, renumbering and moving the file, so it
is the better choice for anything linked more than once.

Both resolve to a relative URL, which is why the same link works on stepik.org
and in `pluto preview`.

> [!NOTE]
> The refs above cannot be pushed while this course has no Stepik ids. Preview
> resolves them against synthetic ids so they stay clickable while drafting;
> `push` refuses them rather than pointing a link at somebody else's lesson.

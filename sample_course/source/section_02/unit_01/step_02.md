---
id:
type: text
---

## Config variables and abbreviations

Two things declared once for the whole course and reused wherever they appear.

**Config variables** come from the `config:` block in `course.md`. Write to
{{config.support_email}}, join [the chat]({{config.chat_url}}), or read the
small print — © {{config.year}}.

A reference inside code is never expanded, which is what makes this course safe
to write about templating: `{{config.year}}` and

```html
<p>{{ message }}</p>
```

both stay exactly as typed. An unknown key is left visible and reported rather
than blanked, on the grounds that a typo you can see is fixable and a silently
empty support address is not.

**Abbreviations** come from `abbreviations.md`, and nothing is written in the
step at all. This is the first mention of PL in this step, so it renders with a
tooltip; a second PL right after it does not, because one tooltip per step is
help and three are noise.

Matching is whole-word and case-sensitive, so `pl` is untouched. Any script
works — ЯП is marked the same way. And a term in code, like `HTTP/2` here, is
never marked and does not spend the step's first use, so this HTTP/2 still gets
its tooltip.

Latin runs are auto-italicised, Cyrillic is not — which is why PL comes out
italic inside its tooltip and ЯП does not.

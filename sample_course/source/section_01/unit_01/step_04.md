---
id:
type: code
---

A `code` step asks for a program. Three fences configure it:

- `samples` — the worked example the student is shown
- `tests` — what the submission is actually checked against
- `dart` — the starter template in the editor

Both `samples` and `tests` are line pairs: an input line, then the output
expected for it. An odd number of lines is an error rather than a
half-ignored last case.

Read two numbers and print their sum.

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

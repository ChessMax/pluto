/// Inline styles for authoring diagnostics rendered into the step HTML —
/// reminder markers and unresolved `{{config.*}}` references.
///
/// Shared so every diagnostic badge looks the same by construction. `style` on a
/// `span` departs from Stepik's documented whitelist and is allowed for exactly
/// this purpose (see html_whitelist.dart); nothing carrying these styles ever
/// reaches students, since the violations they mark abort a push.
const String warningStyle =
    'background-color:#fff3cd;color:#856404;padding:2px 4px;border-radius:3px;';
const String errorStyle =
    'background-color:#f8d7da;color:#721c24;padding:2px 4px;border-radius:3px;';

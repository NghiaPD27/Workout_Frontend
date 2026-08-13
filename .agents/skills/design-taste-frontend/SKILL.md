---
name: design-taste-frontend
description: Mobile app design taste skill for Flutter, Android, and iOS interfaces. Use when designing, redesigning, or polishing mobile screens, flows, navigation, forms, dashboards, onboarding, auth, workout/productivity apps, and any frontend work where the primary surface is a phone rather than a web page.
---

# Mobile App Design Taste

Use this skill to make mobile app UI feel intentional, usable, and native enough to trust. The default target is Flutter with Material 3, but the rules apply to Android and iOS mobile surfaces generally.

Do not treat this as a web landing-page skill. Avoid hero-page instincts, desktop-first layouts, oversized marketing sections, hover-dependent interactions, and browser viewport assumptions.

## 1. Design Read

Before editing UI, infer the product context in one sentence:

`Reading this as: <mobile app type> for <user>, with a <vibe> language, optimized for <primary workflow>.`

Examples:

- `Reading this as: fitness planning app for everyday exercisers, with a calm coaching language, optimized for quick daily workout decisions.`
- `Reading this as: auth/onboarding flow for first-time users, with a trust-first language, optimized for low-friction completion.`
- `Reading this as: progress dashboard for returning users, with a focused utility language, optimized for scanability.`

If the brief is ambiguous and materially affects the design, ask one question. Otherwise infer and proceed.

## 2. Mobile-First Defaults

Design for one-handed use and repeated daily use.

- Treat the phone screen as the primary canvas, not a shrunken desktop.
- Prefer clear task flows over decorative sections.
- Prioritize the next user action above visual spectacle.
- Use bottom navigation for 3-5 top-level destinations.
- Use tabs or segmented controls for peer modes inside one section.
- Use modal bottom sheets for short choices and contextual actions.
- Use full screens for long forms, complex creation flows, and focused tasks.
- Use snackbars/toasts for transient confirmation, not critical errors.
- Avoid hover-only affordances; every interactive state must work by touch.
- Keep text concise; mobile UI should not read like marketing copy.

## 3. Flutter Implementation Bias

Prefer existing Flutter and Material patterns before custom drawing.

- Use `ThemeData`, `ColorScheme`, `TextTheme`, `InputDecorationTheme`, and component themes instead of one-off styling everywhere.
- Use Material 3 components when they match the task: `NavigationBar`, `NavigationRail` for wide layouts, `FilledButton`, `OutlinedButton`, `SegmentedButton`, `Card`, `ListTile`, `BottomSheet`, `Dialog`, `SnackBar`.
- Use `SafeArea` around screen-level layouts that touch device edges.
- Use `Scaffold` structure consistently: app bar/top area, body, bottom navigation or floating action when needed.
- Use `CustomScrollView` and slivers only when they simplify collapsing headers or mixed scroll surfaces.
- Use `ListView.builder` / `GridView.builder` for dynamic lists.
- Use `const` widgets where practical and keep widget build methods readable.
- Extract widgets only when it improves clarity or matches existing local patterns.

## 4. Layout Rules

Mobile layout should feel stable, scannable, and thumb-friendly.

- Minimum touch target: 48x48 logical pixels.
- Page horizontal padding: usually 16px; use 20-24px only for calm/simple screens.
- Vertical rhythm: 8px grid; common gaps are 8, 12, 16, 24, 32.
- Avoid nested cards. Use cards for repeated items, not as page wrappers inside page wrappers.
- Avoid dense rows with too many actions. Put secondary actions in overflow menus or bottom sheets.
- Avoid text clipping at all text scales. Prefer wrapping over shrinking critical text.
- Keep primary CTA visible near the bottom for task completion screens.
- Do not put two competing primary buttons on the same mobile screen.
- Use sticky/bottom CTAs only when the action is the natural next step and does not cover content.
- For forms, stack fields vertically; avoid multi-column form layouts on phones.
- For data, show the most important metric first, then supporting context.

## 5. Navigation

Choose navigation based on information architecture.

- 1-2 primary screens: simple app bar actions or home-first flow.
- 3-5 primary destinations: Material `NavigationBar`.
- More than 5 destinations: group into top-level destinations and move lower-priority items into profile/settings/more.
- Deep workflows: push full screens with clear back behavior.
- Short contextual choices: bottom sheet.
- Destructive confirmations: dialog or bottom sheet with explicit cancel.

Navigation labels must be short: 1-2 words where possible.

## 6. Visual Direction

Default to a quiet, useful mobile product aesthetic.

- Use 1 primary brand color, 1 supporting accent, and neutral surfaces.
- Avoid one-note palettes where every surface is the same hue.
- Avoid AI-purple gradient defaults unless the brand already calls for them.
- Use elevation and borders sparingly. Mobile UIs need hierarchy, not decoration.
- Cards should usually have 8-12px radius in mobile apps. Larger radii are fine for playful consumer apps, but apply consistently.
- Use icons to aid recognition, not as confetti.
- Use real content examples that match the app domain.
- Avoid fake testimonials, fake logos, fake dashboards, and placeholder names like `John Doe`.

## 7. Typography

Mobile type must be legible before it is stylish.

- Use the app's existing font stack unless the user asks for a brand overhaul.
- Typical screen title: 24-32sp.
- Section heading: 18-22sp.
- Body: 14-16sp.
- Caption/metadata: 12-13sp, but keep contrast high.
- Avoid all-caps long labels.
- Avoid negative letter spacing.
- Do not scale font size directly with viewport width.
- Respect dynamic text scaling; test at larger text sizes when touching dense UI.

## 8. Forms And Input

Forms are where mobile apps often feel broken. Make them forgiving.

- Use the correct keyboard type for each field.
- Provide clear labels, not placeholder-only fields.
- Validate inline after the user interacts or submits, not aggressively on first focus.
- Keep error text close to the field.
- Preserve user input on failed submit.
- Disable submit only when the reason is obvious; otherwise allow submit and show actionable errors.
- For auth, support password visibility toggle.
- For long onboarding, show progress and save state when possible.

## 9. States

Every screen touched must account for:

- Loading
- Empty
- Error
- Success/complete
- Offline or network failure when API-bound
- Auth-expired state when relevant

Avoid blank white screens. Skeletons, progress indicators, and short empty-state copy are better than silence.

## 10. Motion

Use motion as feedback, not spectacle.

- Prefer short durations: 120-250ms for UI feedback, 250-400ms for page transitions.
- Animate opacity and transform, not expensive layout properties.
- Avoid continuous ambient animations in utility apps.
- Respect platform reduced-motion settings when applicable.
- Use press, loading, completion, and route transition motion before decorative motion.

## 11. Fitness App Guidance

For this project, bias toward a calm coaching product, not a gym poster.

- Daily workout decisions should be visible within one or two taps.
- Progress metrics should be understandable without reading a paragraph.
- Use encouraging copy, but avoid hype.
- Make missed workouts recoverable; do not shame the user.
- Use color semantically: success/completed, warning/overdue, neutral/upcoming.
- Session cards should show: name, date/day, duration, status, and one clear action.
- Progress screens should pair numbers with interpretation.

## 12. Redesign Protocol

When redesigning an existing screen:

1. Identify the screen's primary job.
2. Preserve working flows and data contracts.
3. Audit visual hierarchy, spacing, text, actions, and states.
4. Change the smallest surface that solves the problem.
5. Keep styling consistent with the rest of the app unless a broader redesign is requested.

Never silently change navigation structure, route names, API behavior, auth behavior, storage, permissions, or business logic just to improve UI.

## 13. Mobile Anti-Patterns

Avoid these:

- Desktop web nav squeezed into mobile.
- Marketing hero pages as the first screen of an app.
- Huge decorative cards that push core actions below the fold.
- Multiple floating cards nested inside each other.
- Tiny tap targets.
- Hover-only controls.
- Text inside controls that wraps awkwardly.
- Progress dashboards made of unexplained numbers.
- Forms with placeholder-only labels.
- Alert dialogs for every minor message.
- Bottom sheets taller than the screen without clear scrolling.
- Scroll views nested in ways that fight gestures.
- Hardcoded heights that clip on small phones.
- Ignoring notch, status bar, keyboard, and bottom gesture area.

## 14. Pre-Flight Check

Before finishing mobile UI work, verify:

- The primary user action is obvious on each changed screen.
- Touch targets are at least 48x48.
- Text fits at small and large phone sizes.
- The layout survives keyboard open/close on form screens.
- Loading, empty, and error states exist where data is fetched.
- Navigation/back behavior is predictable.
- Safe areas are respected.
- Color contrast is readable.
- Components match the app's existing Flutter/Material style.
- No web-only assumptions remain.
- `flutter analyze` or a focused build/check has been run when code changed.

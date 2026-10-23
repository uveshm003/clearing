# Clearing

**Close your mental tabs.**

Clearing is a calm, offline-first Android app that helps you get unfinished
thoughts out of your head, turn them into trusted next actions, and review them
on a regular rhythm. It's built around four verbs: **capture, clarify, plan,
close**. It's deliberately not a feature-dense task manager.

- **Private by default.** No account, no server, no analytics, no ads. The
  release build doesn't request internet access.
- **Small Today.** At most three must-do items. Everything else stays visible
  but quiet.
- **Recovery over punishment.** No streaks, no red overdue badges. Missed items
  are "carried over".

> Status: preparing the closed beta (M5); see [docs/beta](docs/beta/README.md).
> The v1.1 features (batch blocks, after-completion repeats, routines and
> templates, week timeline and series calendar, printable worksheets, morning
> summary) are built on the `v1.1` branch, to ship after beta feedback.
> Android first, iOS later.

## Development

Requires Flutter 3.44 (stable) and Dart 3.12.

```sh
flutter pub get
dart run build_runner build     # Drift code generation
flutter test
flutter test integration_test   # end-to-end, with a phone connected
flutter run
```

### Project layout

```
lib/
  domain/        Pure Dart: entities, Today rules. No Flutter imports.
  data/          Drift database, tables, repositories.
  core/          Providers, router, theme, ids.
  presentation/  Screens and widgets.
drift_schemas/   Schema snapshots used to test migrations.
```

### Design: Glade

The theme lives in `lib/core/glade.dart` (colours, type, spacing, motion)
and `lib/core/theme.dart`. Every colour pair is checked for WCAG AA
contrast; the shared widgets are in `lib/presentation/widgets/`. Screenshot
tests (`test/goldens/`) run on macOS only:

```sh
flutter test --tags golden                   # compare
flutter test --tags golden --update-goldens  # after an intended change
```

### Languages

Strings live in `lib/l10n/arb/` (English is the template; Hindi is the first
translation) and are generated on build. To add a language, copy
`app_en.arb` to `app_<code>.arb`, translate the values, and run
`flutter gen-l10n`; the home-screen widget's few strings are in
`android/app/src/main/res/values-<code>/strings.xml`.

### Database migrations

After changing a table, bump `schemaVersion` in
`lib/data/db/database.dart`, then run:

```sh
dart run drift_dev make-migrations
```

This snapshots the new schema and generates migration tests under
`test/drift/`.

## License

[MIT](LICENSE)

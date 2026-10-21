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

> Status: early development (milestones M0–M2). Android first, iOS later.

## Development

Requires Flutter 3.44 (stable) and Dart 3.12.

```sh
flutter pub get
dart run build_runner build     # Drift code generation
flutter test
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

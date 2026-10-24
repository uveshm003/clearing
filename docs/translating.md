# Translating Clearing

Clearing ships in English and Hindi. Translations are welcome; they're done
by people, not machines, and checked by a test so nothing goes missing.

## The app's words

1. Copy `lib/l10n/arb/app_en.arb` to `lib/l10n/arb/app_<code>.arb`, where
   `<code>` is the language code (`mr`, `gu`, `bn`, `ta`, `es`…).
2. Set `"@@locale"` to the code and translate every value. Leave the keys and
   the `@…` descriptions alone (the descriptions are for you; you don't need
   to copy them).
3. Keep every `{placeholder}` exactly as written. Plurals use ICU syntax:
   translate the words inside `=1{…}` and `other{…}`, and add the plural
   forms your language needs (`few{…}`, `many{…}`).
4. Run `flutter gen-l10n`, then `flutter test test/core/translations_test.dart`.
   It fails if a string or placeholder is missing.

The tone is calm and plain: no exclamation marks, no guilt, no "you missed".
Short sentences. "Done", not "Completed!".

## The home-screen widgets, shortcuts and tile

Copy `android/app/src/main/res/values/strings.xml` to
`android/app/src/main/res/values-<code>/strings.xml` and translate it. The
same test checks these.

## Smart capture's words

Smart capture understands dates, times and repeats typed in any language it
knows. Its words live in `lib/l10n/capture_words.dart`: add your language's
weekdays, months, "today", "tomorrow", "every", "by" and so on to each table.
Then add a few cases to `test/domain/capture_parser_test.dart`, including a
trap or two (an everyday word that looks like a date word).

## Right-to-left languages

Layouts use start/end rather than left/right, so Arabic or Urdu should mostly
just work. Check with the RTL test in `test/presentation/language_test.dart`
and on a phone.

## Checking on a phone

Change the phone's language, open Clearing, and go through Today, capture,
clarify, the weekly review and Settings. Look for text that's cut off,
especially in buttons and chips.

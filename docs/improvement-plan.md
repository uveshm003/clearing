# Clearing: improvement plan

**Scope:** new features, interface and convenience improvements, and a calm,
offline gamification layer for Clearing after the closed beta.
**Constraint:** everything here works with no internet connection. The release
build keeps its current promise: no `INTERNET` permission, no account, no
analytics, no ads.
**Status:** built, 2026-10-24, on the `glade` branch, apart from the items
listed under [Implementation status](#implementation-status). Device checks
are in `docs/beta/exit-checklist.md`.

---

## Contents

1. [Guardrails](#1-guardrails)
2. [Where the app is today](#2-where-the-app-is-today)
3. [Themes of this plan](#3-themes-of-this-plan)
4. [Interface and convenience, screen by screen](#4-interface-and-convenience-screen-by-screen)
5. [New features](#5-new-features)
6. [Gamification: "The Grove"](#6-gamification-the-grove)
7. [Accessibility, languages and polish](#7-accessibility-languages-and-polish)
8. [Engineering foundations](#8-engineering-foundations)
9. [Data model changes](#9-data-model-changes)
10. [Roadmap](#10-roadmap)
11. [Measuring success without telemetry](#11-measuring-success-without-telemetry)
12. [Risks and open decisions](#12-risks-and-open-decisions)
13. [Implementation status](#implementation-status)
14. [Appendix: ideas considered and rejected](#appendix-ideas-considered-and-rejected)

---

## 1. Guardrails

Every proposal was checked against the principles already in the README and
code. A feature that breaks one of these doesn't ship, however popular it
would be.

| Principle | Where it lives today | What it means for new work |
| --- | --- | --- |
| **Offline and private** | No `INTERNET` permission; fonts bundled (`pubspec.yaml`) | No network calls, no cloud APIs, no remote assets. Speech, parsing and art all run on the device. |
| **Small Today** | `mustDoCap` 1–5, "Also today" collapses after 5 (`today_screen.dart`) | New features mustn't add rows to Today by default. Extra information goes behind a tap. |
| **Recovery over punishment** | "Carried over", never red; no streaks (README) | **No streaks, no loss, no decay, no red.** Gamification only ever adds; missing a day takes nothing away. |
| **Calm notifications** | `NotificationIntensity.gentle` default, quiet hours | No new notification is on by default. Celebrations happen in the app, never as a push. |
| **Not feature-dense** | Four verbs: capture, clarify, plan, close | Each new feature must serve one of the four verbs, or the review. Power features go behind progressive disclosure. |
| **Accessible** | WCAG AA pairs, 48 dp targets, 200% text tests, TalkBack actions | Every new widget gets semantics, a contrast check and a golden test. Every animation respects "remove animations". |
| **Translated** | gen-l10n, English + Hindi | Every new string goes into the ARB files, including the home-screen widget's `strings.xml`. |

### Gamification ethics, specifically

Clearing's audience includes people who feel overwhelmed and people with
ADHD, for whom streak-and-loss mechanics often cause the guilt the app is
built to avoid. So the gamification layer follows these rules:

1. **Opt-in, and easy to hide.** One switch in Settings ("Show the Grove")
   turns the whole layer off and leaves no trace in the UI.
2. **Only additive.** Nothing withers, resets to zero, expires with a penalty,
   or shows "you missed…".
3. **Rewards closure, not volume.** Clearing a 40-day-old thought is worth more
   than ticking ten trivial ones. Capturing never earns anything (that would
   reward stuffing the inbox).
4. **Compares you only to yourself, and only upwards.** Never "down 30% from
   last week". If a number went down, don't show that comparison.
5. **No points.** No numeric score, no levels, no leaderboard. Progress is
   shown as a picture (a growing clearing) and as words.
6. **Built from data the app already has.** Most of it is computed from
   `completedAt`, `createdAt` and `ReviewSessions`, so it needs almost no new
   tracking and travels with a backup.

---

## 2. Where the app is today

A quick inventory, so the plan builds on what's there rather than repeating
it.

**Capture:** quick-capture sheet with burst mode and a saved stack
(`capture_sheet.dart`); multi-line paste splits into items
(`ItemActions.capture`); starter suggestion chips; Share-to-Clearing intent;
quick-capture home-screen widget.

**Clarify:** one-question-per-screen flow: actionable → next action →
delegate → when → details (`clarify_screen.dart`); inbox swipe shortcuts with
TalkBack custom actions.

**Plan:** Today (must-do, also today, batch blocks, carried over, this week
row); Upcoming with week timeline; lists (life admin, errands, user lists),
Someday, Archive, Trash; repeat series (fixed and after-completion);
reminders with snooze; batch blocks; templates and routines.

**Close:** complete with the "Mist" animation and undo; focus view; weekly
review (7 steps, resumable, with tallies); overwhelm reset (5 steps).

**Around it:** FTS5 search with filters; backup export/import with reminder;
printable day/week worksheets; morning digest; Today widget; two-pane tablet
layout; onboarding, tips as you go, help centre, FAQ, on-phone error log;
Glade theme (light "Morning", dark "Dusk"); English and Hindi.

**Already gamified, softly:** Today's sky band lightens as items are done
(`GladeTokens.sky`), the dawn glow on completion, the review's stepping
stones (`StepTrail`), the cairn and clearing line art (`clearing_art.dart`).
The Grove in §6 grows out of these.

### Gaps worth closing

These came from reading the code and the beta kit (`docs/beta/`), and they
are what the plan targets:

- Capture is fast, but **everything lands as a bare title**. Dates, lists and
  must-do have to be set later, even when the user typed "pay rent friday".
- **Clarifying is one item at a time.** There's no multi-select or bulk
  action anywhere.
- **No way to see what's been done.** Completed items vanish into Archive,
  which is a plain list. Nothing reflects progress back to the user.
- Focus is deliberately minimal, but there's **no help with starting**, which
  is the hardest part for many users.
- **No "I have 15 minutes, what can I do?"** Items have no effort or context,
  so Today can't be filtered to fit the moment.
- **Backups are manual.** A lost phone loses everything since the last
  export.
- **Reordering** within Today and lists isn't obvious (there's a `sortOrder`
  column, but the UI doesn't make dragging discoverable).
- The beta survey asks "did anything make you feel guilty or nagged?", but
  there's **nothing that makes the user feel good** beyond a single
  animation.

---

## 3. Themes of this plan

The work groups into six themes. The roadmap in §10 orders them.

| # | Theme | One line |
| --- | --- | --- |
| A | **Faster capture** | Understand what's typed, so fewer taps follow. |
| B | **Lighter clarifying** | Decide many things at once, and get gentle suggestions. |
| C | **Plan for the moment** | Effort and context, so Today fits the time and energy available. |
| D | **Help with starting** | Make the first step smaller and the focus view kinder. |
| E | **See your progress** | A done log, a look-back, and the Grove. |
| F | **Trust and safety** | Automatic local backups, app lock, data you control. |

---

## 4. Interface and convenience, screen by screen

Each item has a priority (**P1** next release, **P2** soon after, **P3**
later) and a rough size (**S** under a day, **M** a few days, **L** a week or
more).

### 4.1 Global

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Long-press multi-select** on any item list (Inbox, Today, lists, Search, Someday), with a contextual bar: Today, This week, Pick date, Move to list, Someday, Done, Delete. | Clarifying or rescheduling ten items today takes ten trips. | P1 | M |
| **Drag to reorder** with a visible handle on long-press in Today's sections and user lists; writes `sortOrder`. TalkBack gets "Move up" / "Move down" actions. | `compareTodayOrder` already respects `sortOrder`, but there's no obvious way to set it. | P1 | M |
| **Undo history**: keep the last 10 actions in memory, reachable from a "Recently changed" entry in the overflow menu, beyond the single snackbar. | Snackbars vanish in 4 s; a mis-swipe found a minute later can't be undone. | P2 | M |
| **Consistent swipe actions** everywhere items appear (today only Inbox has them), configurable in Settings: left/right × short/long. | Muscle memory from the Inbox doesn't carry over to Today. | P2 | M |
| **App shortcuts** (long-press launcher icon): Capture, Today, Start review, Overwhelm reset. Static shortcuts in `AndroidManifest.xml`, routed through `widget_intake.dart`. | One tap from the home screen without a widget. | P1 | S |
| **Quick Settings tile** "Capture": opens the capture sheet over the lock screen once unlocked. | Faster than finding a widget; popular in capture apps. | P2 | M |
| **Haptics map**: light on tick (exists), medium on "all clear", a soft double on finishing a review. Off with the system haptics setting. | Feedback without sound or screen. | P2 | S |
| **Optional sounds**: a short bundled sound on "all clear" and review finished, off by default. | Some users want it; must be bundled (no network) and respect silent mode. | P3 | S |
| **Pull-to-capture**: pull down past the header on Today or Inbox to open capture. | Thumb-reachable on tall phones, where the FAB isn't the only way. | P3 | S |
| **Keyboard shortcuts** on tablets and Chromebooks: `N` capture, `/` search, `1–4` tabs, `Space` tick, `E` edit, `Del` delete. | The two-pane layout invites a keyboard; currently only Enter in capture is handled. | P3 | M |

### 4.2 Today

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **"Fits now" filter chip row** under the header (hidden until any item has effort or context, see §5.3): *5 min · 15 min · Low energy · At home · Out*. One chip at a time, clears on leaving. | Answers "what can I do right now?" without adding sections. | P2 | M |
| **"All clear" moment**: when the last item is ticked, the sky band finishes clearing, the clearing scene fades in with a sun rising, and a one-line reflection ("Four things closed today"). Replaces the plain "All clear" subtitle. | The emotional payoff for a finished day; today the only signal is a word. | P1 | S |
| **Tomorrow peek**: a quiet row at the bottom: "Tomorrow: 3 planned" → opens Upcoming at tomorrow. | Lets users end the day knowing tomorrow is handled, without a new tab. | P2 | S |
| **Plan-my-day prompt** (first open after 05:00, only if Today is empty and something is planned for this week): "Pick up to 3 for today" sheet listing This week items as checkboxes. Dismissible forever. | Makes the This week → Today move a ritual instead of a chore. | P2 | M |
| **Carried-over tidy**: in the expanded carried-over section, one button "Decide these" that runs a mini clarify (Today / This week / Someday / Let go) through each, like the reset's step 4. | Carried items pile up silently; this gives a calm exit. | P1 | M |
| **Time-of-day greeting** in the subtitle ("Good morning" / "evening"), translated. | Warmth at no cost; the header already has a subtitle line. | P3 | S |
| **Timed items show a "now" line** between past and future times. | For people who use times, Today becomes a light schedule. | P3 | S |

### 4.3 Inbox

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **"Clarify all" button** in the header when the inbox has 3+ items: runs the clarify flow back-to-back through every item, with a progress trail and "Stop here". | The review does this but only weekly; users want it daily. | P1 | M |
| **Quick-decide cards** mode (optional toggle): one item per card, swipe right "Do it this week", left "Not now (Someday)", up "Today", down "Delete", tap for full clarify. | Fast, tactile triage; maps exactly to the existing swipe actions. | P2 | L |
| **Two-minute nudge**: when clarifying an item with a short title and no notes, offer "Takes under 2 minutes? Do it now" → marks done immediately. | GTD's two-minute rule; closes small loops at once. | P2 | S |
| **Duplicate hint**: if a capture closely matches an open item (FTS match on all words), show "Looks like *Renew passport* is already here" with Merge / Keep both. | Brain dumps repeat themselves. Local FTS5 makes this cheap. | P2 | M |
| **Inbox age shown softly**: items older than 7 days get a small "2 weeks" label in fog colour, never red. | Helps spot stale thoughts without alarm. | P3 | S |

### 4.4 Capture sheet

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Smart parsing** of dates, times, lists and flags as the user types, shown as removable chips under the field (see §5.1). "pay rent fri 9am #home !" → *Pay rent* · Fri 09:00 · Home · Must-do. | Removes most follow-up taps; the biggest single convenience win. | P1 | L |
| **Capture straight to a plan**: a row of small toggles under the field: *Inbox* (default) · *Today* · *This week*. Remembered for the burst, reset next time. | When the user already knows, the Inbox step is busywork. | P1 | S |
| **Voice capture** button, on-device speech only (see §5.2). | Hands-busy capture; must not touch the network. | P2 | M |
| **Recent captures** in the saved stack become tappable to edit or undo. | Typos in a burst can't be fixed until later. | P2 | S |
| **Template quick-insert**: typing `/` lists templates ("/packing" inserts the packing checklist). | Templates exist (`template_actions.dart`) but are three screens away. | P3 | M |

### 4.5 Clarify flow

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Smart defaults**: pre-select the When step from any date parsed at capture, and the list from keywords previously filed there ("milk" → Errands). Purely local, based on the user's own history. | Fewer decisions per item. | P2 | M |
| **"Done means…" examples** under the field, rotating from a small translated set ("Form posted", "Call made, date booked"). | The field is powerful and often skipped; examples teach it. | P1 | S |
| **Break it down** step (optional, after "next action"): add 2–3 subtasks inline. | Big vague items stall; subtasks exist but only in the item screen. | P2 | S |
| **Back button keeps answers**: going back a step restores the previous choice instead of resetting. | Small, but noticed in usability sessions of similar flows. | P1 | S |
| **Effort and context** chips on the details step (§5.3). | Feeds "Fits now". | P2 | S |

### 4.6 Item screen

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Header summary chips** (When, list, repeat, reminder) that open their editors directly, instead of scrolling to the Plan section. | `item_screen.dart` is the longest screen (580 lines); the most-changed fields should be first. | P1 | M |
| **Activity line** at the bottom: "Captured 12 Oct · Moved to This week 14 Oct · Carried over twice". | Context for stale items; built from a small local history (§9). | P3 | M |
| **Photo attachment**: take or pick a photo (receipt, form, label), stored in app storage, included in backups. | Life-admin items often hinge on a document. Camera works offline. | P3 | L |
| **Links in notes** become tappable (phone numbers, emails, addresses) via the system's apps; no web preview fetch. | Calling the dentist from the item is the next action. | P2 | S |
| **Convert to project** (see §5.4). | When an item turns out to be many items. | P3 | M |

### 4.7 Upcoming

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Month view** toggle beside the week timeline, with dots per day (count, not colour-coded urgency). | Planning more than a week ahead is hard today. | P2 | M |
| **Drag an item onto a day** in the week view to reschedule. | Direct manipulation beats the When sheet for moving dates. | P2 | M |
| **Busy-day hint**: a day with more planned than the must-do cap + 5 gets a soft "full day" label, offering to spread items. | Prevents planning tomorrow's overwhelm today. | P3 | S |
| **Waiting-for section** with follow-up dates surfaced on their day. | Waiting items exist but are easy to forget. | P2 | S |

### 4.8 Lists

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **List colours and icons** from a curated, contrast-checked set. | Lists already have an `icon` column; colour aids scanning. | P2 | S |
| **Pinned lists** at the top of the Lists tab, and optionally in the drawer of the two-pane layout. | Most users live in 2–3 lists. | P3 | S |
| **Shopping mode** for errands lists: larger rows, tick moves to the bottom instead of disappearing, "Clear ticked" at the end. | Errands are done standing up in a shop, often one-handed. | P2 | M |
| **Done log ("Cairn")** replaces the plain Archive as the main way to see done items (§6.4). Archive remains for storage. | Progress made visible. | P1 | M |

### 4.9 Search

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Saved searches** as smart lists ("Waiting on Priya", "Errands this week"). | `SearchFilter` already models everything needed; it just isn't savable. | P2 | M |
| **Recent searches** and **filter chips visible by default**. | Discoverability. | P2 | S |
| **Search in notes and subtasks**, with the match highlighted. | Check the FTS index covers them; highlight with FTS5 `highlight()`. | P2 | S |

### 4.10 Weekly review

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Choose a shorter review**: "Quick (5 min)" runs Inbox + Next week only; "Full" runs all seven steps. | Usability target is ≤15 min; many weeks a quick one is enough, and a quick one beats none. | P1 | M |
| **"Look back" closing screen** (§6.5): what got closed this week, the oldest thing cleared, and a tree planted in the Grove. | The review's reward; today it ends on a tally. | P1 | M |
| **Wins prompt** (optional): "Anything you're glad you did this week?" free text, saved to a local journal shown in the Grove. | Reflection improves follow-through; stays private. | P3 | S |
| **Review templates**: let users add their own prompts ("Check bank account", "Plan meals") as extra steps. | Personal reviews differ; reuses the templates model. | P3 | M |

### 4.11 Overwhelm reset and Focus

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Breathing opener** (optional) for the reset: a 30-second paced-breathing animation before step 1, skippable. | Calming before deciding; pure animation, no data. | P2 | S |
| **Focus: "smallest first step"** field pinned at the top if set during reset or clarify, with a big tick for that step alone. | Starting is the hard part. | P1 | S |
| **Focus: optional gentle timebox** (5 / 15 / 25 min), shown as the sky slowly clearing, not a countdown. Nothing recorded. Off by default. | Some users want a container for effort; keeps "nothing tracked". This changes a stated design choice (`focus_screen.dart`: "No timer"), so it's flagged in §12. | P3 | M |
| **Focus: "I'm stuck"** button that offers three ways out: break it down, change "done means", or put it back with "Not now" (no guilt copy). | Avoids abandoning the focus view in silence. | P2 | S |
| **Keep screen on** in Focus while it's open. | Reading a recipe or form while working. | P2 | S |

### 4.12 Settings, onboarding and help

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Settings search** field at the top. | Ten sections are now long; the hint lines help but a search is faster. | P2 | M |
| **"Make Clearing yours" setup** after onboarding: pick style (Minimal / Gentle / Encouraging) that presets the Grove, sounds, tips and digest at once. | One choice instead of ten toggles. | P2 | M |
| **Contextual "What's new"** sheet after an update, translated, with links into the new features. Built from a local changelog asset. | The app can't fetch release notes; bundle them. | P2 | S |
| **Help centre: interactive guides** that open the real screen with a coach-mark overlay, not just text. | Guides already exist per topic (`guides.dart`); make them do. | P3 | L |

### 4.13 Home-screen widgets and notifications

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Interactive Today widget**: tick items from the widget (Android 12+ checkbox remote views), with the sky band in the widget background. | Usability task 7 asks exactly this. | P1 | M |
| **Resizable widget layouts**: 2×1 "next thing", 4×2 Today, 4×4 Today + inbox count. | Fit different home screens. | P2 | M |
| **Grove widget** (§6): the user's clearing as a home-screen picture. | A calm, ambient reminder that isn't a notification. | P3 | M |
| **Notification actions**: add "Tomorrow" and "Pick a time" to reminders, and **inline reply to capture** on the morning digest ("Anything else on your mind?"). | Act without opening the app. | P2 | M |
| **Lock-screen privacy**: per-notification "hide titles on lock screen" setting. | Private by default should include the lock screen. | P1 | S |

---

## 5. New features

### 5.1 Smart capture parsing (Theme A)

**What:** a pure-Dart, rule-based parser in `lib/domain/capture_parser.dart`
that pulls structure out of a captured line. No ML model, no network.

**Recognises (English first, then Hindi):**

| Typed | Result |
| --- | --- |
| `today`, `tonight`, `tmrw`, `tomorrow`, `aaj`, `kal` | When: Today / tomorrow |
| `mon`…`sun`, `next fri`, `this weekend` | Do-date (respects `weekStart`) |
| `12 nov`, `nov 12`, `12/11`, `the 1st` | Do-date (locale-aware day/month order) |
| `9am`, `14:30`, `at 6` | Do-time |
| `in 3 days`, `in 2 weeks` | Do-date |
| `every monday`, `daily`, `monthly on the 1st` | Repeat series suggestion |
| `by friday`, `due 30 nov` | Deadline |
| `#errands` | List (fuzzy-matched to existing lists) |
| `!` at the end | Must-do |
| `@priya` | Waiting on Priya |
| `~15m`, `~1h` | Effort (§5.3) |

**UX rules:**

- Parsed parts appear as **chips** under the field before saving; tapping a
  chip removes it and the words go back in the title. Nothing is silently
  eaten.
- The saved title has the parsed words removed ("Pay rent"), and the original
  text is kept in notes the first time, so nothing is lost.
- An item with a parsed date skips the Inbox and goes straight to active
  (configurable: "Parsed items still go to Inbox").
- A setting turns parsing off for people who find it surprising.

**Testing:** a table-driven test file with 200+ cases per language, including
traps ("Call May about the march" must not become a date). The parser is
pure Dart in `domain/`, so it's fast to test.

**Size:** L. **Priority:** P1.

### 5.2 Voice capture, offline only (Theme A)

**What:** a microphone button in the capture sheet that uses Android's
on-device speech recognition.

**Offline guarantee:** use `SpeechRecognizer.createOnDeviceSpeechRecognizer`
(Android 12+), which never sends audio off the phone. On older phones, or if
no on-device language pack is installed, the button is **hidden**, not
degraded to the cloud recogniser. Help text explains how to download the
offline language pack in Android settings.

**Permission:** `RECORD_AUDIO`, requested only on first tap, with an
explanation screen first. The data-safety form and privacy policy
(`docs/beta/`) get a line each.

**Flow:** hold to talk → transcript appears in the field → runs through the
parser (§5.1) → Save. Each pause in speech of more than 1.5 s starts a new
line, so a spoken brain dump becomes several items, matching paste
behaviour.

**Size:** M (a small platform channel). **Priority:** P2.

### 5.3 Effort and context (Theme C)

**What:** two optional fields on an item:

- **Effort:** 5 min · 15 min · 30 min · 1 h · Longer.
- **Context:** a small, user-editable set of tags with defaults *Home*,
  *Out*, *Computer*, *Phone*, *Low energy*.

**Where they show:** as one quiet chip on the item tile, and in the "Fits
now" filter on Today (§4.2) and Search.

**Design note:** these are hidden until first used. A tip ("Add how long
something takes, and Today can show what fits a spare 15 minutes") appears
after the user has 15+ active items. This keeps the app simple for people who
never need it.

**"I have time" sheet:** from Today's menu, "I have…" → pick a duration and
optionally a context → shows up to 5 matching items, Today's first, then This
week, then Anytime. Pick one → Focus.

**Size:** M. **Priority:** P2.

### 5.4 Projects, lightly (Theme C)

**What:** an item can become a **project**: an outcome with its own next
actions. Not a new screen type; a project is a user list with an outcome line
and an optional target date, so it reuses `Lists`.

**Rules that keep it calm:**

- A project shows only its **next action** in Today/This week, not all its
  steps.
- When the next action is done, the app asks "What's next for *Move house*?"
  with three suggestions from the project's remaining items.
- A project with no next action appears once in the weekly review's "Next
  week" step: "*Move house* has nothing planned. Add a step, or park it?"

**Size:** M. **Priority:** P3. Needs a schema change (§9).

### 5.5 Automatic local backups (Theme F)

**What:** scheduled backups without the internet:

- **Daily automatic backup** to a folder the user picks once through the
  Storage Access Framework (could be the phone's Documents, an SD card, or a
  folder that a separately installed sync app watches; Clearing itself never
  syncs).
- Keeps the last 7 daily and 4 weekly files, then prunes.
- Runs from the existing background work (`background.dart`), only when
  charging or above 30% battery.
- **Optional passphrase encryption** (AES-GCM via a pure-Dart library), so a
  backup file on shared storage is unreadable without it.
- The export reminder (`exportReminderDays`) becomes unnecessary once this is
  on; Settings says "Backed up automatically, last at 03:10".

**Restore:** Backup screen lists found backups by date, with item counts, and
restores one after a preview ("This backup has 214 items, from 12 Oct").

**Size:** M. **Priority:** P1. This is the biggest trust gap for an app that
holds everything only on one phone.

### 5.6 App lock (Theme F)

Biometric or device-PIN lock (`local_auth`, offline), with "Lock after 1 min /
5 min / on leaving". The capture widget and Quick Settings tile still work
while locked (write-only), but don't show content.

**Size:** S. **Priority:** P2.

### 5.7 Device-to-device move (Theme F)

"Move to a new phone": generates the backup file and opens the system share
sheet (Nearby Share, Bluetooth, USB). On the new phone, the onboarding offers
"Restore from a backup" as its first option. No server involved; it's the
existing export with a clearer entry point.

**Size:** S. **Priority:** P2.

### 5.8 Habits as gentle routines (Theme C)

Routines exist (`TemplateKind.routine`). Improve them rather than adding a
habit tracker:

- A routine can be marked **"flexible"**: "3 times a week, any days".
  Progress shows as "2 of 3 this week" with soft dots, **never a streak**.
- Weeks that miss the target show nothing; the count simply starts fresh on
  the new week (that's a new week, not a reset, and the copy says so).

**Size:** M. **Priority:** P3.

### 5.9 Local insights page (Theme E)

A private "Your rhythm" page (from the Grove, or Settings › Your data):

- When you tend to close things (by hour of day, as a soft histogram).
- How long items usually wait in the Inbox (median, trending).
- Which lists move fastest and which get parked.
- Phrased as observations, never judgements: "You close most things before
  noon. Morning must-dos might suit you."

All computed on demand from existing columns. Nothing new is stored.

**Size:** M. **Priority:** P3.

### 5.10 Calendar export, offline (Theme C)

Export Upcoming as an `.ics` file through the share sheet, so a user can
import it into any calendar app manually. One way only; reading the device
calendar would need a permission and adds scope, so it's deferred.

**Size:** S. **Priority:** P3.

---

## 6. Gamification: "The Grove"

### 6.1 The idea

Clearing's metaphor is a forest clearing at first light. The Grove extends
it: **every thought you close helps a small, private landscape grow.** It
never shrinks. It's drawn in code with the same line-art style as
`clearing_art.dart`, so it costs no download and works offline.

The core loop it reinforces is the app's own: **capture → clarify → plan →
close → review.** Rewards attach to closing and reviewing, which are the
behaviours that reduce mental load, not to opening the app or capturing more.

### 6.2 What grows, and from what

All of this is derived from data the app already stores, except where noted.

| Element in the Grove | Earned by | Source data |
| --- | --- | --- |
| **A stone** on the day's cairn | Each item completed | `Items.completedAt` |
| **A wildflower** | Clearing an item that waited 14+ days ("an old tab closed") | `completedAt − createdAt` |
| **A young tree** | Finishing a weekly review (quick or full) | `ReviewSessions.completedAt` |
| **A tree matures** (sapling → tree → old tree) | The same tree's week, plus each review after it in the season | Review count per season |
| **A stream** appears | First overwhelm reset finished | `ReviewSessions` (reset) |
| **Birds** | Days where every must-do was done ("All clear") | Completions vs. must-do flag on that date (needs a small daily record, §9) |
| **A bench** | First automatic or manual backup | `lastExportAt` |
| **Lanterns** | Each "Waiting for" item resolved | Status history (§9) |

**Seasons** follow the calendar (quarterly, hemisphere set by the user). At
each season's turn, the current Grove is **kept as a pressed "season card"**
in an album, and a new season begins with the old trees still standing,
dressed for the new season. Nothing is lost; the landscape just changes
clothes. A Monsoon variant can replace Spring for users who prefer it (nice
fit for Hindi-speaking users).

### 6.3 Where users see it

- **Grove screen**, from the Today menu and the Lists tab ("Your clearing").
  A full-width painted scene, pinch-to-zoom on tablets, with a caption: "This
  season: 64 things closed, 9 reviews, 6 old tabs cleared."
- **Tap any element** to see what it was for: tap a wildflower → "Renew
  passport, waited 41 days, closed 3 Oct". This turns the Grove into a
  done-log you want to browse.
- **Today's header**: on "All clear", the scene that fades in is today's
  small cairn, which then flies into the Grove (respects reduced motion).
- **Optional home-screen widget** (§4.13).

### 6.4 The Cairn: a done log worth opening

Replace "Archive" as the main view of done things with **the Cairn**:

- Grouped by week, each week a stack of stones (one per item), tallest weeks
  drawn tallest. No targets on the axis.
- Tap a week to list what was closed, with search.
- "Old tabs closed" filter highlights items that had waited 14+ days.
- Archive stays as the storage concept behind it; nothing changes in the data.

This gives the user evidence of progress, which matters most on the days they
feel they've done nothing.

### 6.5 Look back (end of the weekly review)

The review's final step (`ReviewStep.close`) becomes a short, gentle
summary, written in words, then the new tree being planted:

> **This week you closed 12 things.**
> The oldest was *Call the insurance company*, which had waited 5 weeks.
> 3 things moved to Someday, so they're out of your head.
> A new tree is growing in your clearing.

Rules: only positive comparisons ("More than any week this season"), never a
negative one. If the week was light, the copy acknowledges rest: "A quieter
week. Clearing your inbox still counts."

### 6.6 Field notes: discoveries, not achievements

A small notebook of **Field notes**, each a one-time, quiet discovery tied to
learning a feature. They double as feature discovery, which complements the
existing tips (`tip_card.dart`).

| Field note | Unlocked by |
| --- | --- |
| *First light* | First item captured |
| *A home for everything* | First item clarified into a list |
| *Out of your hands* | First "Waiting for" |
| *The long view* | First repeating item |
| *Deep breath* | First overwhelm reset |
| *The path* | First weekly review |
| *Just one thing* | First item finished from Focus |
| *Safe keeping* | First backup |
| *From the doorstep* | First capture from the widget or share |
| *Old tab* | First item closed after waiting 30+ days |
| *Open sky* | First "All clear" day |
| *Four seasons* | Reviewed at least once in each season of a year |

Rules:

- Shown as a **small inline card** at the moment it happens ("Field note:
  *Deep breath*. You found the overwhelm reset."), never a modal, never a
  notification.
- The notebook shows locked notes as **soft silhouettes with a hint**, so
  they teach what the app can do, but there's no percentage or "12 of 30".
- No note requires repetition or consistency. All are reachable by trying a
  feature once, except *Four seasons*, which can be earned at any pace.

### 6.7 Invitations: gentle, optional quests

Once a week (on the review day), the app may offer **one** invitation on
Today, as a dismissible quiet row. Examples:

- "Give three inbox items a home."
- "Write a *Done means…* for one thing that's been sitting."
- "Close one thing that's been on your mind for more than a month."
- "Park one idea in Someday that you won't do this month."
- "Try the focus view on your must-do."

Rules:

- Completing it adds a small ornament to the Grove (a lantern, a stepping
  stone).
- **Ignoring it does nothing.** It quietly disappears at the week's end; no
  "expired" label.
- Picked from a local, translated pool, weighted towards features the user
  hasn't tried (using Field notes state) and away from recent ones.
- "Don't show invitations" is one tap on the row itself.

### 6.8 Cosmetic rewards: Glade variants

Unlock **theme variants** through the Grove (not by paying, not by
grinding):

| Variant | Unlocked when |
| --- | --- |
| *Autumn Glade* (amber accent) | First season card pressed |
| *Monsoon Glade* (teal, rain-washed) | 10 reviews |
| *Winter Glade* (cool, high contrast) | 25 old tabs closed |
| *Night Sky* (deep blue Dusk) | 100 things closed |

Each variant is a `GladeTokens` + `ColorScheme` pair, run through the same
WCAG contrast tests as Morning and Dusk. A "Show all themes" setting unlocks
them all at once for anyone who'd rather just choose; rewards should never
gate accessibility (the high-contrast Winter variant is always available from
the accessibility settings regardless).

### 6.9 Micro-delights

Small, cheap touches that make finishing feel good:

- **Sky band** finishes clearing with a sunrise on "All clear" (exists in
  part; extend).
- **Stone sound** (optional, bundled) when a review's stepping stone fills.
- **Count-up** on the Look back numbers.
- **Seasonal touches** on the clearing empty states (snow on the nest in
  winter, rain in monsoon).
- **The dawn glow** from Focus's finished screen reused on the inline tick
  for must-dos.

All honour `MediaQuery.disableAnimations` through `GladeMotion.of`.

### 6.10 Anti-patterns, explicitly banned

| Banned | Why |
| --- | --- |
| Daily streaks, "don't break the chain" | Loss aversion; the opposite of "recovery over punishment". |
| Points, XP, levels | Turns closing loops into a number to optimise. |
| Withering plants, sad mascots | Guilt. |
| Notifications about rewards or "come back" pushes | Nagging; breaks calm notifications. |
| Rewarding captures or app opens | Inflates the inbox; vanity engagement. |
| Leaderboards or sharing scores | No network, and comparison harms. |
| Variable-ratio "loot" rewards | Manipulative. |
| Negative comparisons ("down from last week") | Discouraging. |

### 6.11 Implementation outline

- `lib/domain/grove.dart`: pure functions that build a `GroveState` from
  items, review sessions and day records for a season. Easy to unit-test with
  fixed dates.
- `lib/domain/field_notes.dart`: an enum of notes, each with a predicate over
  app state. Unlocked note ids stored in `AppSettings` (like `seenTips`), so no
  migration and they travel with backups.
- `lib/presentation/grove/`: `grove_screen.dart`, `grove_painter.dart`
  (CustomPainter, seeded randomness per element id so the layout is stable
  between launches), `cairn_screen.dart`, `look_back.dart`.
- Painting performance: cache the painted scene as a picture, repaint only on
  change; cap elements per season with clustering ("a meadow of 40 flowers")
  so a heavy user's Grove stays fast.
- Settings: `groveEnabled` (default **on** for new users after onboarding asks
  "Would you like to see your progress as a growing clearing?", default
  **off** for beta users who upgrade, so nothing changes unasked).
- Goldens for each season × light/dark × reduced-motion, and semantics: the
  Grove has a text description for TalkBack ("Your clearing: 9 trees, 6
  wildflowers, a stream and a bench").

---

## 7. Accessibility, languages and polish

| Change | Pri | Size |
| --- | --- | --- |
| **High-contrast theme** (beyond AA, aiming for AAA text pairs) selectable in Settings › Display. | P2 | M |
| **Dyslexia-friendly spacing** option: more line and letter spacing on body text. Atkinson Hyperlegible already helps. | P3 | S |
| **Text size preview** in Settings, showing a Today row at the chosen size. | P3 | S |
| **TalkBack audit of new gestures**: every swipe, drag and long-press has a semantics action equivalent; covered by widget tests. | P1 | S per feature |
| **Switch Access / keyboard focus order** verified on Today, Inbox and capture. | P2 | S |
| **More languages**: Marathi, Gujarati, Bengali, Tamil, Spanish, as community translations. Add a `docs/translating.md` and a lint test that fails on missing keys. | P2 | M |
| **RTL readiness** (Arabic, Urdu): audit `EdgeInsets.fromLTRB` uses (several exist, e.g. `capture_sheet.dart`) and replace with `EdgeInsetsDirectional`. | P2 | M |
| **Parser localisation**: date words per language live beside the ARB files, so translators can add them. | P2 | M |
| **Copy review**: words testers found confusing (the usability guide lists Clarify, Someday, Waiting, carried over, must-do) get one-line inline explanations on first sight. | P1 | S |

---

## 8. Engineering foundations

These make the features above cheaper and safer to build.

| Change | Why | Pri | Size |
| --- | --- | --- | --- |
| **Split `item_screen.dart`** (582 lines) into header, plan section, details section and actions widgets. | It's about to gain chips, attachments and activity. | P1 | M |
| **Item event log** table (§9) written by `ItemActions` on each transition. | Powers activity lines, lanterns, insights and smarter undo. | P2 | M |
| **Feature flags** in `AppSettings` for unfinished features, toggled from a hidden developer screen in debug builds. | Ship parts behind flags; test on the `v1.x` branch. | P1 | S |
| **Performance budget**: Today builds in < 16 ms with 2,000 open items; add a benchmark test seeded with a large database. | Heavy users exist; the Grove and filters add work. | P2 | M |
| **Background work audit**: one scheduler entry point for reminders, digest, auto-backup and day records, with battery-aware constraints. | Avoid several overlapping jobs as features grow. | P2 | M |
| **Golden coverage** for every new screen in both themes and at 200% text. | Keeps Glade consistent. | P1 | ongoing |
| **Integration tests**: parse-capture-to-Today; multi-select reschedule; auto-backup then restore; review with Look back. | Covers the riskiest new flows end to end. | P1 | M |
| **Backup format version bump** with forward-compatible readers, so a v1.2 backup restores on v1.1 (ignoring unknown fields) and vice versa. | Backups are the user's only safety net. | P1 | S |
| **Offline check in CI**: a test that fails if `INTERNET` appears in the merged release manifest. | Protects the core promise as dependencies change. | P1 | S |

---

## 9. Data model changes

Summarised so migrations can be planned in one or two schema bumps rather
than one per feature. Bump `schemaVersion` in `lib/data/db/database.dart`
and run `dart run drift_dev make-migrations` as the README describes.

### Schema v4 (with release 1.2)

| Table | Change | For |
| --- | --- | --- |
| `items` | `effort INTEGER NULL` (minutes) | §5.3 |
| `items` | `firstStep TEXT NULL` | Focus first step, §4.11 |
| `item_contexts` (new) | `itemId`, `contextId` | §5.3 |
| `contexts` (new) | `id`, `name`, `icon`, `sortOrder`, `updatedAt` | §5.3 |
| `day_records` (new) | `date` PK, `mustDoPlanned`, `mustDoDone`, `allClear BOOL`, `updatedAt` | Birds in the Grove; insights. Written once at day rollover. |
| `item_events` (new) | `id`, `itemId`, `kind` (captured/planned/carried/waiting/resolved/done/reopened), `at`, `data JSON` | Activity, lanterns, insights, undo history |

### Schema v5 (with release 1.3)

| Table | Change | For |
| --- | --- | --- |
| `lists` | `outcome TEXT NULL`, `targetDate TEXT NULL`, `isProject BOOL` | §5.4 |
| `lists` | `colour TEXT NULL`, `pinned BOOL` | §4.8 |
| `attachments` (new) | `id`, `itemId`, `path`, `mime`, `createdAt` | Photos, §4.6 |
| `saved_searches` (new) | `id`, `name`, `filter JSON`, `sortOrder` | §4.9 |

### Settings only (no migration)

`groveEnabled`, `fieldNotes` (set of ids), `invitationsEnabled`,
`hemisphere`, `seasonStyle` (spring/monsoon), `themeVariant`,
`unlockAllThemes`, `parseCapture`, `parsedSkipInbox`, `autoBackupEnabled`,
`autoBackupFolderUri`, `backupPassphraseSet`, `appLock`, `lockAfter`,
`hideOnLockScreen`, `soundsEnabled`, `swipeActions`, `focusTimebox`,
`reviewLength`. All follow the existing `AppSettings.fromJson` fallback
pattern.

All new tables carry `updatedAt` like the existing ones, keeping the door
open for the future sync layer the comment in `tables.dart` mentions.

---

## 10. Roadmap

Releases are sized for one developer working part-time, about 4–6 weeks
each. Each release ends with a soak test (`docs/beta/soak-test.md`) and a
Hindi translation pass.

### Release 1.2: "Faster in, easier out"

Goal: cut taps for the commonest actions and make data safe.

- Smart capture parsing, English and Hindi (§5.1)
- Capture straight to Today / This week (§4.4)
- Multi-select and bulk actions (§4.1)
- Drag to reorder (§4.1)
- "Clarify all" in the Inbox (§4.3)
- Carried-over "Decide these" (§4.2)
- "All clear" moment (§4.2)
- Automatic local backups with optional encryption (§5.5)
- App shortcuts (§4.1), lock-screen privacy (§4.13)
- Interactive Today widget (§4.13)
- Foundations: item screen split, feature flags, offline CI check, backup
  version bump

**Done when:** the usability task "Get *buy stamps on Friday* into Today
from the home screen" takes ≤ 8 s median with no extra taps after typing;
a restore from an automatic backup passes the integration test.

### Release 1.3: "See your progress"

Goal: introduce the Grove and make finishing feel good.

- The Grove, Cairn and season cards (§6.2–6.4)
- Look back at the end of the review, quick vs. full review (§6.5, §4.10)
- Field notes (§6.6)
- Focus first step and "I'm stuck" (§4.11)
- Done-means examples, clarify back-button fix (§4.5)
- Item event log and day records (schema v4)
- Copy review for confusing words (§7)

**Done when:** in a 5-person session, at least 4 describe the Grove as
"encouraging" or similar and none as "pressure" or "guilt"; the beta survey's
Q7 ("Did anything make you feel guilty or nagged?") gets no Grove mentions.

### Release 1.4: "Plan for the moment"

- Effort and context, "Fits now" chips, "I have time" sheet (§5.3)
- Plan-my-day prompt and Tomorrow peek (§4.2)
- Month view and drag-to-day in Upcoming (§4.7)
- Shopping mode for errands lists (§4.8)
- Voice capture, on-device only (§5.2)
- Invitations (§6.7) and Glade theme variants (§6.8)
- App lock (§5.6), device-to-device move (§5.7)

### Release 2.0: "Your clearing"

- Projects, lightly (§5.4), schema v5
- Saved searches (§4.9), list colours and pins (§4.8)
- Photo attachments (§4.6)
- Local insights page (§5.9)
- Flexible routines (§5.8)
- Grove widget, resizable widgets (§4.13)
- More languages and RTL (§7)
- iOS port (the README already plans "iOS later"; the domain and data layers
  are platform-neutral, but widgets, notifications, speech and the Quick
  Settings tile need native equivalents)

### Priority overview

| Feature | Impact | Effort | Release |
| --- | --- | --- | --- |
| Smart capture parsing | High | L | 1.2 |
| Multi-select / bulk | High | M | 1.2 |
| Automatic backups | High (trust) | M | 1.2 |
| Interactive widget | High | M | 1.2 |
| Clarify all | Medium | M | 1.2 |
| The Grove + Cairn | High (motivation) | L | 1.3 |
| Look back | Medium | M | 1.3 |
| Field notes | Medium (discovery) | S | 1.3 |
| Effort / context | Medium | M | 1.4 |
| Voice capture | Medium | M | 1.4 |
| Projects | Medium | M | 2.0 |
| Attachments | Low–medium | L | 2.0 |

---

## 11. Measuring success without telemetry

Clearing collects nothing, so measurement stays in person and on-device,
as the beta kit already does.

**Additions to the beta survey** (`docs/beta/survey.md`):

- "How did the growing clearing (the Grove) make you feel?" Encouraged ·
  Neutral · Pressured · Didn't notice · Turned it off.
- "How often did Clearing understand the date or list you typed?" Almost
  always · Usually · Sometimes · Rarely.
- "Have you lost data, or worried about losing it?" Yes / No / Worried.

**Additions to the usability sessions** (`docs/beta/usability-sessions.md`):

| Task | Target |
| --- | --- |
| "Add *pay rent every 1st, remind me the day before*" by typing only. | 4 of 5 unaided |
| "Move these five inbox items to this week, at once." | ≤ 30 s median |
| "Find something you finished last week." | 4 of 5 unaided |
| "You have 15 minutes. Find something to do." (1.4) | ≤ 20 s median |

**On-device, user-visible only:** the insights page (§5.9) lets users judge
for themselves. A "Share my anonymous stats" button can export a small JSON
summary through the share sheet *only when the user taps it*, for testers who
want to send it with feedback, next to the existing error log.

---

## 12. Risks and open decisions

| Risk / decision | Notes | Proposed answer |
| --- | --- | --- |
| **Gamification undermines the calm brand.** | Biggest product risk. | Opt-in at onboarding, off for upgrading users, banned-patterns list (§6.10), and the 1.3 "done when" check before going further. |
| **Focus timebox contradicts "no timer".** | The focus view's doc comment states this as intentional. | Ship only behind a setting, off by default, without recording anything. Needs the maintainer's call. |
| **Parsing eats words wrongly.** | "Meet Will at March" etc. | Always show chips before saving; tapping restores the words; per-language test tables; one-tap off. |
| **Voice capture accidentally uses the cloud.** | Older APIs fall back to Google's online recogniser. | Use only `createOnDeviceSpeechRecognizer`; hide the button otherwise; covered in the offline CI check and manual soak test. |
| **Encrypted backup passphrase forgotten.** | Data unrecoverable. | Clear warning; offer an unencrypted copy option; no "reset" exists by design. |
| **Feature creep.** | The README says "deliberately not feature-dense". | Every feature in this plan is behind progressive disclosure (appears after use or a tip), and §1's "serves one of the four verbs" test. Review the list after each beta round and cut freely. |
| **Grove performance for heavy users.** | Thousands of completions per year. | Clustering and cached pictures (§6.11), benchmark test. |
| **Seasons and hemispheres.** | Southern users get winter in July. | Hemisphere setting; Monsoon option; default from device locale's region. |
| **Translations lag features.** | Hindi must not show English fallbacks. | Missing-key lint test fails CI; Hindi pass is in each release's exit checklist. |

---

## Implementation status

Everything in §4–§7 and the foundations in §8 is built, tested (unit,
widget, golden and end-to-end flows) and translated into Hindi. Where the
build differs from the plan:

| Plan | What was built, and why |
| --- | --- |
| Two schema bumps (v4, v5) | One bump to **v4** with every new table and column, since everything shipped together. Migration tests cover v1–v3 → v4. |
| Interactive Today widget (§4.13) | The Today widget already ticked items off. Added an **Inbox line**, a small **Next thing** widget and a **Grove** widget instead. |
| Offline check in CI (§8) | Already existed (`android-release` job). Kept as is. |
| Invitations detected automatically (§6.7) | Taken up with a **"Did it"** tap. Detecting them would mean tracking more than the app does, and the honour system fits the tone. |
| Day records written live (§9) | Worked out **after the day** from the items themselves (plus "all clear" when seen live), so nothing is tracked as the day goes. Backfills up to a week. |
| Interactive guides (§4.12) | "Show me" on each guide opens the real tab with a **coach mark** on the capture button or the tab, rather than a step-by-step walkthrough of every control. |
| Focus timebox (§4.11, open decision) | Built **off by default**, behind Settings › Focus and reset, shown as the sky clearing, nothing recorded. Remove it if the maintainer decides against. |
| Grove default (§6.11, open decision) | Asked in the welcome with no answer pre-selected; **off** unless chosen. People upgrading keep it off. |
| Swipe actions everywhere (§4.1) | On Today, This week, lists, Upcoming, Search and smart lists; the Inbox keeps its own richer swipes. |
| Undo history (§4.1) | In memory for the session, as planned; not persisted. |
| More languages (§7) | **Not added**: they need human translators. `docs/translating.md` and a test that fails on any missing string or placeholder are in place. |
| iOS port (§10, 2.0) | **Not done.** The domain and data layers are platform-neutral; widgets, speech, the tile, shortcuts, folder access and notifications need native iOS work and an iPhone to test on. |

## Appendix: ideas considered and rejected

| Idea | Why not |
| --- | --- |
| Cloud sync / account | Breaks the offline promise. Local auto-backup to a user-chosen folder covers most of the need. |
| AI suggestions via an API | Network. Rule-based parsing and local history cover the useful parts. |
| On-device LLM for clarifying | Large download bundled into the APK, slow on mid-range phones; revisit when Android ships a standard on-device model API that works fully offline. |
| Daily streaks | Explicitly against the app's principles. |
| Pomodoro tracker with stats | Turns Focus into a productivity meter; the optional timebox (§4.11) is the most that fits. |
| Social accountability / sharing progress | Network, comparison, and privacy concerns. |
| Eisenhower matrix view | Duplicates must-do + deadlines with more decisions per item. |
| Colour-coded priority levels (P1–P4) | Must-do already is the priority system; more levels reintroduce the overwhelm the cap prevents. |
| Red overdue badges | Against "recovery over punishment". |
| Reading the device calendar | Needs a sensitive permission for modest value; one-way `.ics` export first. |

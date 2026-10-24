/// Lifecycle of an item (PRD §3). Every item has exactly one status.
enum ItemStatus {
  /// Captured but not yet clarified.
  inbox,

  /// A commitment the user intends to do.
  active,

  /// Handed to someone else; tracked with a person and follow-up date.
  waiting,

  /// An idea, not a commitment. Never shown in Today or Upcoming.
  someday,
  done,

  /// Soft-deleted; purged 30 days after [Item.trashedAt].
  trashed,
}

/// Soft time horizons for active items without a date.
///
/// A do-date always wins over a horizon, so the effective "When" of an item is
/// derived by [Item.when].
enum WhenHorizon { today, thisWeek, anytime }

/// The effective "When" dimension of an active item.
enum When { today, thisWeek, onDate, anytime }

enum ListKind { lifeAdmin, errands, user }

enum RepeatFrequency { daily, weekly, monthly }

enum RepeatMode { fixed, afterCompletion }

/// What happens to an occurrence whose date passes without completion.
enum OnMissed { carryOver, skip }

enum TemplateKind { checklist, routine, defaults }

enum ReviewKind { weekly, reset }

/// Notification intensity (FR-09). Gentle is the default: nothing nags.
enum NotificationIntensity { off, gentle, standard }

enum ThemePreference { system, light, dark }

/// Built-in contexts are translated by kind; user ones keep their name.
enum ContextKind { home, out, computer, phone, lowEnergy, user }

/// Entries in an item's activity line.
enum ItemEventKind {
  captured,
  planned,
  waiting,

  /// A waiting item came back: done, or planned again.
  resolved,
  someday,
  done,
  reopened,
  trashed,
}

/// Which half of the world the Grove's seasons follow.
enum Hemisphere { north, south }

/// The Grove's wet season: a temperate spring, or a monsoon.
enum SeasonStyle { spring, monsoon }

/// Glade's colour variants. Morning and Dusk are [glade]; the rest are
/// unlocked through the Grove, or all at once in Settings.
enum GladeVariant { glade, autumn, monsoon, winter, nightSky }

/// What a swipe on an item does (outside the Inbox, which has its own).
enum SwipeAction {
  none,
  done,
  tomorrow,
  today,
  thisWeek,
  pickDate,
  someday,
  delete,
}

/// How long the weekly review is: ask each time, or always quick or full.
enum ReviewLength { ask, quick, full }

/// Presets from "Make Clearing yours".
enum ClearingStyle { minimal, gentle, encouraging }

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

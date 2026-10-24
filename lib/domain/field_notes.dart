/// Field notes (Grove, §6.6): one-time discoveries, each found by trying a
/// part of the app once. No counts, no percentages, nothing to keep up.
enum FieldNote {
  /// First item captured.
  firstLight,

  /// First item clarified into a list.
  aHomeForEverything,

  /// First "Waiting for".
  outOfYourHands,

  /// First repeating item.
  theLongView,

  /// First overwhelm reset finished.
  deepBreath,

  /// First weekly review finished.
  thePath,

  /// First item finished from Focus.
  justOneThing,

  /// First backup.
  safeKeeping,

  /// First capture from the widget, a share, a shortcut or by voice.
  fromTheDoorstep,

  /// First item closed after waiting 30 days or more.
  oldTab,

  /// First day with everything on Today done.
  openSky,

  /// A review in each season of a year, at any pace.
  fourSeasons,
}

/// Days an item must have waited for closing it to count as an old tab.
const oldTabDays = 30;

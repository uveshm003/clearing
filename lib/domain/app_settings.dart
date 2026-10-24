import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'enums.dart';
import 'local_date.dart';

/// User preferences (FR-21). Stored as one JSON value per key so new settings
/// never need a schema migration, and all of them travel with an export.
@immutable
class AppSettings {
  const AppSettings({
    this.weekStart = DateTime.monday,
    this.reviewWeekday = DateTime.sunday,
    this.reviewTime = 18 * 60,
    this.reviewReminder = true,
    this.morningDigest = false,
    this.morningDigestTime = 8 * 60,
    this.mustDoCap = 3,
    this.notificationIntensity = NotificationIntensity.gentle,
    this.quietHoursStart = 22 * 60,
    this.quietHoursEnd = 7 * 60,
    this.autoArchiveDays = 7,
    this.theme = ThemePreference.system,
    this.starterSuggestions = true,
    this.exportReminderDays = 30,
    this.lastExportAt,
    this.inboxBadge = true,
    this.onboardingDone = false,
    this.showTips = true,
    this.seenTips = const {},
    this.groveEnabled = false,
    this.groveAsked = false,
    this.fieldNotes = const {},
    this.invitationsEnabled = true,
    this.invitationsDone = const {},
    this.hemisphere = Hemisphere.north,
    this.seasonStyle = SeasonStyle.spring,
    this.themeVariant = GladeVariant.glade,
    this.unlockAllThemes = false,
    this.highContrast = false,
    this.roomyText = false,
    this.parseCapture = true,
    this.parsedSkipInbox = true,
    this.autoBackup = false,
    this.autoBackupFolder,
    this.autoBackupEncrypt = false,
    this.lastAutoBackupAt,
    this.appLock = false,
    this.lockAfterMinutes = 1,
    this.hideOnLockScreen = false,
    this.sounds = false,
    this.swipeStart = SwipeAction.done,
    this.swipeEnd = SwipeAction.tomorrow,
    this.focusTimebox = false,
    this.breathingOpener = true,
    this.reviewLength = ReviewLength.ask,
    this.reviewPrompts = const [],
    this.winsPrompt = true,
    this.planMyDay = true,
    this.lastPlanPromptOn,
    this.recentSearches = const [],
    this.lastSeenVersion,
    this.style,
    this.flags = const {},
  }) : assert(mustDoCap >= minMustDoCap && mustDoCap <= maxMustDoCap);

  static const minMustDoCap = 1;
  static const maxMustDoCap = 5;

  /// Recent searches kept for the search screen.
  static const maxRecentSearches = 6;

  /// [DateTime.weekday] numbering: 1 = Monday.
  final int weekStart;
  final int reviewWeekday;

  /// Minutes from local midnight.
  final int reviewTime;

  /// A gentle weekly nudge to review, at [reviewWeekday] and [reviewTime].
  final bool reviewReminder;

  /// One notification each morning summing up Today. Off by default: nothing
  /// nags unless asked to (PRD §2.1).
  final bool morningDigest;

  /// Minutes from local midnight.
  final int morningDigestTime;
  final int mustDoCap;
  final NotificationIntensity notificationIntensity;
  final int quietHoursStart;
  final int quietHoursEnd;
  final int autoArchiveDays;
  final ThemePreference theme;
  final bool starterSuggestions;

  /// Null turns the export reminder off.
  final int? exportReminderDays;

  /// When a backup was last exported, which the export reminder counts from.
  final DateTime? lastExportAt;
  final bool inboxBadge;

  /// The welcome has been finished or skipped. It shows on first launch
  /// only, and can be replayed from Settings › Help.
  final bool onboardingDone;

  /// One-time tips shown where they matter ("Tips as you go").
  final bool showTips;

  /// Tips already dismissed, by id.
  final Set<String> seenTips;

  /// The Grove: progress shown as a growing clearing. Opt-in, and off for
  /// people upgrading from a version without it, so nothing changes unasked.
  final bool groveEnabled;

  /// The welcome asked whether to show the Grove (so it doesn't again).
  final bool groveAsked;

  /// Field notes found, by id.
  final Set<String> fieldNotes;

  /// One optional invitation a week on Today.
  final bool invitationsEnabled;

  /// Invitations taken up, as `weekStartIso:id`.
  final Set<String> invitationsDone;
  final Hemisphere hemisphere;
  final SeasonStyle seasonStyle;
  final GladeVariant themeVariant;

  /// Every Glade variant, without earning them.
  final bool unlockAllThemes;

  /// Stronger contrast than AA, for low vision.
  final bool highContrast;

  /// More space between lines and letters, which some readers find easier.
  final bool roomyText;

  /// Reads dates, lists and flags out of what's typed in capture.
  final bool parseCapture;

  /// A capture with a date goes straight to Today or Upcoming.
  final bool parsedSkipInbox;

  /// A daily backup into [autoBackupFolder], kept for a week or so.
  final bool autoBackup;

  /// The folder chosen through the system picker, as a content URI.
  final String? autoBackupFolder;

  /// Encrypts automatic backups with a passphrase kept on this phone.
  final bool autoBackupEncrypt;
  final DateTime? lastAutoBackupAt;

  /// Asks for the fingerprint, face or screen lock to open the app.
  final bool appLock;

  /// Minutes away before the lock comes back; 0 locks on every leave.
  final int lockAfterMinutes;

  /// Notifications show "Reminder" instead of the item's title on the lock
  /// screen.
  final bool hideOnLockScreen;

  /// A short sound on "all clear" and a finished review.
  final bool sounds;

  /// Swipe from the start edge (right, in left-to-right languages) on an
  /// item outside the Inbox.
  final SwipeAction swipeStart;

  /// Swipe from the end edge.
  final SwipeAction swipeEnd;

  /// Offers a soft timebox in Focus. Nothing is recorded.
  final bool focusTimebox;

  /// Offers a few breaths before the overwhelm reset.
  final bool breathingOpener;
  final ReviewLength reviewLength;

  /// The user's own checks, added to the weekly review.
  final List<String> reviewPrompts;

  /// Asks "anything you're glad you did?" at the end of the review.
  final bool winsPrompt;

  /// Offers to pick a few things for today from This week each morning.
  final bool planMyDay;

  /// The day the plan-my-day prompt last showed, so it shows once a day.
  final LocalDate? lastPlanPromptOn;

  /// Newest first.
  final List<String> recentSearches;

  /// The app version whose "What's new" was last shown.
  final String? lastSeenVersion;

  /// The preset last picked in "Make Clearing yours".
  final ClearingStyle? style;

  /// Unfinished features switched on from the developer screen.
  final Set<String> flags;

  /// Whether [variant] may be picked.
  bool canUse(GladeVariant variant, Set<GladeVariant> earned) =>
      variant == GladeVariant.glade ||
      unlockAllThemes ||
      earned.contains(variant) ||
      // High contrast is never gated behind a reward.
      (variant == GladeVariant.winter && highContrast);

  AppSettings copyWith({
    int? weekStart,
    int? reviewWeekday,
    int? reviewTime,
    bool? reviewReminder,
    bool? morningDigest,
    int? morningDigestTime,
    int? mustDoCap,
    NotificationIntensity? notificationIntensity,
    int? quietHoursStart,
    int? quietHoursEnd,
    int? autoArchiveDays,
    ThemePreference? theme,
    bool? starterSuggestions,
    int? Function()? exportReminderDays,
    DateTime? Function()? lastExportAt,
    bool? inboxBadge,
    bool? onboardingDone,
    bool? showTips,
    Set<String>? seenTips,
    bool? groveEnabled,
    bool? groveAsked,
    Set<String>? fieldNotes,
    bool? invitationsEnabled,
    Set<String>? invitationsDone,
    Hemisphere? hemisphere,
    SeasonStyle? seasonStyle,
    GladeVariant? themeVariant,
    bool? unlockAllThemes,
    bool? highContrast,
    bool? roomyText,
    bool? parseCapture,
    bool? parsedSkipInbox,
    bool? autoBackup,
    String? Function()? autoBackupFolder,
    bool? autoBackupEncrypt,
    DateTime? Function()? lastAutoBackupAt,
    bool? appLock,
    int? lockAfterMinutes,
    bool? hideOnLockScreen,
    bool? sounds,
    SwipeAction? swipeStart,
    SwipeAction? swipeEnd,
    bool? focusTimebox,
    bool? breathingOpener,
    ReviewLength? reviewLength,
    List<String>? reviewPrompts,
    bool? winsPrompt,
    bool? planMyDay,
    LocalDate? Function()? lastPlanPromptOn,
    List<String>? recentSearches,
    String? Function()? lastSeenVersion,
    ClearingStyle? Function()? style,
    Set<String>? flags,
  }) => AppSettings(
    weekStart: weekStart ?? this.weekStart,
    reviewWeekday: reviewWeekday ?? this.reviewWeekday,
    reviewTime: reviewTime ?? this.reviewTime,
    reviewReminder: reviewReminder ?? this.reviewReminder,
    morningDigest: morningDigest ?? this.morningDigest,
    morningDigestTime: morningDigestTime ?? this.morningDigestTime,
    mustDoCap: mustDoCap ?? this.mustDoCap,
    notificationIntensity: notificationIntensity ?? this.notificationIntensity,
    quietHoursStart: quietHoursStart ?? this.quietHoursStart,
    quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    autoArchiveDays: autoArchiveDays ?? this.autoArchiveDays,
    theme: theme ?? this.theme,
    starterSuggestions: starterSuggestions ?? this.starterSuggestions,
    exportReminderDays: exportReminderDays != null
        ? exportReminderDays()
        : this.exportReminderDays,
    lastExportAt: lastExportAt != null ? lastExportAt() : this.lastExportAt,
    inboxBadge: inboxBadge ?? this.inboxBadge,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    showTips: showTips ?? this.showTips,
    seenTips: seenTips ?? this.seenTips,
    groveEnabled: groveEnabled ?? this.groveEnabled,
    groveAsked: groveAsked ?? this.groveAsked,
    fieldNotes: fieldNotes ?? this.fieldNotes,
    invitationsEnabled: invitationsEnabled ?? this.invitationsEnabled,
    invitationsDone: invitationsDone ?? this.invitationsDone,
    hemisphere: hemisphere ?? this.hemisphere,
    seasonStyle: seasonStyle ?? this.seasonStyle,
    themeVariant: themeVariant ?? this.themeVariant,
    unlockAllThemes: unlockAllThemes ?? this.unlockAllThemes,
    highContrast: highContrast ?? this.highContrast,
    roomyText: roomyText ?? this.roomyText,
    parseCapture: parseCapture ?? this.parseCapture,
    parsedSkipInbox: parsedSkipInbox ?? this.parsedSkipInbox,
    autoBackup: autoBackup ?? this.autoBackup,
    autoBackupFolder: autoBackupFolder != null
        ? autoBackupFolder()
        : this.autoBackupFolder,
    autoBackupEncrypt: autoBackupEncrypt ?? this.autoBackupEncrypt,
    lastAutoBackupAt: lastAutoBackupAt != null
        ? lastAutoBackupAt()
        : this.lastAutoBackupAt,
    appLock: appLock ?? this.appLock,
    lockAfterMinutes: lockAfterMinutes ?? this.lockAfterMinutes,
    hideOnLockScreen: hideOnLockScreen ?? this.hideOnLockScreen,
    sounds: sounds ?? this.sounds,
    swipeStart: swipeStart ?? this.swipeStart,
    swipeEnd: swipeEnd ?? this.swipeEnd,
    focusTimebox: focusTimebox ?? this.focusTimebox,
    breathingOpener: breathingOpener ?? this.breathingOpener,
    reviewLength: reviewLength ?? this.reviewLength,
    reviewPrompts: reviewPrompts ?? this.reviewPrompts,
    winsPrompt: winsPrompt ?? this.winsPrompt,
    planMyDay: planMyDay ?? this.planMyDay,
    lastPlanPromptOn: lastPlanPromptOn != null
        ? lastPlanPromptOn()
        : this.lastPlanPromptOn,
    recentSearches: recentSearches ?? this.recentSearches,
    lastSeenVersion: lastSeenVersion != null
        ? lastSeenVersion()
        : this.lastSeenVersion,
    style: style != null ? style() : this.style,
    flags: flags ?? this.flags,
  );

  Map<String, Object?> toJson() => {
    'weekStart': weekStart,
    'reviewWeekday': reviewWeekday,
    'reviewTime': reviewTime,
    'reviewReminder': reviewReminder,
    'morningDigest': morningDigest,
    'morningDigestTime': morningDigestTime,
    'mustDoCap': mustDoCap,
    'notificationIntensity': notificationIntensity.name,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
    'autoArchiveDays': autoArchiveDays,
    'theme': theme.name,
    'starterSuggestions': starterSuggestions,
    'exportReminderDays': exportReminderDays,
    'lastExportAt': lastExportAt?.toIso8601String(),
    'inboxBadge': inboxBadge,
    'onboardingDone': onboardingDone,
    'showTips': showTips,
    'seenTips': seenTips.toList()..sort(),
    'groveEnabled': groveEnabled,
    'groveAsked': groveAsked,
    'fieldNotes': fieldNotes.toList()..sort(),
    'invitationsEnabled': invitationsEnabled,
    'invitationsDone': invitationsDone.toList()..sort(),
    'hemisphere': hemisphere.name,
    'seasonStyle': seasonStyle.name,
    'themeVariant': themeVariant.name,
    'unlockAllThemes': unlockAllThemes,
    'highContrast': highContrast,
    'roomyText': roomyText,
    'parseCapture': parseCapture,
    'parsedSkipInbox': parsedSkipInbox,
    'autoBackup': autoBackup,
    'autoBackupFolder': autoBackupFolder,
    'autoBackupEncrypt': autoBackupEncrypt,
    'lastAutoBackupAt': lastAutoBackupAt?.toIso8601String(),
    'appLock': appLock,
    'lockAfterMinutes': lockAfterMinutes,
    'hideOnLockScreen': hideOnLockScreen,
    'sounds': sounds,
    'swipeStart': swipeStart.name,
    'swipeEnd': swipeEnd.name,
    'focusTimebox': focusTimebox,
    'breathingOpener': breathingOpener,
    'reviewLength': reviewLength.name,
    'reviewPrompts': reviewPrompts,
    'winsPrompt': winsPrompt,
    'planMyDay': planMyDay,
    'lastPlanPromptOn': lastPlanPromptOn?.toIso(),
    'recentSearches': recentSearches,
    'lastSeenVersion': lastSeenVersion,
    'style': style?.name,
    'flags': flags.toList()..sort(),
  };

  /// Unknown or malformed values fall back to defaults, so an older or
  /// hand-edited backup can never stop the app from starting.
  factory AppSettings.fromJson(Map<String, Object?> json) {
    const d = AppSettings();
    T read<T>(String key, T fallback) =>
        json[key] is T ? json[key] as T : fallback;
    E readEnum<E extends Enum>(String key, List<E> values, E fallback) =>
        values.where((v) => v.name == json[key]).firstOrNull ?? fallback;
    Set<String> readSet(String key) => {
      for (final id in read<List<Object?>>(key, const []))
        if (id is String) id,
    };
    List<String> readList(String key) => [
      for (final value in read<List<Object?>>(key, const []))
        if (value is String) value,
    ];
    LocalDate? readDate(String key) {
      final value = json[key];
      if (value is! String) return null;
      try {
        return LocalDate.parse(value);
      } on FormatException {
        return null;
      }
    }

    return AppSettings(
      weekStart: read('weekStart', d.weekStart),
      reviewWeekday: read('reviewWeekday', d.reviewWeekday),
      reviewTime: read('reviewTime', d.reviewTime),
      reviewReminder: read('reviewReminder', d.reviewReminder),
      morningDigest: read('morningDigest', d.morningDigest),
      morningDigestTime: read('morningDigestTime', d.morningDigestTime),
      mustDoCap: read(
        'mustDoCap',
        d.mustDoCap,
      ).clamp(minMustDoCap, maxMustDoCap),
      notificationIntensity: readEnum(
        'notificationIntensity',
        NotificationIntensity.values,
        d.notificationIntensity,
      ),
      quietHoursStart: read('quietHoursStart', d.quietHoursStart),
      quietHoursEnd: read('quietHoursEnd', d.quietHoursEnd),
      autoArchiveDays: read('autoArchiveDays', d.autoArchiveDays),
      theme: readEnum('theme', ThemePreference.values, d.theme),
      starterSuggestions: read('starterSuggestions', d.starterSuggestions),
      exportReminderDays: json.containsKey('exportReminderDays')
          ? json['exportReminderDays'] as int?
          : d.exportReminderDays,
      lastExportAt: DateTime.tryParse('${json['lastExportAt']}'),
      inboxBadge: read('inboxBadge', d.inboxBadge),
      onboardingDone: read('onboardingDone', d.onboardingDone),
      showTips: read('showTips', d.showTips),
      seenTips: readSet('seenTips'),
      groveEnabled: read('groveEnabled', d.groveEnabled),
      groveAsked: read('groveAsked', d.groveAsked),
      fieldNotes: readSet('fieldNotes'),
      invitationsEnabled: read('invitationsEnabled', d.invitationsEnabled),
      invitationsDone: readSet('invitationsDone'),
      hemisphere: readEnum('hemisphere', Hemisphere.values, d.hemisphere),
      seasonStyle: readEnum('seasonStyle', SeasonStyle.values, d.seasonStyle),
      themeVariant: readEnum(
        'themeVariant',
        GladeVariant.values,
        d.themeVariant,
      ),
      unlockAllThemes: read('unlockAllThemes', d.unlockAllThemes),
      highContrast: read('highContrast', d.highContrast),
      roomyText: read('roomyText', d.roomyText),
      parseCapture: read('parseCapture', d.parseCapture),
      parsedSkipInbox: read('parsedSkipInbox', d.parsedSkipInbox),
      autoBackup: read('autoBackup', d.autoBackup),
      autoBackupFolder: read<String?>('autoBackupFolder', null),
      autoBackupEncrypt: read('autoBackupEncrypt', d.autoBackupEncrypt),
      lastAutoBackupAt: DateTime.tryParse('${json['lastAutoBackupAt']}'),
      appLock: read('appLock', d.appLock),
      lockAfterMinutes: read('lockAfterMinutes', d.lockAfterMinutes),
      hideOnLockScreen: read('hideOnLockScreen', d.hideOnLockScreen),
      sounds: read('sounds', d.sounds),
      swipeStart: readEnum('swipeStart', SwipeAction.values, d.swipeStart),
      swipeEnd: readEnum('swipeEnd', SwipeAction.values, d.swipeEnd),
      focusTimebox: read('focusTimebox', d.focusTimebox),
      breathingOpener: read('breathingOpener', d.breathingOpener),
      reviewLength: readEnum(
        'reviewLength',
        ReviewLength.values,
        d.reviewLength,
      ),
      reviewPrompts: readList('reviewPrompts'),
      winsPrompt: read('winsPrompt', d.winsPrompt),
      planMyDay: read('planMyDay', d.planMyDay),
      lastPlanPromptOn: readDate('lastPlanPromptOn'),
      recentSearches: readList('recentSearches'),
      lastSeenVersion: read<String?>('lastSeenVersion', null),
      style: ClearingStyle.values
          .where((v) => v.name == json['style'])
          .firstOrNull,
      flags: readSet('flags'),
    );
  }

  static const _sets = SetEquality<String>();
  static const _lists = ListEquality<String>();

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.weekStart == weekStart &&
      other.reviewWeekday == reviewWeekday &&
      other.reviewTime == reviewTime &&
      other.reviewReminder == reviewReminder &&
      other.morningDigest == morningDigest &&
      other.morningDigestTime == morningDigestTime &&
      other.mustDoCap == mustDoCap &&
      other.notificationIntensity == notificationIntensity &&
      other.quietHoursStart == quietHoursStart &&
      other.quietHoursEnd == quietHoursEnd &&
      other.autoArchiveDays == autoArchiveDays &&
      other.theme == theme &&
      other.starterSuggestions == starterSuggestions &&
      other.exportReminderDays == exportReminderDays &&
      other.lastExportAt == lastExportAt &&
      other.inboxBadge == inboxBadge &&
      other.onboardingDone == onboardingDone &&
      other.showTips == showTips &&
      _sets.equals(other.seenTips, seenTips) &&
      other.groveEnabled == groveEnabled &&
      other.groveAsked == groveAsked &&
      _sets.equals(other.fieldNotes, fieldNotes) &&
      other.invitationsEnabled == invitationsEnabled &&
      _sets.equals(other.invitationsDone, invitationsDone) &&
      other.hemisphere == hemisphere &&
      other.seasonStyle == seasonStyle &&
      other.themeVariant == themeVariant &&
      other.unlockAllThemes == unlockAllThemes &&
      other.highContrast == highContrast &&
      other.roomyText == roomyText &&
      other.parseCapture == parseCapture &&
      other.parsedSkipInbox == parsedSkipInbox &&
      other.autoBackup == autoBackup &&
      other.autoBackupFolder == autoBackupFolder &&
      other.autoBackupEncrypt == autoBackupEncrypt &&
      other.lastAutoBackupAt == lastAutoBackupAt &&
      other.appLock == appLock &&
      other.lockAfterMinutes == lockAfterMinutes &&
      other.hideOnLockScreen == hideOnLockScreen &&
      other.sounds == sounds &&
      other.swipeStart == swipeStart &&
      other.swipeEnd == swipeEnd &&
      other.focusTimebox == focusTimebox &&
      other.breathingOpener == breathingOpener &&
      other.reviewLength == reviewLength &&
      _lists.equals(other.reviewPrompts, reviewPrompts) &&
      other.winsPrompt == winsPrompt &&
      other.planMyDay == planMyDay &&
      other.lastPlanPromptOn == lastPlanPromptOn &&
      _lists.equals(other.recentSearches, recentSearches) &&
      other.lastSeenVersion == lastSeenVersion &&
      other.style == style &&
      _sets.equals(other.flags, flags);

  @override
  int get hashCode => Object.hashAll([
    weekStart,
    reviewWeekday,
    reviewTime,
    reviewReminder,
    morningDigest,
    morningDigestTime,
    mustDoCap,
    notificationIntensity,
    quietHoursStart,
    quietHoursEnd,
    autoArchiveDays,
    theme,
    starterSuggestions,
    exportReminderDays,
    lastExportAt,
    inboxBadge,
    onboardingDone,
    showTips,
    _sets.hash(seenTips),
    groveEnabled,
    groveAsked,
    _sets.hash(fieldNotes),
    invitationsEnabled,
    _sets.hash(invitationsDone),
    hemisphere,
    seasonStyle,
    themeVariant,
    unlockAllThemes,
    highContrast,
    roomyText,
    parseCapture,
    parsedSkipInbox,
    autoBackup,
    autoBackupFolder,
    autoBackupEncrypt,
    lastAutoBackupAt,
    appLock,
    lockAfterMinutes,
    hideOnLockScreen,
    sounds,
    swipeStart,
    swipeEnd,
    focusTimebox,
    breathingOpener,
    reviewLength,
    _lists.hash(reviewPrompts),
    winsPrompt,
    planMyDay,
    lastPlanPromptOn,
    _lists.hash(recentSearches),
    lastSeenVersion,
    style,
    _sets.hash(flags),
  ]);
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Clearing';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonMore => 'More';

  @override
  String get commonNone => 'None';

  @override
  String get commonFinish => 'Finish';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonName => 'Name';

  @override
  String get whenToday => 'Today';

  @override
  String get whenThisWeek => 'This week';

  @override
  String get whenAnytime => 'Anytime';

  @override
  String get whenPickDate => 'Pick a date';

  @override
  String get whenAnytimeHint => 'No particular day';

  @override
  String get whenQuestion => 'When?';

  @override
  String get tabToday => 'Today';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabLists => 'Lists';

  @override
  String get someday => 'Someday';

  @override
  String get waitingOn => 'Waiting on';

  @override
  String get mustDo => 'Must-do';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String repeatEveryDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String get repeatAfterDone => 'after it’s done';

  @override
  String repeatOnDays(String days) {
    return 'on $days';
  }

  @override
  String repeatOnMonthDay(String day) {
    return 'on the $day';
  }

  @override
  String repeatUntil(String date) {
    return 'until $date';
  }

  @override
  String repeatTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String get offsetAtTime => 'At the time';

  @override
  String offsetMinutes(int count) {
    return '$count min before';
  }

  @override
  String offsetHours(int count) {
    return '$count h before';
  }

  @override
  String offsetDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get notifReviewTitle => 'Time for your weekly review';

  @override
  String get notifReviewBody =>
      'About 15 minutes to clear your head and plan the week.';

  @override
  String get notifBackupTitle => 'Time to back up';

  @override
  String get notifBackupBody =>
      'Export a copy, so a lost phone doesn’t mean lost plans.';

  @override
  String get notifDigestTitle => 'Today';

  @override
  String notifDoneMeans(String text) {
    return 'Done means: $text';
  }

  @override
  String notifBlockTitle(String list) {
    return '$list time';
  }

  @override
  String notifBlockBody(String list) {
    return 'Work through $list in one go.';
  }

  @override
  String notifDigestMustDos(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count must-dos: $titles',
      one: '1 must-do: $titles',
    );
    return '$_temp0';
  }

  @override
  String notifDigestMoreToday(int count) {
    return '$count more today';
  }

  @override
  String notifDigestOnToday(int count) {
    return '$count on Today';
  }

  @override
  String get notifActionDone => 'Done';

  @override
  String get notifActionSnoozeHour => 'Snooze 1 h';

  @override
  String get notifActionTomorrow => 'Tomorrow';

  @override
  String get worksheetDocToday => 'Clearing: today';

  @override
  String get worksheetDocWeek => 'Clearing: week';

  @override
  String worksheetMoreInApp(int count) {
    return '+$count more in the app';
  }

  @override
  String worksheetMore(int count) {
    return '+$count more';
  }

  @override
  String get worksheetBlocks => 'Blocks';

  @override
  String get worksheetAlsoToday => 'Also today';

  @override
  String get worksheetOnYourMind => 'On your mind';

  @override
  String get worksheetAnyDay => 'Any day · on your mind';

  @override
  String worksheetWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get worksheetList => 'List';

  @override
  String worksheetCarriedOver(String item) {
    return '$item (carried over)';
  }

  @override
  String get flowCaptureHint => 'What’s on your mind?';

  @override
  String flowSavedToInbox(int count, String title) {
    return 'Saved $count to Inbox · latest: $title';
  }

  @override
  String get flowItemGone => 'This item no longer exists.';

  @override
  String get focusTitle => 'Focus';

  @override
  String focusDoneMeans(String doneMeans) {
    return 'Done means: $doneMeans';
  }

  @override
  String get focusNotNow => 'Not now';

  @override
  String get focusFinishedTitle => 'One less thing';

  @override
  String get reviewTitle => 'Weekly review';

  @override
  String get reviewResumed => 'Picking up where you left off.';

  @override
  String get reviewStartOver => 'Start over';

  @override
  String get reviewEmptyHeadTitle => 'Empty your head';

  @override
  String get reviewEmptyHeadHint =>
      'Anything not written down yet: errands, worries, replies you owe. One thought at a time.';

  @override
  String get reviewInboxClearTitle => 'Inbox clear';

  @override
  String get reviewInboxClearHint => 'Every item has a place.';

  @override
  String reviewInboxSkipped(int count) {
    return '$count skipped for now. They’ll be here next time.';
  }

  @override
  String reviewInboxLeft(int count) {
    return '$count left in the inbox. Where does this one go?';
  }

  @override
  String get reviewSkipForNow => 'Skip for now';

  @override
  String get reviewWaitingOnChoice => 'Waiting on…';

  @override
  String get reviewAlreadyDone => 'Already done';

  @override
  String get reviewWhoWaitingOn => 'Who are you waiting on?';

  @override
  String get reviewMarkDone => 'Mark done';

  @override
  String get reviewReplan => 'Re-plan';

  @override
  String get reviewLetGo => 'Let go to Someday';

  @override
  String get reviewLastWeekTitle => 'Last week’s open items';

  @override
  String get reviewLastWeekEmpty => 'Nothing left over from last week.';

  @override
  String get reviewLastWeekHint =>
      'This week’s items and anything carried over. Re-plan them, or let them go.';

  @override
  String get reviewWaitingEmpty => 'You’re not waiting on anyone.';

  @override
  String get reviewWaitingHint =>
      'Follow up, mark done, or take it back to do yourself.';

  @override
  String get reviewSomeone => 'Someone';

  @override
  String reviewFollowUpOn(String date) {
    return 'follow up $date';
  }

  @override
  String get reviewFollowUpTooltip => 'Follow up on…';

  @override
  String get reviewTakeBack => 'Take it back';

  @override
  String get reviewNextWeekTitle => 'The next 7 days';

  @override
  String get reviewNextWeekEmpty => 'Nothing dated this coming week.';

  @override
  String get reviewNextWeekHint =>
      'A glance at what’s coming. Tap one to adjust it.';

  @override
  String get reviewSomedayEmpty => 'No ideas parked.';

  @override
  String get reviewSomedayHint =>
      'Optional. Anything here ready to become a plan?';

  @override
  String get reviewMakePlan => 'Make it a plan';

  @override
  String get reviewWhenWillYou => 'When will you do it?';

  @override
  String get reviewCloseTitle => 'That’s the week';

  @override
  String get reviewCloseHint => 'Your head should feel a little lighter.';

  @override
  String reviewCloseSummary(int cleared, int planned) {
    return '$cleared cleared · $planned planned';
  }

  @override
  String reviewCloseSkipped(int skipped) {
    return '$skipped skipped for another time.';
  }

  @override
  String get resetTitle => 'Reset';

  @override
  String get resetMindTitle => 'Everything on your mind';

  @override
  String get resetMindHint =>
      'Get it all out, one thought at a time. Nothing needs deciding yet.';

  @override
  String get resetOnYourPlate => 'Already on your plate';

  @override
  String get resetTodayTitle => 'What must happen today?';

  @override
  String resetTodayHint(int cap) {
    return 'Up to $cap. Only what truly can’t wait.';
  }

  @override
  String get resetTodayEmpty => 'Nothing open right now.';

  @override
  String get resetWeekTitle => 'What belongs to this week?';

  @override
  String get resetWeekHint => 'It stays visible as one quiet row on Today.';

  @override
  String get resetWeekEmpty => 'Nothing else is open.';

  @override
  String get resetLetGoTitle => 'Let go of the rest?';

  @override
  String get resetLetGoEmpty => 'Nothing left over.';

  @override
  String get resetLetGoHint =>
      'Ticked items go to Someday, or to Trash for 30 days. Untick anything you want to keep as it is.';

  @override
  String get resetKeepAll => 'Keep them all';

  @override
  String get resetMoveToSomeday => 'Move to Someday';

  @override
  String get resetSmallestTitle => 'Smallest next action';

  @override
  String get resetSmallestEmpty =>
      'Nothing was picked, and that’s fine. You’ve cleared some space.';

  @override
  String get resetSmallestHint =>
      'Pick one. Optionally, name a first step so small it’s easy.';

  @override
  String get resetFocusOnIt => 'Focus on it';

  @override
  String get resetFirstStepLabel => 'Tiny first step (optional)';

  @override
  String get resetFirstStepHint => 'e.g. “open the letter”';

  @override
  String get clarifyTitle => 'Clarify';

  @override
  String get clarifyActionableTitle => 'Is this actionable?';

  @override
  String get clarifyActionableYes => 'Yes, there’s something to do';

  @override
  String get clarifyKeepIdea => 'No, keep it as an idea';

  @override
  String get clarifyKeepIdeaHint => 'It waits in Someday, out of Today’s way';

  @override
  String get clarifyLetGo => 'No, let it go';

  @override
  String get clarifyLetGoHint => 'Into Trash for 30 days';

  @override
  String get clarifyNextActionTitle => 'What’s the next action?';

  @override
  String get clarifyNextActionHint =>
      'A concrete step, starting with a verb: call, buy, email, book…';

  @override
  String get clarifyDelegateTitle => 'Is someone else doing it?';

  @override
  String get clarifyWho => 'Who?';

  @override
  String get clarifyFollowUpOptional => 'Follow up on… (optional)';

  @override
  String clarifyFollowUpOn(String date) {
    return 'Follow up $date';
  }

  @override
  String get clarifyDoItMyself => 'No, I’ll do it';

  @override
  String get clarifyWaitingYes => 'Yes, I’m waiting on someone';

  @override
  String get clarifyWaitingYesHint => 'Track who, and when to follow up';

  @override
  String get clarifySaveWaiting => 'Save as Waiting';

  @override
  String get clarifyThisWeekHint =>
      'One quiet row on Today until you pick a day';

  @override
  String get clarifyDetailsTitle => 'Anything else?';

  @override
  String get clarifyDetailsHint => 'All optional.';

  @override
  String get clarifyMustDoToday => 'Must-do today';

  @override
  String get clarifyRemindMe => 'Remind me';

  @override
  String get clarifyNoReminder => 'No reminder';

  @override
  String get clarifyRemoveReminders => 'Remove reminders';

  @override
  String get clarifyRepeat => 'Repeat';

  @override
  String get clarifyNoRepeat => 'Doesn’t repeat';

  @override
  String get clarifyDontRepeat => 'Don’t repeat';

  @override
  String get clarifyDoneMeans => 'Done means…';

  @override
  String get clarifyDoneMeansHint => 'e.g. “form posted”, not “sort out taxes”';

  @override
  String get faqTitle => 'Questions and answers';

  @override
  String get faqSectionData => 'Your data';

  @override
  String get faqSectionUsing => 'Using Clearing';

  @override
  String get faqSectionReminders => 'Reminders';

  @override
  String get faqRemindersHelpSubtitle =>
      'Battery settings to check on your phone';

  @override
  String get faqWhereKeptQ => 'Where are my things kept?';

  @override
  String get faqWhereKeptA =>
      'Only on this phone. Clearing has no account, no server and no internet access, so nothing you write leaves the phone unless you export it.';

  @override
  String get faqNewPhoneQ => 'How do I move to a new phone?';

  @override
  String get faqNewPhoneA =>
      'Use Settings › Backup › Share a backup, and send the file somewhere you can reach from the new phone (email it to yourself, or save it to Drive). On the new phone, install Clearing and choose Restore from a backup. Android’s phone-to-phone transfer also moves Clearing’s data when you set up a new phone.';

  @override
  String get faqUninstallQ => 'What happens if I uninstall Clearing?';

  @override
  String get faqUninstallA =>
      'Everything in it is deleted with the app. Export a backup first if you might want it back. Clearing reminds you to export once a month, and you can change how often in Backup.';

  @override
  String get faqTwoDevicesQ => 'Can I use Clearing on two devices?';

  @override
  String get faqTwoDevicesA =>
      'Not in sync: each phone keeps its own copy. You can move things across with a backup: Restore › Merge adds what’s missing and keeps the newer copy of anything on both.';

  @override
  String get faqUndoQ => 'I did something by mistake. Can I undo it?';

  @override
  String get faqUndoA =>
      'Right after completing, deleting or moving an item, tap Undo on the note at the bottom of the screen. Deleted items stay in Lists › Trash for 30 days. Done items are in Lists › Done; untick one to bring it back.';

  @override
  String get faqCarriedOverQ => 'What does “carried over” mean?';

  @override
  String get faqCarriedOverA =>
      'Something planned for an earlier day that isn’t done yet. It stays on Today, quietly, until you do it or move it. Nothing turns red and nothing is counted against you.';

  @override
  String get faqMissedRepeatQ => 'What happens when I miss a repeating item?';

  @override
  String get faqMissedRepeatA =>
      'You choose per item. “Carry it over” keeps the missed one on Today until done, and the next one waits. “Skip it quietly” lets it go and starts fresh. Either way, missed days never pile up.';

  @override
  String get faqMustDoLimitQ => 'Why is Today limited to a few must-dos?';

  @override
  String get faqMustDoLimitA =>
      'A short list gets done; a long one turns into guilt. Everything else stays visible below. You can change the limit (1 to 5) in Settings.';

  @override
  String get faqNoStreaksQ => 'Why are there no streaks or scores?';

  @override
  String get faqNoStreaksA =>
      'They make a missed day feel like failure. Clearing counts what you cleared and planned, and nothing else.';

  @override
  String get remindersHelpTitle => 'Reminders not arriving?';

  @override
  String get remindersHelpIntro =>
      'Clearing schedules every reminder on your phone; nothing goes through a server. Some phones stop apps in the background to save battery, which can delay or drop reminders.';

  @override
  String get remindersHelpFirstCheck => 'First, check';

  @override
  String get remindersHelpNotificationsTitle => 'Notifications are allowed';

  @override
  String get remindersHelpNotificationsPath =>
      'Settings › Apps › Clearing › Notifications';

  @override
  String get remindersHelpExactTitle => 'Exact timing is on';

  @override
  String get remindersHelpExactBody =>
      'Without it, Android may deliver reminders a few minutes late. See Exact timing in Clearing’s settings.';

  @override
  String get remindersHelpDndTitle => 'Do Not Disturb is off';

  @override
  String get remindersHelpDndBody =>
      'It silences or hides reminders while it’s on.';

  @override
  String get remindersHelpForYourPhone => 'Then, for your phone';

  @override
  String get remindersHelpBrandXiaomi => 'Xiaomi, Redmi and POCO';

  @override
  String get remindersHelpBrandOnePlus => 'OnePlus, OPPO and realme';

  @override
  String get remindersHelpBrandVivo => 'vivo and iQOO';

  @override
  String get remindersHelpBrandHuawei => 'Huawei and Honor';

  @override
  String get remindersHelpBrandPixel => 'Pixel and other phones';

  @override
  String get remindersHelpSamsung =>
      'Settings › Apps › Clearing › Battery › Unrestricted. Also check Settings › Battery › Background usage limits and remove Clearing from “Sleeping apps”.';

  @override
  String get remindersHelpXiaomi =>
      'Settings › Apps › Manage apps › Clearing: turn on Autostart, and set Battery saver to “No restrictions”.';

  @override
  String get remindersHelpOnePlus =>
      'Settings › Apps › Clearing › Battery: allow background activity and turn off “Optimise battery use”. On some versions, also allow Auto launch.';

  @override
  String get remindersHelpVivo =>
      'Settings › Battery › Background power consumption management: allow Clearing. Also turn on Autostart for Clearing in i Manager.';

  @override
  String get remindersHelpHuawei =>
      'Settings › Battery › App launch › Clearing: switch to “Manage manually” and allow Auto-launch, Secondary launch and Run in background.';

  @override
  String get remindersHelpPixel =>
      'Settings › Apps › Clearing › App battery usage: Unrestricted.';

  @override
  String get remindersHelpFooter =>
      'Menu names vary between versions. dontkillmyapp.com has up-to-date steps for many more phones.';

  @override
  String get templateGone => 'This template no longer exists.';

  @override
  String get templateWhenStart => 'When will you do it?';

  @override
  String get templateAddedToInbox => 'Added to the Inbox';

  @override
  String templateAdded(String title) {
    return '“$title” added';
  }

  @override
  String get templateRoutine => 'Routine';

  @override
  String get templateTemplate => 'Template';

  @override
  String get templateStopRoutine => 'Stop the routine';

  @override
  String get templateDelete => 'Delete template';

  @override
  String get templateSteps => 'Steps';

  @override
  String get templateDragToReorder => 'Drag to reorder';

  @override
  String get templateRemoveStep => 'Remove step';

  @override
  String get templateAddStepHint => 'Add a step';

  @override
  String get templateAddStep => 'Add step';

  @override
  String get templateDoneMeans => 'Done means…';

  @override
  String get templateList => 'List';

  @override
  String get templateUseIt => 'Use it';

  @override
  String get templateMakeRoutine => 'Make it a routine';

  @override
  String get templateMakeRoutineHint =>
      'Arrives as a fresh checklist on the days you choose';

  @override
  String get templateStartNow => 'Start now';

  @override
  String get templateStartNote =>
      'Starting makes a copy. Changing the template later won’t change items already made from it.';

  @override
  String get templatesTitle => 'Routines & templates';

  @override
  String get templatesNew => 'New template';

  @override
  String get templatesNameHint => 'e.g. Packing list';

  @override
  String get templatesEmptyTitle => 'No templates yet';

  @override
  String get templatesEmptyMessage =>
      'A template is a checklist you use again and again. Make it a routine and it arrives on its own schedule.';

  @override
  String get templatesStartFromScratch => 'Start from scratch';

  @override
  String get templatesRoutines => 'Routines';

  @override
  String get templatesTemplates => 'Templates';

  @override
  String templatesStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get worksheetPrintTitle => 'Print a worksheet';

  @override
  String get worksheetDaySubtitle =>
      'Must-dos, today, this week, and room to jot things down';

  @override
  String get worksheetWeekSubtitle => 'A box for each day';

  @override
  String get worksheetJobNameDay => 'Clearing – today';

  @override
  String get worksheetJobNameWeek => 'Clearing – week';

  @override
  String get itemNoLongerExists => 'This item no longer exists.';

  @override
  String get itemWhenNotDecided => 'Not decided yet';

  @override
  String itemWhenWaitingOn(String name) {
    return 'Waiting on $name';
  }

  @override
  String get itemWhenWaitingOnSomeone => 'Waiting on someone';

  @override
  String get itemWhenInTrash => 'In Trash';

  @override
  String itemWhenDateAtTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String get itemFutureRepeatsTitle => 'Change future repeats too?';

  @override
  String get itemFutureRepeatsBody =>
      'You edited this one. Future repeats can stay as they were, or start from this version.';

  @override
  String get itemJustThisOne => 'Just this one';

  @override
  String get itemThisAndFuture => 'This and future';

  @override
  String get itemFocusOnThis => 'Focus on this';

  @override
  String get itemNotMustDo => 'Not a must-do';

  @override
  String get itemMakeMustDo => 'Make it a must-do';

  @override
  String get itemMoveToSomeday => 'Move to Someday';

  @override
  String get itemSomeoneElseDoingIt => 'Someone else is doing it';

  @override
  String get itemUseForFutureRepeats => 'Use for future repeats';

  @override
  String get itemResumeRepeating => 'Resume repeating';

  @override
  String get itemPauseRepeating => 'Pause repeating';

  @override
  String get itemStopRepeating => 'Stop repeating';

  @override
  String get itemNotDoneYet => 'Not done yet';

  @override
  String get itemTitleHint => 'Title';

  @override
  String get itemPlanSection => 'Plan';

  @override
  String get itemWhen => 'When';

  @override
  String get itemSomeone => 'Someone';

  @override
  String get itemFollowUp => 'Follow up';

  @override
  String get itemNoDate => 'No date';

  @override
  String get itemDoesntRepeat => 'Doesn’t repeat';

  @override
  String itemRepeatPaused(String rule) {
    return '$rule · paused';
  }

  @override
  String get itemSeeAllDates => 'See all dates';

  @override
  String get itemDeadline => 'Deadline';

  @override
  String get itemDeadlineNone => 'None — “do on” is when you plan to do it';

  @override
  String get itemRemoveDeadline => 'Remove deadline';

  @override
  String get itemDetailsSection => 'Details';

  @override
  String get itemList => 'List';

  @override
  String get itemDoneMeansLabel => 'Done means…';

  @override
  String get itemDoneMeansHint => 'What does finished look like?';

  @override
  String get itemNotes => 'Notes';

  @override
  String get repeatTitle => 'Repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every 1 day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every 1 week',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every 1 month',
    );
    return '$_temp0';
  }

  @override
  String get repeatLessOften => 'Less often';

  @override
  String get repeatMoreSpreadOut => 'More spread out';

  @override
  String get repeatAfterCompletionTitle => 'Count from when it’s done';

  @override
  String get repeatAfterCompletionSubtitle =>
      'For things like haircuts: the next one is set when you finish this one';

  @override
  String get repeatOnDay => 'On day';

  @override
  String get repeatOnDayHint => 'short months use their last day';

  @override
  String get repeatStarts => 'Starts';

  @override
  String get repeatEnds => 'Ends';

  @override
  String get repeatEndsNever => 'Never';

  @override
  String get repeatEndsOnDate => 'On a date';

  @override
  String get repeatEndsAfter => 'After';

  @override
  String repeatLastTimeOn(String date) {
    return 'Last time on $date';
  }

  @override
  String repeatTimesInAll(int count) {
    return '$count times in all';
  }

  @override
  String get repeatFewerTimes => 'Fewer times';

  @override
  String get repeatMoreTimes => 'More times';

  @override
  String get repeatIfMissed => 'If one is missed';

  @override
  String get repeatCarryOver => 'Carry it over';

  @override
  String get repeatCarryOverSubtitle =>
      'It stays on Today until done; the next one waits';

  @override
  String get repeatSkipQuietly => 'Skip it quietly';

  @override
  String get repeatSkipQuietlySubtitle =>
      'Good for routines: tomorrow is a fresh start';

  @override
  String get seriesCalendarDone => 'done';

  @override
  String get seriesCalendarSkipped => 'skipped';

  @override
  String get seriesCalendarOpenNow => 'open now';

  @override
  String get seriesCalendarComingUp => 'coming up';

  @override
  String get seriesCalendarPreviousMonth => 'Previous month';

  @override
  String get seriesCalendarNextMonth => 'Next month';

  @override
  String get seriesCalendarToday => 'today';

  @override
  String get reminderWaitingForDate => 'Waiting for a date';

  @override
  String get reminderRemove => 'Remove reminder';

  @override
  String get reminderRemindMe => 'Remind me';

  @override
  String get reminderAdd => 'Add a reminder';

  @override
  String get reminderSeparateHint => 'Separate from when you plan to do it';

  @override
  String reminderCountedFromNine(String offset) {
    return '$offset (counted from 9:00)';
  }

  @override
  String get reminderAtTimeIChoose => 'At a time I choose';

  @override
  String get reminderRemindMeOn => 'Remind me on';

  @override
  String get reminderRemindMeAt => 'Remind me at';

  @override
  String get reminderOffInSettings => 'Reminders are off in Settings';

  @override
  String get reminderNotificationsOff =>
      'Notifications are off for Clearing, so this reminder can’t appear. You can allow them in system settings.';

  @override
  String get reminderMayBeLate => 'Reminders may arrive a few minutes late';

  @override
  String get reminderMakeExact => 'Make exact';

  @override
  String get subtaskAllDone => 'All steps done';

  @override
  String get subtaskCompleteItem => 'Complete item';

  @override
  String get subtaskSteps => 'Steps';

  @override
  String subtaskProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String subtaskRemoveStep(String title) {
    return 'Remove step $title';
  }

  @override
  String get subtaskAddHint => 'Add a step';

  @override
  String get whenSheetDoOn => 'Do on';

  @override
  String get whenSheetAddTimeQuestion =>
      'Add a time? Most things don’t need one.';

  @override
  String get whenSheetNoTime => 'No time';

  @override
  String get whenSheetAddTime => 'Add time';

  @override
  String get todayMenuWeeklyReview => 'Weekly review';

  @override
  String get todayMenuOverwhelmReset => 'Overwhelm reset';

  @override
  String get todayMenuPrintWorksheet => 'Print a worksheet';

  @override
  String todayLeft(int count) {
    return '$count left';
  }

  @override
  String get todayAllClear => 'all clear';

  @override
  String get todayEmptyTitle => 'A clear day';

  @override
  String get todayEmptyMessage =>
      'Capture anything on your mind. You can decide what it means later.';

  @override
  String get todayHowClearingWorks => 'How Clearing works';

  @override
  String get todayResetOfferTitle => 'Feeling like a lot?';

  @override
  String get todayResetOfferSubtitle =>
      'A five-minute reset narrows it to one thing';

  @override
  String todayMustDoCount(int count, int cap) {
    return '$count of $cap';
  }

  @override
  String get todayBlocks => 'Blocks';

  @override
  String get todayAlsoToday => 'Also today';

  @override
  String todayShowMore(int count) {
    return 'Show $count more';
  }

  @override
  String todayCarriedOver(int count) {
    return 'Carried over ($count)';
  }

  @override
  String get todayCarriedOverSubtitle => 'Picking up where you left off';

  @override
  String get todayHide => 'Hide';

  @override
  String get todayShow => 'Show';

  @override
  String todayThisWeekCount(int count) {
    return 'This week ($count)';
  }

  @override
  String get thisWeekEmptyTitle => 'Nothing set for this week';

  @override
  String get thisWeekEmptyMessage =>
      'Things you mean to do this week, without picking a day, gather here and show as one quiet row on Today.';

  @override
  String get thisWeekDoToday => 'Do today';

  @override
  String inboxToDecide(int count) {
    return '$count to decide · tap one, or swipe for shortcuts';
  }

  @override
  String inboxReviewEstimate(int count) {
    return 'Inbox: $count — a review takes about 15 minutes';
  }

  @override
  String get inboxReviewSubtitle => 'Every item gets a place';

  @override
  String get inboxStartReview => 'Start review';

  @override
  String get inboxSwipePickDate => 'Pick date';

  @override
  String get inboxEmptyTitle => 'Inbox is empty';

  @override
  String get inboxEmptyMessage =>
      'Thoughts you capture land here until you decide what they mean.';

  @override
  String get itemTileRepeats => 'Repeats';

  @override
  String itemTileWaitingOn(String name) {
    return 'Waiting on $name';
  }

  @override
  String itemTileFollowUp(String date) {
    return 'Follow up $date';
  }

  @override
  String itemTileDeadline(String date) {
    return 'Deadline $date';
  }

  @override
  String itemTileProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get itemTileMarkDone => 'Mark done';

  @override
  String get itemTileMarkNotDone => 'Mark not done';

  @override
  String get itemTileFromLastWeek => 'From last week';

  @override
  String itemTileFromDay(String day) {
    return 'From $day';
  }

  @override
  String itemTileDayTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get itemTileNotMustDo => 'Not a must-do';

  @override
  String get itemTileMakeMustDo => 'Make it a must-do';

  @override
  String get itemTileTomorrow => 'Tomorrow';

  @override
  String get itemTileFocusOnThis => 'Focus on this';

  @override
  String get itemTileReschedule => 'Reschedule…';

  @override
  String get itemTileBreakIntoSteps => 'Break into steps';

  @override
  String get itemTileMoveToSomeday => 'Move to Someday';

  @override
  String get listsSubtitle => 'Contexts, ideas, and what’s done';

  @override
  String get listsNewList => 'New list';

  @override
  String get listsRoutinesTitle => 'Routines & templates';

  @override
  String get listsRoutinesSubtitle => 'Checklists you use again and again';

  @override
  String get listsNotNow => 'Not now';

  @override
  String get listsSomedaySubtitle => 'Ideas, not commitments';

  @override
  String get listsDoneTitle => 'Done';

  @override
  String get listsDoneSubtitle => 'Recently done and the archive';

  @override
  String get listsTrashTitle => 'Trash';

  @override
  String get listsTrashSubtitle => 'Kept for 30 days';

  @override
  String listsHiddenLists(int count) {
    return 'Hidden lists ($count)';
  }

  @override
  String get listsRename => 'Rename';

  @override
  String get listsRenameList => 'Rename list';

  @override
  String get listsShow => 'Show';

  @override
  String get listsHide => 'Hide';

  @override
  String get listsDeleteList => 'Delete list';

  @override
  String get listsDeleteListSubtitle => 'Its items are kept, just unfiled';

  @override
  String get listSectionToDo => 'To do';

  @override
  String get listSectionNotDecided => 'Not decided yet';

  @override
  String listBlockEvery(String weekday, String time) {
    return 'Every $weekday at $time';
  }

  @override
  String listBlockOn(String date, String time) {
    return '$date at $time';
  }

  @override
  String get listBlockSubtitle => 'Shows as one entry on Today';

  @override
  String get listRemoveBlock => 'Remove time block';

  @override
  String get listBlockOutTime => 'Block out time';

  @override
  String listAddTo(String name) {
    return 'Add to $name';
  }

  @override
  String get listAddToList => 'Add to list';

  @override
  String listEmptyTitle(String name) {
    return 'Nothing in $name';
  }

  @override
  String get listEmptyTitleThisList => 'Nothing in this list';

  @override
  String get listEmptyMessage =>
      'Add things that belong together, like errands to run in one trip.';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashDeleteForever => 'Delete forever';

  @override
  String get trashEmptyConfirmTitle => 'Empty Trash?';

  @override
  String trashEmptyConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items will be deleted for good. This can’t be undone.',
      one: '1 item will be deleted for good. This can’t be undone.',
    );
    return '$_temp0';
  }

  @override
  String get trashEmpty => 'Empty';

  @override
  String get trashEmptyTitle => 'Trash is empty';

  @override
  String get trashEmptyMessage =>
      'Deleted items stay here for 30 days, in case you want them back.';

  @override
  String get trashPurgeTomorrow => 'Deleted for good tomorrow';

  @override
  String trashPurgeInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Deleted for good in $days days',
      one: 'Deleted for good in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restore';

  @override
  String get trashDeleteForeverConfirmTitle => 'Delete forever?';

  @override
  String trashDeleteForeverConfirmBody(String title) {
    return '“$title” will be gone for good.';
  }

  @override
  String get archiveTitle => 'Done';

  @override
  String get archiveEmptyTitle => 'Nothing done yet';

  @override
  String get archiveEmptyMessage =>
      'Finished items rest here, and search still finds them.';

  @override
  String get archiveRecentlyDone => 'Recently done';

  @override
  String archiveArchivedAfter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'archived after $days days',
      one: 'archived after 1 day',
    );
    return '$_temp0';
  }

  @override
  String get archiveSection => 'Archive';

  @override
  String get somedayEmptyTitle => 'No ideas parked here';

  @override
  String get somedayEmptyMessage =>
      'Things you might do one day, without the pressure.';

  @override
  String get somedayMakePlan => 'Make it a plan';

  @override
  String get somedayWhenTitle => 'When will you do it?';

  @override
  String get settingsMustDoPerDay => 'Must-do items per day';

  @override
  String get settingsMustDoPerDayHint =>
      'Keeping this small keeps Today doable';

  @override
  String get settingsWeekStartsOn => 'Week starts on';

  @override
  String get settingsWeekStartsOnHint => 'for “This week” and weekday choices';

  @override
  String get settingsInboxBadge => 'Show count on the Inbox tab';

  @override
  String get settingsStarterSuggestionsHint =>
      'Quick-add ideas in capture and an empty inbox';

  @override
  String get settingsEditSuggestions => 'Edit suggestions';

  @override
  String get settingsRemindersSection => 'Reminders';

  @override
  String get settingsIntensityOff => 'Off';

  @override
  String get settingsIntensityGentle => 'Gentle';

  @override
  String get settingsIntensityStandard => 'Standard';

  @override
  String get settingsIntensityOffHint => 'No notifications at all.';

  @override
  String get settingsIntensityGentleHint =>
      'Only reminders you set, without sound or vibration.';

  @override
  String get settingsIntensityStandardHint =>
      'Only reminders you set, with sound.';

  @override
  String get settingsQuietHours => 'Quiet hours';

  @override
  String settingsQuietHoursRange(String start, String end) {
    return '$start – $end. Early reminders wait until morning; ones you timed exactly still arrive.';
  }

  @override
  String get settingsQuietFrom => 'Quiet from';

  @override
  String get settingsQuietUntil => 'Quiet until';

  @override
  String get settingsMorningSummary => 'Morning summary';

  @override
  String settingsMorningSummaryOn(String time) {
    return 'Today’s must-dos at $time. Nothing on a clear day.';
  }

  @override
  String get settingsMorningSummaryOff =>
      'One note each morning with today’s must-dos';

  @override
  String get settingsSummaryTime => 'Summary time';

  @override
  String get settingsRemindersNotArriving => 'Reminders not arriving?';

  @override
  String get settingsWeeklyReviewSection => 'Weekly review';

  @override
  String get settingsRemindReview => 'Remind me to review';

  @override
  String get settingsRemindReviewHint => 'About 15 minutes, once a week';

  @override
  String get settingsReviewDay => 'Review day';

  @override
  String get settingsReviewTime => 'Review time';

  @override
  String get settingsDoneSection => 'Done items';

  @override
  String get settingsAutoArchive => 'Move done items to the archive';

  @override
  String get settingsAutoArchiveHint => 'still searchable there';

  @override
  String get settingsArchiveAfterDay => 'After a day';

  @override
  String get settingsArchiveAfterWeek => 'After a week';

  @override
  String get settingsArchiveAfterMonth => 'After a month';

  @override
  String get settingsArchiveNever => 'Never';

  @override
  String settingsArchiveAfterDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'After $count days',
      one: 'After 1 day',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataSection => 'Your data';

  @override
  String get settingsBackupHint => 'Export a copy, or restore one';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsHelpSection => 'Help';

  @override
  String get settingsFaq => 'Questions and answers';

  @override
  String get settingsFaqHint => 'Backups, new phones, undo and more';

  @override
  String get settingsAbout => 'About and feedback';

  @override
  String get settingsNotificationsBlocked => 'Notifications are blocked';

  @override
  String get settingsNotificationsBlockedHint =>
      'Tap to allow them for Clearing';

  @override
  String get settingsExactTiming => 'Exact timing';

  @override
  String get settingsExactTimingOn => 'Reminders arrive on the minute';

  @override
  String get settingsExactTimingOff =>
      'Off: reminders may arrive a few minutes late. Tap to allow exact timing.';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String backupExportFailed(String error) {
    return 'Couldn’t export: $error';
  }

  @override
  String get backupIntro =>
      'Everything stays on this phone, with no account and no cloud. Uninstalling Clearing or losing the phone deletes your data unless you’ve exported a copy.';

  @override
  String get backupLast => 'Last backup';

  @override
  String get backupNever => 'Never';

  @override
  String get backupExportSection => 'Export';

  @override
  String get backupShare => 'Share a backup';

  @override
  String get backupShareHint => 'Send it to email, Drive, or another app';

  @override
  String get backupSaveToFolder => 'Save to a folder';

  @override
  String get backupRemindExport => 'Remind me to export';

  @override
  String get backupEveryTwoWeeks => 'Every 2 weeks';

  @override
  String get backupMonthly => 'Monthly';

  @override
  String backupEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String get backupRestoreSection => 'Restore';

  @override
  String get backupRestoreFrom => 'Restore from a backup';

  @override
  String get backupRestoreFromHint =>
      'You’ll see what’s in it before anything changes';

  @override
  String get backupCantRestore => 'Can’t restore this file';

  @override
  String get backupReplaceAllTitle => 'Replace everything?';

  @override
  String get backupReplaceAllBody =>
      'Everything now in Clearing on this phone will be replaced by the backup. This can’t be undone.';

  @override
  String get backupReplace => 'Replace';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupRestoreThis => 'Restore this backup?';

  @override
  String backupFromDate(String date) {
    return 'Backup from $date';
  }

  @override
  String backupPreviewItems(int count, int open, int someday, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0: $open open, $someday someday, $done done';
  }

  @override
  String backupPreviewLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists',
      one: '1 list',
    );
    return '$_temp0';
  }

  @override
  String backupPreviewRepeating(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repeating items',
      one: '1 repeating item',
    );
    return '$_temp0';
  }

  @override
  String get backupMergeExplain =>
      'Merge adds what’s missing and keeps the newer copy of anything on both. Replace makes this phone match the backup exactly.';

  @override
  String get backupMerge => 'Merge';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutTagline => 'Close your mental tabs.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacySection => 'Your privacy';

  @override
  String get aboutPrivacy =>
      'No account, no server, no analytics, no ads. Clearing can’t reach the internet at all: everything you write stays on this phone unless you export it yourself.';

  @override
  String get aboutBetaSection => 'Beta';

  @override
  String get aboutSendFeedback => 'Send feedback';

  @override
  String get aboutSendFeedbackHint =>
      'Opens your email or messaging app with a short template';

  @override
  String get aboutFeedbackSubject => 'Clearing feedback';

  @override
  String get aboutFeedbackWhatHappened => 'What happened:';

  @override
  String get aboutFeedbackExpected => 'What I expected:';

  @override
  String get aboutFeedbackElse => 'Anything else:';

  @override
  String aboutSendWithErrorLog(int count) {
    return 'Send feedback with the error log ($count)';
  }

  @override
  String get aboutErrorLogHint =>
      'Error types and where they happened; you see it all first';

  @override
  String get aboutErrorLogHeader => '--- Error log ---';

  @override
  String get aboutClearErrorLog => 'Clear the error log';

  @override
  String get aboutSourceCode => 'Source code';

  @override
  String aboutSourceSubtitle(String url) {
    return '$url · MIT licence';
  }

  @override
  String get aboutLicences => 'Open-source licences';

  @override
  String get suggestionsTitle => 'Starter suggestions';

  @override
  String get suggestionsAdd => 'Add';

  @override
  String get suggestionsYours => 'Yours';

  @override
  String get suggestionsEdit => 'Edit';

  @override
  String get suggestionsNew => 'New suggestion';

  @override
  String get suggestionsEditTitle => 'Edit suggestion';

  @override
  String get introTitle => 'How Clearing works';

  @override
  String get introCaptureTitle => 'Capture it';

  @override
  String get introCaptureBody =>
      'Get a thought out of your head the moment it appears. One line is enough: it waits in the Inbox until you have a minute.';

  @override
  String get introDecideTitle => 'Decide what it means';

  @override
  String get introDecideBody =>
      'Later, give each one a place: today, this week, a date, someone else, or Someday if it’s just an idea.';

  @override
  String get introPlanTitle => 'Plan small, close often';

  @override
  String get introPlanBody =>
      'Keep Today to a few must-dos, and review once a week so nothing is forgotten. Missed things are carried over, never held against you.';

  @override
  String introCardPosition(int index, int total) {
    return 'Card $index of $total';
  }

  @override
  String get introGetStarted => 'Get started';

  @override
  String get searchStatusOpen => 'Open';

  @override
  String get searchPlannedBetween => 'Planned between';

  @override
  String get searchHint => 'Search titles, notes and steps';

  @override
  String get searchClear => 'Clear';

  @override
  String get searchAnyList => 'Any list';

  @override
  String searchDateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get searchAnyDate => 'Any date';

  @override
  String get searchRepeating => 'Repeating';

  @override
  String get searchNoMatchesTitle => 'No matches';

  @override
  String get searchNoMatchesMessage =>
      'Try fewer words, or loosen the filters.';

  @override
  String get upcomingSubtitleWeek => 'A week at a time';

  @override
  String get upcomingSubtitleAgenda => 'The next 30 days';

  @override
  String get upcomingAgenda => 'Agenda';

  @override
  String get upcomingWeekView => 'Week view';

  @override
  String get upcomingEmptyTitle => 'Nothing scheduled';

  @override
  String get upcomingEmptyMessage =>
      'Items with a date in the next 30 days show up here.';

  @override
  String get weekPrevious => 'Previous week';

  @override
  String get weekNext => 'Next week';

  @override
  String weekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get weekAnyDay => 'Any day this week';

  @override
  String get weekNothingLeft => 'Nothing left';

  @override
  String get weekFree => 'Free';

  @override
  String blockTileTitle(String list, String time) {
    return '$list · $time';
  }

  @override
  String get blockAllDone => 'All done';

  @override
  String blockToDo(int count) {
    return '$count to do, in one go';
  }

  @override
  String get blockDialogTitle => 'Block out time';

  @override
  String get blockDialogMessage => 'Work through the whole list in one go.';

  @override
  String get blockEveryWeek => 'Every week';

  @override
  String get blockOnce => 'Once';

  @override
  String blockAtTime(String time) {
    return 'At $time';
  }

  @override
  String captureSavedAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count items',
      one: 'Saved',
    );
    return '$_temp0';
  }

  @override
  String get captureHint => 'What’s on your mind?';

  @override
  String get captureHelper => 'Saved to Inbox. Decide what it means later.';

  @override
  String captureHelperInList(String list) {
    return 'Saved to Inbox, in $list.';
  }

  @override
  String captureSavedCount(int count) {
    return 'Saved $count to Inbox';
  }

  @override
  String get commandsTrashed => 'Moved to Trash';

  @override
  String get commandsSomeday => 'Kept as an idea in Someday';

  @override
  String get commandsSnoozed => 'Moved to tomorrow';

  @override
  String get commandsRescheduled => 'Rescheduled';

  @override
  String commandsMustDoCapTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You already have $count must-dos',
      one: 'You already have 1 must-do',
    );
    return '$_temp0';
  }

  @override
  String get commandsMustDoSwapPrompt => 'Swap one out to make room?';

  @override
  String get commandsMustDoKeep => 'Keep things as they are';

  @override
  String shellInboxTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inbox, $count items',
      one: 'Inbox, 1 item',
    );
    return '$_temp0';
  }

  @override
  String get shellCapture => 'Capture';

  @override
  String stepTrailLabel(int current, int count) {
    return 'Step $current of $count';
  }
}

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

  @override
  String get settingsTodayHint => 'How much Today asks of you.';

  @override
  String get settingsInboxHint => 'Where new thoughts wait for a decision.';

  @override
  String get settingsRemindersHint => 'When and how Clearing may notify you.';

  @override
  String get settingsWeeklyReviewHint =>
      'A gentle nudge to look over your week.';

  @override
  String get settingsDoneHint => 'Where finished things go.';

  @override
  String get settingsDataHint => 'It stays on this phone unless you export it.';

  @override
  String get settingsAppearanceHint => 'Light, dark, or follow the phone.';

  @override
  String get settingsHelpHint => 'Answers, and how Clearing works.';

  @override
  String get welcomeTitle => 'Close your mental tabs.';

  @override
  String get welcomeBody =>
      'Clearing is a quiet place for everything on your mind, so you can stop carrying it around.';

  @override
  String get welcomeShowMe => 'Show me around';

  @override
  String get welcomeSkip => 'Skip the tour';

  @override
  String get welcomeCaptureTitle => 'Capture it';

  @override
  String get welcomeCaptureBody =>
      'The moment something pops into your head, tap + and write one line. It waits in your Inbox until you have a minute.';

  @override
  String get welcomeDecideTitle => 'Decide what it means';

  @override
  String get welcomeDecideBody =>
      'Later, give each thought a place: today, this week, a date, someone else’s job, or Someday if it’s just an idea.';

  @override
  String get welcomeTodayTitle => 'Keep Today small';

  @override
  String get welcomeTodayBody =>
      'Pick up to three must-dos. Missed things are carried over, never shown in red, never held against you.';

  @override
  String get welcomeReviewTitle => 'Look back once a week';

  @override
  String get welcomeReviewBody =>
      'A 15-minute weekly review clears your head and plans the week, so nothing slips.';

  @override
  String get welcomePrivateTitle => 'Private by design';

  @override
  String get welcomePrivateBody =>
      'No account, no ads, no internet access. Everything stays on this phone, and you can export a backup any time.';

  @override
  String get welcomeSetupTitle => 'Make it yours';

  @override
  String get welcomeSetupHint =>
      'You can change all of this later in Settings.';

  @override
  String get welcomeSetupMustDo => 'Must-dos per day';

  @override
  String get welcomeSetupMustDoHint =>
      'Fewer is calmer. Three is a good start.';

  @override
  String get welcomeSetupWeek => 'Your week starts on';

  @override
  String get welcomeSetupReminders => 'Reminders';

  @override
  String get welcomeSetupReview => 'Remind me to do a weekly review';

  @override
  String welcomeSetupReviewWhen(String day, String time) {
    return '$day at $time';
  }

  @override
  String get welcomeSetupDone => 'Start using Clearing';

  @override
  String get welcomeReadyTitle => 'You’re all set';

  @override
  String get welcomeReadyBody =>
      'Tip: add the Today and quick-capture widgets to your home screen. Long-press the home screen, then Widgets › Clearing.';

  @override
  String get welcomeCaptureFirst => 'Capture my first thought';

  @override
  String get welcomeGoToday => 'Go to Today';

  @override
  String welcomePageLabel(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get welcomeTourTitle => 'How Clearing works';

  @override
  String get tipLabel => 'Tip';

  @override
  String get tipGotIt => 'Got it';

  @override
  String get tipTodayRing =>
      'Tap the ring when something’s done. Long-press any item for more options.';

  @override
  String get tipInboxSwipe =>
      'Swipe right to plan an item for today or this week. Swipe left to pick a date, keep it for Someday, or delete it. Or tap it to decide step by step.';

  @override
  String get tipUpcomingWeek =>
      'See a whole week at a time with the week icon at the top.';

  @override
  String get tipListsBlock =>
      'Open a list and tap the calendar icon to block out time for it, like “Errands, Saturday 10:00”.';

  @override
  String get tipItemFocus =>
      'Feeling stuck? Tap the focus icon at the top to see only this item.';

  @override
  String get tipCaptureBurst =>
      'Press Enter after each thought: the field stays open for the next one.';

  @override
  String get settingsShowTips => 'Show tips as you go';

  @override
  String get settingsShowTipsHint =>
      'Short hints the first time you visit each screen';

  @override
  String get settingsResetTips => 'Show all tips again';

  @override
  String get settingsTipsReset => 'Tips will show again';

  @override
  String get settingsReplayWelcome => 'Replay the welcome';

  @override
  String get settingsReplayWelcomeHint => 'The tour, and setting up the basics';

  @override
  String get helpTitle => 'Help and guides';

  @override
  String get helpSubtitle => 'Guides, questions and answers';

  @override
  String get helpGetStarted => 'Get started';

  @override
  String get helpGuides => 'Guides';

  @override
  String get helpMore => 'More help';

  @override
  String get helpTourHint => 'Five short pages';

  @override
  String get guideCaptureTitle => 'Capturing thoughts';

  @override
  String get guideCaptureLead => 'Get it out of your head first; decide later.';

  @override
  String get guideCapture1Title => 'Tap + anywhere';

  @override
  String get guideCapture1Body =>
      'The capture button is on every tab. Write one line and press Enter; the field stays open for the next thought.';

  @override
  String get guideCapture2Title => 'Paste a brain-dump';

  @override
  String get guideCapture2Body =>
      'Paste several lines at once and each line becomes its own item.';

  @override
  String get guideCapture3Title => 'Share from other apps';

  @override
  String get guideCapture3Body =>
      'Share text from a message or a web page to Clearing to capture it.';

  @override
  String get guideCapture4Title => 'From your home screen';

  @override
  String get guideCapture4Body =>
      'Add the quick-capture widget: long-press the home screen, then Widgets › Clearing.';

  @override
  String get guideDecideTitle => 'Deciding what things mean';

  @override
  String get guideDecideLead =>
      'Every thought in the Inbox gets a place, in a few taps.';

  @override
  String get guideDecide1Title => 'Clarify step by step';

  @override
  String get guideDecide1Body =>
      'Tap an Inbox item. Clearing asks: is it actionable, what’s the next action, is someone else doing it, and when?';

  @override
  String get guideDecide2Title => 'Swipe shortcuts';

  @override
  String get guideDecide2Body =>
      'Swipe right for Today or This week; swipe left to pick a date, keep it for Someday, or delete it.';

  @override
  String get guideDecide3Title => 'Done means…';

  @override
  String get guideDecide3Body =>
      'For anything vague, write what finished looks like, and break it into steps.';

  @override
  String get guideDecide4Title => 'Waiting on someone';

  @override
  String get guideDecide4Body =>
      'If someone else is doing it, note who, and when to follow up.';

  @override
  String get guideTodayTitle => 'Today and must-dos';

  @override
  String get guideTodayLead =>
      'Today shows what you planned for today, and keeps it small.';

  @override
  String get guideToday1Title => 'Must-dos';

  @override
  String get guideToday1Body =>
      'Star up to three things that truly must happen. Everything else stays visible below.';

  @override
  String get guideToday2Title => 'Carried over';

  @override
  String get guideToday2Body =>
      'Things from earlier days wait quietly at the bottom. Nothing turns red.';

  @override
  String get guideToday3Title => 'This week';

  @override
  String get guideToday3Body =>
      'Things for this week, without a day, gather in one row.';

  @override
  String get guideToday4Title => 'Done, and undo';

  @override
  String get guideToday4Body =>
      'Tap the ring when done. Changed your mind? Tap Undo, or untick it in Lists › Done.';

  @override
  String get guideTimeTitle => 'Dates, reminders and repeats';

  @override
  String get guideTimeLead =>
      'When you’ll do it, when it’s due, and when to be reminded are three separate things.';

  @override
  String get guideTime1Title => 'Do on, deadline, remind me';

  @override
  String get guideTime1Body =>
      '“When” is the day you plan to do it. A deadline is when it’s due. A reminder is a notification; you can have up to three.';

  @override
  String get guideTime2Title => 'Repeats';

  @override
  String get guideTime2Body =>
      'Daily, weekly or monthly, or counted from when you finish (good for haircuts). Missed repeats never pile up.';

  @override
  String get guideTime3Title => 'Quiet hours';

  @override
  String get guideTime3Body =>
      'Early reminders wait until morning; ones you timed exactly still arrive.';

  @override
  String get guideTime4Title => 'Morning summary';

  @override
  String get guideTime4Body =>
      'Turn on one note each morning with today’s must-dos, in Settings › Reminders.';

  @override
  String get guideReviewTitle => 'Reviews and resets';

  @override
  String get guideReviewLead => 'Two short routines that keep your head clear.';

  @override
  String get guideReview1Title => 'Weekly review';

  @override
  String get guideReview1Body =>
      'About 15 minutes: empty your head, sort the Inbox, look back at last week and ahead at the next.';

  @override
  String get guideReview2Title => 'Overwhelm reset';

  @override
  String get guideReview2Body =>
      'When it’s all too much, five quick steps narrow everything down to one thing.';

  @override
  String get guideReview3Title => 'Focus';

  @override
  String get guideReview3Body =>
      'Shows a single item and nothing else, until it’s done.';

  @override
  String get guideReview4Title => 'Print a worksheet';

  @override
  String get guideReview4Body =>
      'Print today or this week on one page, with room to write.';

  @override
  String get guideOrganizeTitle => 'Lists, blocks and templates';

  @override
  String get guideOrganizeLead =>
      'Group things by context, and reuse what you do often.';

  @override
  String get guideOrganize1Title => 'Lists';

  @override
  String get guideOrganize1Body =>
      'Life Admin, Errands, and your own lists. An item can be in a list and planned for a day.';

  @override
  String get guideOrganize2Title => 'Time blocks';

  @override
  String get guideOrganize2Body =>
      'Block out time for a whole list, like Errands on Saturday morning, and it shows as one entry on Today.';

  @override
  String get guideOrganize3Title => 'Templates and routines';

  @override
  String get guideOrganize3Body =>
      'Save checklists you use again and again. Make one a routine and it arrives on its own schedule.';

  @override
  String get guideOrganize4Title => 'Search';

  @override
  String get guideOrganize4Body =>
      'Find anything, including done items, from the search icon.';

  @override
  String get guideDataTitle => 'Your data and privacy';

  @override
  String get guideDataLead => 'Clearing keeps everything on this phone.';

  @override
  String get guideData1Title => 'No account, no internet';

  @override
  String get guideData1Body =>
      'There’s no server and no tracking; the app can’t reach the internet at all.';

  @override
  String get guideData2Title => 'Backups';

  @override
  String get guideData2Body =>
      'Export a copy in Settings › Backup, and restore it on any phone.';

  @override
  String get guideData3Title => 'Moving phones';

  @override
  String get guideData3Body =>
      'Android’s phone-to-phone transfer brings Clearing’s data along, or use a backup.';

  @override
  String get guideData4Title => 'Trash and archive';

  @override
  String get guideData4Body =>
      'Deleted items stay in Trash for 30 days; done items move to the archive and stay searchable.';

  @override
  String effortMinutes(int count) {
    return '$count min';
  }

  @override
  String get effortHour => '1 hour';

  @override
  String get effortLonger => 'Longer';

  @override
  String get effortTitle => 'How long?';

  @override
  String get contextHome => 'Home';

  @override
  String get contextOut => 'Out';

  @override
  String get contextComputer => 'Computer';

  @override
  String get contextPhone => 'Phone';

  @override
  String get contextLowEnergy => 'Low energy';

  @override
  String get contextsTitle => 'Where or how';

  @override
  String get contextsManage => 'Edit contexts';

  @override
  String get contextsNew => 'New context';

  @override
  String get contextsHint =>
      'Contexts say where or how something can be done, so Today can show what fits right now.';

  @override
  String get captureToInbox => 'Inbox';

  @override
  String get captureDestination => 'Save to';

  @override
  String captureChipRemove(String label) {
    return 'Keep “$label” in the title';
  }

  @override
  String get captureUnderstood => 'Understood';

  @override
  String get captureChipMustDo => 'Must-do';

  @override
  String captureChipWaiting(String person) {
    return 'Waiting on $person';
  }

  @override
  String captureChipDue(String date) {
    return 'Due $date';
  }

  @override
  String get captureMustDoFull =>
      'Today’s must-dos are full, so it’s on Today instead.';

  @override
  String captureDuplicate(String title) {
    return 'Looks like “$title” is already here.';
  }

  @override
  String get captureDuplicateMerge => 'Keep just one';

  @override
  String get captureDuplicateKeep => 'Keep both';

  @override
  String get captureDuplicateMerged => 'Kept the one already there';

  @override
  String get captureEditSaved => 'Edit this thought';

  @override
  String get captureRemoveSaved => 'Remove it';

  @override
  String get captureTemplates => 'Templates';

  @override
  String captureTemplateStarted(String name) {
    return 'Started “$name”';
  }

  @override
  String get captureVoice => 'Speak';

  @override
  String get captureVoiceListening => 'Listening… pause to start a new line';

  @override
  String get captureVoiceStop => 'Stop listening';

  @override
  String get captureVoiceFailed =>
      'Couldn’t listen. Speech works offline once the language is downloaded in Android settings.';

  @override
  String get captureVoicePermission =>
      'Clearing listens only while you hold the button, on this phone. Nothing is recorded or sent anywhere.';

  @override
  String get captureVoicePermissionTitle => 'Use the microphone?';

  @override
  String get captureVoiceAllow => 'Allow';

  @override
  String selectCount(int count) {
    return '$count selected';
  }

  @override
  String get selectClear => 'Stop selecting';

  @override
  String get selectThis => 'Select';

  @override
  String get selectDeselect => 'Deselect';

  @override
  String get selectMoveToList => 'Move to list';

  @override
  String get selectMoreActions => 'More actions';

  @override
  String selectDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count done',
      one: '1 done',
    );
    return '$_temp0';
  }

  @override
  String selectPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planned',
      one: '1 planned',
    );
    return '$_temp0';
  }

  @override
  String selectMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moved',
      one: '1 moved',
    );
    return '$_temp0';
  }

  @override
  String selectTrashed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moved to Trash',
      one: '1 moved to Trash',
    );
    return '$_temp0';
  }

  @override
  String selectSomeday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moved to Someday',
      one: '1 moved to Someday',
    );
    return '$_temp0';
  }

  @override
  String get selectHint =>
      'Tip: press and hold any item to select several at once.';

  @override
  String get undoHistoryTitle => 'Recently changed';

  @override
  String get undoHistoryEmpty => 'Nothing changed yet in this session.';

  @override
  String get undoHistoryHint =>
      'The last ten changes since you opened Clearing. Undo puts things back exactly as they were.';

  @override
  String get undoHistoryUndone => 'Undone';

  @override
  String itemTileAge(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'waiting $days days',
      one: 'waiting 1 day',
    );
    return '$_temp0';
  }

  @override
  String itemTileAgeWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'waiting $weeks weeks',
      one: 'waiting 1 week',
    );
    return '$_temp0';
  }

  @override
  String get itemTileNow => 'Now';

  @override
  String get settingsSwipeSection => 'Swipes';

  @override
  String get settingsSwipeHint =>
      'What a swipe on an item does outside the Inbox.';

  @override
  String get settingsSwipeStart => 'Swipe right';

  @override
  String get settingsSwipeEnd => 'Swipe left';

  @override
  String get swipeNone => 'Nothing';

  @override
  String get fieldNoteLabel => 'Field note';

  @override
  String fieldNoteFound(String name, String body) {
    return 'Field note: $name. $body';
  }

  @override
  String get fieldNotesTitle => 'Field notes';

  @override
  String get fieldNotesHint =>
      'Small discoveries, each found by trying something once. There’s no order and nothing to keep up.';

  @override
  String fieldNoteLocked(String hint) {
    return 'Not found yet: $hint';
  }

  @override
  String get noteFirstLightName => 'First light';

  @override
  String get noteFirstLightBody => 'You got a thought out of your head.';

  @override
  String get noteFirstLightHint => 'capture a thought';

  @override
  String get noteHomeName => 'A home for everything';

  @override
  String get noteHomeBody => 'You gave a thought a list to live in.';

  @override
  String get noteHomeHint => 'clarify something into a list';

  @override
  String get noteHandsName => 'Out of your hands';

  @override
  String get noteHandsBody =>
      'Someone else is doing it; Clearing will remember to check.';

  @override
  String get noteHandsHint => 'mark something as waiting on someone';

  @override
  String get noteLongViewName => 'The long view';

  @override
  String get noteLongViewBody =>
      'Something that comes back now looks after itself.';

  @override
  String get noteLongViewHint => 'make something repeat';

  @override
  String get noteBreathName => 'Deep breath';

  @override
  String get noteBreathBody => 'You found the overwhelm reset.';

  @override
  String get noteBreathHint => 'try the overwhelm reset';

  @override
  String get notePathName => 'The path';

  @override
  String get notePathBody =>
      'Your first weekly review. Your clearing has its first tree.';

  @override
  String get notePathHint => 'finish a weekly review';

  @override
  String get noteOneThingName => 'Just one thing';

  @override
  String get noteOneThingBody => 'You finished something from the focus view.';

  @override
  String get noteOneThingHint => 'finish something in Focus';

  @override
  String get noteKeepingName => 'Safe keeping';

  @override
  String get noteKeepingBody => 'There’s a copy of everything, kept by you.';

  @override
  String get noteKeepingHint => 'make a backup';

  @override
  String get noteDoorstepName => 'From the doorstep';

  @override
  String get noteDoorstepBody => 'You captured without opening the app first.';

  @override
  String get noteDoorstepHint =>
      'capture from the widget, a share, a shortcut or your voice';

  @override
  String get noteOldTabName => 'Old tab';

  @override
  String get noteOldTabBody =>
      'You closed something that had been open for a month or more.';

  @override
  String get noteOldTabHint => 'close something that’s waited a month';

  @override
  String get noteOpenSkyName => 'Open sky';

  @override
  String get noteOpenSkyBody => 'Everything on Today, done.';

  @override
  String get noteOpenSkyHint => 'clear a whole Today';

  @override
  String get noteSeasonsName => 'Four seasons';

  @override
  String get noteSeasonsBody => 'You reviewed in every season of a year.';

  @override
  String get noteSeasonsHint =>
      'review at least once in each season, at any pace';

  @override
  String get groveTitle => 'Your clearing';

  @override
  String get groveMenu => 'Your clearing';

  @override
  String groveCaption(String season, int closed, int reviews, int oldTabs) {
    String _temp0 = intl.Intl.pluralLogic(
      closed,
      locale: localeName,
      other: '$closed things closed',
      one: '1 thing closed',
      zero: 'nothing closed yet',
    );
    String _temp1 = intl.Intl.pluralLogic(
      reviews,
      locale: localeName,
      other: '$reviews reviews',
      one: '1 review',
      zero: 'no reviews',
    );
    String _temp2 = intl.Intl.pluralLogic(
      oldTabs,
      locale: localeName,
      other: '$oldTabs old tabs cleared',
      one: '1 old tab cleared',
      zero: 'no old tabs',
    );
    return 'This $season: $_temp0, $_temp1, $_temp2.';
  }

  @override
  String get groveEmpty =>
      'Your clearing is ready. Close a thought or finish a review, and something will grow here. Nothing here ever wilts.';

  @override
  String groveDescription(
    int trees,
    int flowers,
    int cairns,
    int birds,
    String extras,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      trees,
      locale: localeName,
      other: '$trees trees',
      one: '1 tree',
      zero: 'no trees yet',
    );
    String _temp1 = intl.Intl.pluralLogic(
      flowers,
      locale: localeName,
      other: '$flowers wildflowers',
      one: '1 wildflower',
      zero: 'no wildflowers',
    );
    String _temp2 = intl.Intl.pluralLogic(
      cairns,
      locale: localeName,
      other: '$cairns cairns',
      one: '1 cairn',
      zero: 'no cairns',
    );
    String _temp3 = intl.Intl.pluralLogic(
      birds,
      locale: localeName,
      other: '$birds birds',
      one: '1 bird',
      zero: 'no birds',
    );
    return 'Your clearing: $_temp0, $_temp1, $_temp2, $_temp3$extras.';
  }

  @override
  String get groveHasStream => ', a stream';

  @override
  String get groveHasBench => ', a bench';

  @override
  String groveHasLanterns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lanterns',
      one: '1 lantern',
    );
    return ', $_temp0';
  }

  @override
  String get groveTapHint =>
      'Tap anything in your clearing to see what it was for.';

  @override
  String groveCairn(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things closed',
      one: '1 thing closed',
    );
    return 'Week of $date: $_temp0';
  }

  @override
  String groveFlower(String title, int days, String date) {
    return '$title, waited $days days, closed $date';
  }

  @override
  String groveTree(String date) {
    return 'A weekly review, $date';
  }

  @override
  String groveOldTree(String date) {
    return 'A tree from an earlier season, from your review on $date';
  }

  @override
  String groveStream(String date) {
    return 'Your first overwhelm reset, $date';
  }

  @override
  String groveBird(String date) {
    return 'Everything on Today done, $date';
  }

  @override
  String get groveBench => 'You keep a backup. A place to sit.';

  @override
  String groveLantern(String date) {
    return 'Something you were waiting for came back, $date';
  }

  @override
  String groveStep(String date) {
    return 'An invitation taken up, $date';
  }

  @override
  String get groveSeasonSpring => 'spring';

  @override
  String get groveSeasonMonsoon => 'monsoon';

  @override
  String get groveSeasonSummer => 'summer';

  @override
  String get groveSeasonAutumn => 'autumn';

  @override
  String get groveSeasonWinter => 'winter';

  @override
  String groveSeasonCard(String season, String year) {
    return '$season $year';
  }

  @override
  String get groveAlbum => 'Season cards';

  @override
  String get groveAlbumHint =>
      'At each season’s turn, your clearing is pressed into a card and kept. The trees stay standing.';

  @override
  String get groveAlbumEmpty =>
      'Your first card is pressed when this season turns.';

  @override
  String get groveCairnTitle => 'The cairn';

  @override
  String get groveCairnHint =>
      'Everything you’ve closed, a stone each, a pile a week. Tap a week to see what was in it.';

  @override
  String groveCairnWeek(String date) {
    return 'Week of $date';
  }

  @override
  String get groveCairnEmpty =>
      'Things you finish will stack up here, one stone each.';

  @override
  String get groveCairnOldOnly => 'Only old tabs';

  @override
  String groveCairnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count closed',
      one: '1 closed',
    );
    return '$_temp0';
  }

  @override
  String get groveJournal => 'Glad you did';

  @override
  String get groveJournalEmpty =>
      'At the end of a weekly review you can note something you’re glad you did. It stays here, just for you.';

  @override
  String get groveMore => 'More in your clearing';

  @override
  String get groveSettings => 'Seasons';

  @override
  String get groveHemisphere => 'Where you are';

  @override
  String get groveNorth => 'Northern half of the world';

  @override
  String get groveSouth => 'Southern half of the world';

  @override
  String get groveWetSeason => 'Show monsoon instead of spring';

  @override
  String get settingsGroveSection => 'Your clearing';

  @override
  String get settingsGroveHint =>
      'Your progress as a calm, growing picture. Nothing in it ever wilts or resets.';

  @override
  String get settingsGroveShow => 'Show your clearing';

  @override
  String get settingsInvitations => 'Weekly invitations';

  @override
  String get settingsInvitationsHint =>
      'One optional idea a week on Today. Ignoring it does nothing.';

  @override
  String get groveAskTitle => 'See your progress as a growing clearing?';

  @override
  String get groveAskBody =>
      'Each thing you close and each review you finish helps a small, private landscape grow. It never shrinks, and there are no streaks to keep. You can turn it off any time.';

  @override
  String get groveAskYes => 'Yes, show it';

  @override
  String get groveAskNo => 'No thanks';

  @override
  String get inviteLabel => 'This week’s invitation';

  @override
  String get inviteHomeForThree => 'Give three inbox items a home.';

  @override
  String get inviteDoneMeans =>
      'Write a “Done means…” for one thing that’s been sitting.';

  @override
  String get inviteOldThought =>
      'Close one thing that’s been on your mind for more than a month.';

  @override
  String get inviteParkAnIdea =>
      'Park one idea in Someday that you won’t do this month.';

  @override
  String get inviteTryFocus => 'Try the focus view on your must-do.';

  @override
  String get inviteTryReset =>
      'When it feels like a lot, try the overwhelm reset.';

  @override
  String get inviteAddEffort =>
      'Add how long two things take, so Today can show what fits.';

  @override
  String get inviteBackUp => 'Make a backup, or turn on automatic ones.';

  @override
  String get inviteDidIt => 'Did it';

  @override
  String get inviteNotThisWeek => 'Not this week';

  @override
  String get inviteOff => 'Don’t show invitations';

  @override
  String get inviteThanks => 'A stepping stone joins your clearing.';

  @override
  String get inviteGo => 'Go';

  @override
  String get lookBackTitle => 'Look back';

  @override
  String lookBackClosed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This week you closed $count things.',
      one: 'This week you closed 1 thing.',
      zero: 'A quieter week.',
    );
    return '$_temp0';
  }

  @override
  String get lookBackQuiet => 'Clearing your inbox still counts.';

  @override
  String get lookBackBest => 'More than any week this season.';

  @override
  String lookBackOldest(String title, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'The oldest was “$title”, which had waited $_temp0.';
  }

  @override
  String lookBackParked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things moved to Someday, so they’re out of your head.',
      one: '1 thing moved to Someday, so it’s out of your head.',
    );
    return '$_temp0';
  }

  @override
  String get lookBackTree => 'A new tree is growing in your clearing.';

  @override
  String get lookBackWins => 'Anything you’re glad you did this week?';

  @override
  String get lookBackWinsHint => 'Optional, and only for you';

  @override
  String get insightsTitle => 'Your rhythm';

  @override
  String get insightsHint =>
      'What the last 90 days look like, worked out on this phone. Observations, never judgements.';

  @override
  String get insightsEmpty =>
      'Once you’ve closed a few things, you’ll see your rhythm here.';

  @override
  String get insightsByHour => 'When you close things';

  @override
  String insightsByHourSummary(String hour) {
    return 'Things closed by hour of day. Most around $hour.';
  }

  @override
  String insightsBarTooltip(String hour, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count closed',
      one: '1 closed',
    );
    return '$hour: $_temp0';
  }

  @override
  String get insightsMorning =>
      'You close most things before noon. Morning must-dos might suit you.';

  @override
  String get insightsAfternoon => 'Afternoons are when most things get closed.';

  @override
  String get insightsEvening =>
      'You close most things in the evening. A short evening list might suit you.';

  @override
  String get insightsNight => 'Late hours are your closing time.';

  @override
  String insightsInboxWait(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'about $days days',
      one: 'about a day',
      zero: 'less than a day',
    );
    return 'Thoughts usually wait $_temp0 in your Inbox before you decide.';
  }

  @override
  String insightsCloseTime(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'about $days days',
      one: 'about a day',
      zero: 'less than a day',
    );
    return 'From capture to done usually takes $_temp0.';
  }

  @override
  String insightsFastestList(String list, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'about $days days',
      one: 'about a day',
      zero: 'under a day',
    );
    return '$list moves fastest: things there close in $_temp0.';
  }

  @override
  String insightsMostParked(String list) {
    return 'Most of what’s in Someday came from $list.';
  }

  @override
  String get insightsTable => 'Closed by hour';

  @override
  String get insightsShareStats => 'Share anonymous stats';

  @override
  String get insightsShareStatsHint =>
      'Counts only, no titles or notes. Nothing is sent unless you pick where to send it.';

  @override
  String get autoBackupSection => 'Automatic backups';

  @override
  String get autoBackupSwitch => 'Back up every day';

  @override
  String get autoBackupHint =>
      'A copy each night, into a folder you choose. The last week of copies, and one a week for a month, are kept.';

  @override
  String get autoBackupFolder => 'Folder';

  @override
  String get autoBackupFolderNone => 'Not chosen';

  @override
  String get autoBackupFolderChange => 'Choose a folder';

  @override
  String autoBackupLast(String when) {
    return 'Backed up automatically, last $when';
  }

  @override
  String get autoBackupNotYet =>
      'The first copy is made tonight, or tap Back up now.';

  @override
  String get autoBackupNow => 'Back up now';

  @override
  String get autoBackupDone => 'Backed up';

  @override
  String get autoBackupFailed =>
      'Couldn’t write to that folder. Try choosing it again.';

  @override
  String get autoBackupEncrypt => 'Lock backups with a passphrase';

  @override
  String get autoBackupEncryptHint =>
      'Anyone who finds the file can’t read it without the passphrase.';

  @override
  String get passphraseTitle => 'Choose a passphrase';

  @override
  String get passphraseWarning =>
      'Write it down somewhere safe. If it’s forgotten, these backups can’t be opened by anyone, including Clearing.';

  @override
  String get passphraseField => 'Passphrase';

  @override
  String get passphraseAgain => 'Passphrase again';

  @override
  String get passphraseMismatch => 'The two don’t match.';

  @override
  String get passphraseShort => 'Use at least 8 characters.';

  @override
  String get passphraseAsk => 'This backup is locked';

  @override
  String get passphraseAskBody => 'Enter the passphrase it was made with.';

  @override
  String get passphraseWrong => 'That passphrase doesn’t open this backup.';

  @override
  String get passphraseUnlock => 'Open';

  @override
  String get backupFoundTitle => 'Restore an automatic backup';

  @override
  String get backupFoundNone => 'No automatic backups in the folder yet.';

  @override
  String get backupNewer =>
      'This backup is from a newer version of Clearing. What this version knows about will be restored.';

  @override
  String get moveSection => 'Moving to a new phone';

  @override
  String get moveSend => 'Send everything to a new phone';

  @override
  String get moveSendHint =>
      'Share a backup by Nearby Share, Bluetooth or a cable. On the new phone, choose “Restore from a backup” in the welcome.';

  @override
  String get welcomeRestore => 'Restore from a backup';

  @override
  String get todayGoodMorning => 'Good morning';

  @override
  String get todayGoodAfternoon => 'Good afternoon';

  @override
  String get todayGoodEvening => 'Good evening';

  @override
  String get todayAllClearTitle => 'Open sky';

  @override
  String todayAllClearReflection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things closed today.',
      one: 'One thing closed today.',
    );
    return '$_temp0';
  }

  @override
  String get todayAllClearRest => 'Nothing else is asking for you today.';

  @override
  String todayTomorrowPeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tomorrow: $count planned',
      one: 'Tomorrow: 1 planned',
    );
    return '$_temp0';
  }

  @override
  String get todayDecideThese => 'Decide these';

  @override
  String get todayMenuGrove => 'Your clearing';

  @override
  String get todayMenuHaveTime => 'I have a few minutes…';

  @override
  String get todayMenuReorder => 'Reorder Today';

  @override
  String get todayMenuRecent => 'Recently changed';

  @override
  String planDayTitle(int cap) {
    return 'Pick up to $cap for today';
  }

  @override
  String get planDayHint =>
      'From what you set for this week. The rest stays where it is.';

  @override
  String get planDayPrompt => 'Plan your day?';

  @override
  String get planDayPromptHint => 'Pick a few from this week';

  @override
  String get planDayStart => 'Put on Today';

  @override
  String get planDayNever => 'Don’t offer this';

  @override
  String get planDayMustDo => 'Make the first a must-do';

  @override
  String get fitsNow => 'What fits now';

  @override
  String get fitsNowNone =>
      'Nothing on Today fits that. Try “I have a few minutes” for this week too.';

  @override
  String get haveTimeTitle => 'I have…';

  @override
  String get haveTimeWhere => 'And I’m…';

  @override
  String get haveTimeAnywhere => 'Anywhere';

  @override
  String get haveTimeResults => 'These fit';

  @override
  String get haveTimeNone =>
      'Nothing with a length that fits yet. Add how long things take from an item’s details.';

  @override
  String get haveTimeFocus => 'Focus on it';

  @override
  String get decideTitle => 'Carried over';

  @override
  String decideHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0. No wrong answers.';
  }

  @override
  String get decideLetGo => 'Let it go';

  @override
  String get decideDoneTitle => 'All decided';

  @override
  String get decideDoneBody => 'Today is lighter now.';

  @override
  String get reorderTitle => 'Reorder';

  @override
  String get reorderHint =>
      'Drag the handles, or use the actions with a screen reader. Timed items keep to their times.';

  @override
  String get reorderMoveUp => 'Move up';

  @override
  String get reorderMoveDown => 'Move down';

  @override
  String get pullToCapture => 'Release to capture';

  @override
  String get clarifyTwoMinutes => 'Takes under 2 minutes? Do it now';

  @override
  String get clarifyTwoMinutesHint => 'Then it’s done, not filed.';

  @override
  String get clarifyBreakDown => 'Break it into steps';

  @override
  String get clarifyDoneMeansExample1 => 'e.g. Form posted';

  @override
  String get clarifyDoneMeansExample2 => 'e.g. Call made, date booked';

  @override
  String get clarifyDoneMeansExample3 => 'e.g. Draft sent to Sam';

  @override
  String get clarifyDoneMeansExample4 => 'e.g. Receipt filed';

  @override
  String get clarifySuggestedList =>
      'Suggested from similar things you’ve filed';

  @override
  String clarifyOnDate(String date) {
    return 'On $date';
  }

  @override
  String get clarifyOnDateHint => 'As you typed it';

  @override
  String clarifyProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get clarifyStopHere => 'Stop here';

  @override
  String get inboxClarifyAll => 'Clarify all';

  @override
  String get inboxCards => 'Quick decide';

  @override
  String get cardsTitle => 'Quick decide';

  @override
  String get cardsHint =>
      'Right: this week · Left: someday · Up: today · Down: delete · Tap: the full questions';

  @override
  String cardsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0';
  }

  @override
  String get cardsDone => 'Inbox is clear';

  @override
  String get cardsDetails => 'All questions';

  @override
  String get itemEffort => 'How long';

  @override
  String get itemEffortNone => 'Not set';

  @override
  String get itemContexts => 'Where or how';

  @override
  String get itemContextsNone => 'Anywhere';

  @override
  String get itemFirstStep => 'Smallest first step';

  @override
  String get itemFirstStepHint => 'e.g. Open the form';

  @override
  String get itemActivity => 'History';

  @override
  String activityCaptured(String date) {
    return 'Captured $date';
  }

  @override
  String activityPlanned(String date) {
    return 'Planned $date';
  }

  @override
  String activityWaiting(String date) {
    return 'Handed on $date';
  }

  @override
  String activityResolved(String date) {
    return 'Came back $date';
  }

  @override
  String activitySomeday(String date) {
    return 'Parked $date';
  }

  @override
  String activityDone(String date) {
    return 'Done $date';
  }

  @override
  String activityReopened(String date) {
    return 'Reopened $date';
  }

  @override
  String activityTrashed(String date) {
    return 'Deleted $date';
  }

  @override
  String activityCarried(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Carried over $days days',
      one: 'Carried over 1 day',
    );
    return '$_temp0';
  }

  @override
  String get itemPhotos => 'Photos';

  @override
  String get itemAddPhoto => 'Add a photo';

  @override
  String get itemTakePhoto => 'Take a photo';

  @override
  String get itemPickPhoto => 'Choose from gallery';

  @override
  String get itemRemovePhoto => 'Remove photo';

  @override
  String itemPhotoLabel(int n) {
    return 'Photo $n';
  }

  @override
  String get itemPhotosHint => 'Kept on this phone and in your backups.';

  @override
  String get itemMakeProject => 'Make this a project';

  @override
  String itemMadeProject(String name) {
    return '“$name” is now a project';
  }

  @override
  String get itemOpenLink => 'Open';

  @override
  String get itemNotesLinks => 'Links';

  @override
  String projectNextTitle(String name) {
    return 'What’s next for “$name”?';
  }

  @override
  String get projectNextHint => 'Pick the next step for this week, or add one.';

  @override
  String get projectAddStep => 'Add a step';

  @override
  String get projectNextNone =>
      'That was the last step. Add another, or let the project rest.';

  @override
  String get projectLabel => 'Project';

  @override
  String get projectOutcome => 'Outcome';

  @override
  String get projectOutcomeHint => 'What’s true when it’s finished?';

  @override
  String get projectTarget => 'Aiming for';

  @override
  String get projectTargetNone => 'No date';

  @override
  String get projectOnlyNext =>
      'Only the next step shows on Today and This week.';

  @override
  String get projectNew => 'New project';

  @override
  String get projectMakeList => 'Treat as a project';

  @override
  String get projectsSection => 'Projects';

  @override
  String get listColour => 'Colour';

  @override
  String get listColourNone => 'None';

  @override
  String get listColourMoss => 'Moss';

  @override
  String get listColourDawn => 'Dawn';

  @override
  String get listColourSky => 'Sky';

  @override
  String get listColourClay => 'Clay';

  @override
  String get listColourHeather => 'Heather';

  @override
  String get listPin => 'Pin to top';

  @override
  String get listUnpin => 'Unpin';

  @override
  String get listPinned => 'Pinned';

  @override
  String get listShoppingMode => 'Shopping mode';

  @override
  String get listShoppingHint =>
      'Bigger rows; ticked things move to the bottom until you clear them.';

  @override
  String get listClearTicked => 'Clear ticked';

  @override
  String get listReorder => 'Reorder';

  @override
  String get savedSearchesSection => 'Smart lists';

  @override
  String get savedSearchSave => 'Save as a smart list';

  @override
  String get savedSearchName => 'Smart list name';

  @override
  String get savedSearchSaved => 'Saved to Lists';

  @override
  String get savedSearchDelete => 'Remove smart list';

  @override
  String get savedSearchEmpty => 'Nothing matches right now.';

  @override
  String get searchRecent => 'Recent';

  @override
  String get searchClearRecent => 'Clear';

  @override
  String get searchContext => 'Where';

  @override
  String get searchAnyContext => 'Anywhere';

  @override
  String get searchEffort => 'Length';

  @override
  String get searchAnyEffort => 'Any length';

  @override
  String searchUpTo(String length) {
    return 'Up to $length';
  }

  @override
  String get upcomingMonthView => 'Month view';

  @override
  String get upcomingSubtitleMonth =>
      'Dots show how much is planned; tap a day';

  @override
  String get monthPrevious => 'Previous month';

  @override
  String get monthNextLabel => 'Next month';

  @override
  String monthDayCount(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planned',
      one: '1 planned',
      zero: 'nothing planned',
    );
    return '$date: $_temp0';
  }

  @override
  String busyDay(int count) {
    return 'A full day: $count planned.';
  }

  @override
  String get busySpread => 'Spread some out';

  @override
  String busySpreadDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count across the next days',
      one: 'Moved 1 to the next day',
    );
    return '$_temp0';
  }

  @override
  String get dragToDay => 'Drag to another day';

  @override
  String followUpOn(String title) {
    return 'Follow up: $title';
  }

  @override
  String get focusFirstStep => 'First step';

  @override
  String get focusFirstStepDone => 'First step done';

  @override
  String get focusStuck => 'I’m stuck';

  @override
  String get focusStuckTitle => 'That happens. Try one of these:';

  @override
  String get focusStuckBreak => 'Break it into smaller steps';

  @override
  String get focusStuckDoneMeans => 'Change what “done” means';

  @override
  String get focusStuckLater => 'Put it back for now';

  @override
  String get focusTimebox => 'Give it a few minutes';

  @override
  String get focusTimeboxRunning =>
      'The sky clears as the minutes pass. Nothing is recorded.';

  @override
  String get focusTimeboxDone =>
      'Time’s up. Carry on, or stop here; either is fine.';

  @override
  String get focusTimeboxStop => 'Stop the timebox';

  @override
  String get settingsFocusTimebox => 'Offer a timebox in Focus';

  @override
  String get settingsFocusTimeboxHint =>
      '5, 15 or 25 minutes, shown as the sky clearing. Nothing is tracked.';

  @override
  String get breatheTitle => 'A few breaths first?';

  @override
  String get breatheIn => 'Breathe in';

  @override
  String get breatheOut => 'Breathe out';

  @override
  String get breatheSkip => 'Skip';

  @override
  String get breatheReady => 'Ready';

  @override
  String get settingsBreathing => 'Offer a few breaths before the reset';

  @override
  String get reviewLengthTitle => 'How long have you got?';

  @override
  String get reviewQuick => 'Quick (about 5 minutes)';

  @override
  String get reviewQuickHint => 'Your inbox and next week';

  @override
  String get reviewFull => 'Full';

  @override
  String get reviewFullHint => 'Every step, about 15 minutes';

  @override
  String get reviewQuickCounts => 'A quick one beats none.';

  @override
  String get settingsReviewLength => 'Review length';

  @override
  String get settingsReviewAsk => 'Ask each time';

  @override
  String get reviewOwnChecks => 'Your own checks';

  @override
  String get reviewOwnChecksHint => 'Tick what you’ve looked at.';

  @override
  String get settingsReviewPrompts => 'Your own review checks';

  @override
  String get settingsReviewPromptsHint =>
      'e.g. Check the bank account, plan meals';

  @override
  String get reviewPromptAdd => 'Add a check';

  @override
  String get settingsWinsPrompt => 'Ask what went well';

  @override
  String reviewProjectsStuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects have nothing planned',
      one: '1 project has nothing planned',
    );
    return '$_temp0';
  }

  @override
  String get reviewProjectAddStep => 'Add a step';

  @override
  String get reviewProjectPark => 'Park it';

  @override
  String get settingsSearch => 'Search settings';

  @override
  String get settingsSearchNone => 'No setting matches that.';

  @override
  String get settingsCaptureSection => 'Capture';

  @override
  String get settingsCaptureHint => 'How Clearing reads what you type.';

  @override
  String get settingsParse => 'Understand dates and lists as I type';

  @override
  String get settingsParseHint =>
      '“pay rent fri 9am #home !” becomes Pay rent, Friday 9:00, Home, must-do.';

  @override
  String get settingsParsedSkipInbox => 'Things with a date skip the Inbox';

  @override
  String get settingsContexts => 'Contexts';

  @override
  String get settingsFocusSection => 'Focus and reset';

  @override
  String get settingsFocusHint =>
      'Small helps for starting and for heavy days.';

  @override
  String get settingsPlanMyDay => 'Offer to plan my day';

  @override
  String get settingsPrivacySection => 'Privacy';

  @override
  String get settingsPrivacyHint => 'Who can see what, on this phone.';

  @override
  String get settingsHideOnLock => 'Hide titles on the lock screen';

  @override
  String get settingsHideOnLockHint =>
      'The lock screen shows that there’s a reminder, not what it says.';

  @override
  String get settingsAppLock => 'Lock Clearing';

  @override
  String get settingsAppLockHint =>
      'With your fingerprint, face or screen lock. Quick capture still works while locked.';

  @override
  String get settingsAppLockUnavailable =>
      'Set a screen lock on the phone first.';

  @override
  String get settingsLockAfter => 'Lock after';

  @override
  String get settingsLockImmediately => 'Leaving the app';

  @override
  String settingsLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes away',
      one: '1 minute away',
    );
    return '$_temp0';
  }

  @override
  String get lockTitle => 'Clearing is locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockReason => 'Unlock Clearing';

  @override
  String get lockCapture => 'Capture without unlocking';

  @override
  String get settingsFeedbackSection => 'Feedback';

  @override
  String get settingsFeedbackHint => 'Small signals when something’s done.';

  @override
  String get settingsSounds => 'Sounds';

  @override
  String get settingsSoundsHint =>
      'A short chime when Today is clear and when a review is finished. Silent when the phone is.';

  @override
  String get settingsThemeVariant => 'Glade colours';

  @override
  String get settingsThemeVariantHint =>
      'More are found as your clearing grows.';

  @override
  String get variantGlade => 'Glade';

  @override
  String get variantAutumn => 'Autumn';

  @override
  String get variantMonsoon => 'Monsoon';

  @override
  String get variantWinter => 'Winter';

  @override
  String get variantNightSky => 'Night sky';

  @override
  String variantLocked(String name) {
    return '$name, not found yet';
  }

  @override
  String get variantHowAutumn => 'Comes with your first season card';

  @override
  String get variantHowMonsoon => 'Comes after 10 reviews';

  @override
  String get variantHowWinter => 'Comes after 25 old tabs closed';

  @override
  String get variantHowNightSky => 'Comes after 100 things closed';

  @override
  String get settingsUnlockAll => 'Show all colours';

  @override
  String get settingsHighContrast => 'High contrast';

  @override
  String get settingsHighContrastHint =>
      'Darker text and outlines, for low vision. Always available.';

  @override
  String get settingsRoomyText => 'Roomier text';

  @override
  String get settingsRoomyTextHint =>
      'More space between lines and letters, which some readers find easier.';

  @override
  String get settingsTextPreview => 'Text size preview';

  @override
  String get settingsTextPreviewHint =>
      'Text size follows the phone’s setting.';

  @override
  String get settingsMakeYours => 'Make Clearing yours';

  @override
  String get settingsMakeYoursHint => 'One choice that sets the rest';

  @override
  String get styleTitle => 'Make Clearing yours';

  @override
  String get styleHint =>
      'Pick a feel. You can change any part of it afterwards.';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleMinimalHint =>
      'Just the lists. No clearing, no tips, no sounds, no morning summary.';

  @override
  String get styleGentle => 'Gentle';

  @override
  String get styleGentleHint =>
      'Tips as you go and your clearing, quietly. The default.';

  @override
  String get styleEncouraging => 'Encouraging';

  @override
  String get styleEncouragingHint =>
      'Your clearing, weekly invitations, sounds and a morning summary.';

  @override
  String get styleApplied =>
      'Done. Everything can still be changed in Settings.';

  @override
  String get settingsWhatsNew => 'What’s new';

  @override
  String get whatsNewTitle => 'What’s new in Clearing';

  @override
  String get whatsNew1Title => 'Type it the way you say it';

  @override
  String get whatsNew1Body =>
      '“Dentist fri 3pm” is planned for Friday at 3. Tap a chip to undo any part.';

  @override
  String get whatsNew2Title => 'Many at once';

  @override
  String get whatsNew2Body =>
      'Press and hold to select several things, then plan, move or finish them together.';

  @override
  String get whatsNew3Title => 'Your clearing';

  @override
  String get whatsNew3Body =>
      'An optional, private landscape that grows as you close things. Nothing in it ever wilts.';

  @override
  String get whatsNew4Title => 'Backups that look after themselves';

  @override
  String get whatsNew4Body =>
      'A copy every night into a folder you choose, locked with a passphrase if you like.';

  @override
  String get whatsNewTry => 'Show me';

  @override
  String get settingsDeveloper => 'Developer options';

  @override
  String get developerTitle => 'Developer options';

  @override
  String get developerHint =>
      'Unfinished features, for testing. Only in debug builds.';

  @override
  String get developerNoFlags => 'No unfinished features right now.';

  @override
  String get developerSeed => 'Add sample items';

  @override
  String get contextsScreenTitle => 'Contexts';

  @override
  String get contextsRename => 'Rename';

  @override
  String get contextsDelete => 'Delete';

  @override
  String get settingsExportCalendar => 'Export Upcoming as a calendar file';

  @override
  String get settingsExportCalendarHint =>
      'For importing into any calendar app. Clearing never reads your calendar.';

  @override
  String get settingsExportCalendarNone => 'Nothing dated in the next 90 days.';

  @override
  String get notifActionPickTime => 'Pick a time';

  @override
  String get notifActionCapture => 'Capture';

  @override
  String get notifReplyHint => 'Anything else on your mind?';

  @override
  String get repeatFlexible => 'Any days of the week';

  @override
  String get repeatFlexibleHint =>
      'A few times a week, whenever suits. Weeks that fall short just start fresh.';

  @override
  String repeatTimesAWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times a week, any days',
      one: 'Once a week, any day',
    );
    return '$_temp0';
  }

  @override
  String get repeatFewer => 'Fewer times';

  @override
  String get repeatMore => 'More times';

  @override
  String flexibleProgress(int done, int target) {
    return '$done of $target this week';
  }

  @override
  String get glossClarify =>
      'Clarify means deciding what a thought is: something to do, someone else’s, an idea for later, or nothing at all. Tap an item to start.';

  @override
  String get glossMustDo =>
      'Must-dos are the few things that have to happen today. Clearing keeps them to a small number on purpose.';

  @override
  String get glossCarried =>
      'Carried over means it was planned for an earlier day. No harm done: decide again when you’re ready.';

  @override
  String get glossWaiting =>
      'Waiting on is for things someone else is doing. Clearing reminds you to check in on the follow-up date.';

  @override
  String get glossSomeday =>
      'Someday holds ideas, not commitments. They never show on Today; the weekly review brings them back to look at.';

  @override
  String get guideShowMe => 'Show me';

  @override
  String get coachCapture =>
      'Tap here, or press N on a keyboard, to get a thought out of your head.';

  @override
  String get coachInbox =>
      'Everything you capture waits here until you decide what it is.';

  @override
  String get coachToday => 'Today: your must-dos first, the rest quiet below.';

  @override
  String get coachUpcoming =>
      'Dates, the week ahead, and the month at a glance.';

  @override
  String get coachLists =>
      'Lists, projects, smart lists, Someday and your settings.';

  @override
  String get coachGotIt => 'Got it';
}

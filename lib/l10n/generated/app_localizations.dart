import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The app's name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Clearing'**
  String get appName;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get commonFinish;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @whenToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get whenToday;

  /// No description provided for @whenThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get whenThisWeek;

  /// No description provided for @whenAnytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get whenAnytime;

  /// No description provided for @whenPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get whenPickDate;

  /// No description provided for @whenAnytimeHint.
  ///
  /// In en, this message translates to:
  /// **'No particular day'**
  String get whenAnytimeHint;

  /// No description provided for @whenQuestion.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get whenQuestion;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get tabInbox;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get tabLists;

  /// No description provided for @someday.
  ///
  /// In en, this message translates to:
  /// **'Someday'**
  String get someday;

  /// No description provided for @waitingOn.
  ///
  /// In en, this message translates to:
  /// **'Waiting on'**
  String get waitingOn;

  /// No description provided for @mustDo.
  ///
  /// In en, this message translates to:
  /// **'Must-do'**
  String get mustDo;

  /// Relative date label.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// Relative date label.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Start of a repeat rule.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String repeatEveryDay(int count);

  /// Start of a repeat rule.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String repeatEveryWeek(int count);

  /// Start of a repeat rule.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String repeatEveryMonth(int count);

  /// Repeat rule counted from completion, e.g. 'Every 6 weeks after it’s done'.
  ///
  /// In en, this message translates to:
  /// **'after it’s done'**
  String get repeatAfterDone;

  /// Weekdays of a weekly repeat, e.g. 'on Mon, Thu'.
  ///
  /// In en, this message translates to:
  /// **'on {days}'**
  String repeatOnDays(String days);

  /// Day of a monthly repeat; in English day is '5th'.
  ///
  /// In en, this message translates to:
  /// **'on the {day}'**
  String repeatOnMonthDay(String day);

  /// End date of a repeat.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String repeatUntil(String date);

  /// Maximum count of a repeat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{once} other{{count} times}}'**
  String repeatTimes(int count);

  /// A reminder at the item's own time.
  ///
  /// In en, this message translates to:
  /// **'At the time'**
  String get offsetAtTime;

  /// Reminder offset.
  ///
  /// In en, this message translates to:
  /// **'{count} min before'**
  String offsetMinutes(int count);

  /// Reminder offset.
  ///
  /// In en, this message translates to:
  /// **'{count} h before'**
  String offsetHours(int count);

  /// Reminder offset.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before} other{{count} days before}}'**
  String offsetDays(int count);

  /// Weekly review reminder title.
  ///
  /// In en, this message translates to:
  /// **'Time for your weekly review'**
  String get notifReviewTitle;

  /// Weekly review reminder body.
  ///
  /// In en, this message translates to:
  /// **'About 15 minutes to clear your head and plan the week.'**
  String get notifReviewBody;

  /// Export reminder title.
  ///
  /// In en, this message translates to:
  /// **'Time to back up'**
  String get notifBackupTitle;

  /// Export reminder body.
  ///
  /// In en, this message translates to:
  /// **'Export a copy, so a lost phone doesn’t mean lost plans.'**
  String get notifBackupBody;

  /// Morning summary title.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifDigestTitle;

  /// Reminder body showing the item's definition of done.
  ///
  /// In en, this message translates to:
  /// **'Done means: {text}'**
  String notifDoneMeans(String text);

  /// Batch block notification title, e.g. 'Errands time'.
  ///
  /// In en, this message translates to:
  /// **'{list} time'**
  String notifBlockTitle(String list);

  /// Batch block notification body.
  ///
  /// In en, this message translates to:
  /// **'Work through {list} in one go.'**
  String notifBlockBody(String list);

  /// Morning summary: today's must-dos by name.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 must-do: {titles}} other{{count} must-dos: {titles}}}'**
  String notifDigestMustDos(int count, String titles);

  /// Morning summary: other items today.
  ///
  /// In en, this message translates to:
  /// **'{count} more today'**
  String notifDigestMoreToday(int count);

  /// Morning summary when there are no must-dos.
  ///
  /// In en, this message translates to:
  /// **'{count} on Today'**
  String notifDigestOnToday(int count);

  /// Notification button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notifActionDone;

  /// Notification button.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 h'**
  String get notifActionSnoozeHour;

  /// Notification button: remind again tomorrow morning.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get notifActionTomorrow;

  /// PDF document title.
  ///
  /// In en, this message translates to:
  /// **'Clearing: today'**
  String get worksheetDocToday;

  /// PDF document title.
  ///
  /// In en, this message translates to:
  /// **'Clearing: week'**
  String get worksheetDocWeek;

  /// Worksheet: items that didn't fit.
  ///
  /// In en, this message translates to:
  /// **'+{count} more in the app'**
  String worksheetMoreInApp(int count);

  /// Worksheet: items that didn't fit in a day box.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String worksheetMore(int count);

  /// Worksheet section: batch blocks.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get worksheetBlocks;

  /// Worksheet section.
  ///
  /// In en, this message translates to:
  /// **'Also today'**
  String get worksheetAlsoToday;

  /// Worksheet: blank lines to write on.
  ///
  /// In en, this message translates to:
  /// **'On your mind'**
  String get worksheetOnYourMind;

  /// Worksheet: the box for this week's undated items and notes.
  ///
  /// In en, this message translates to:
  /// **'Any day · on your mind'**
  String get worksheetAnyDay;

  /// Worksheet subtitle.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String worksheetWeekOf(String date);

  /// Fallback name for a list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get worksheetList;

  /// Worksheet: an item carried over from an earlier day.
  ///
  /// In en, this message translates to:
  /// **'{item} (carried over)'**
  String worksheetCarriedOver(String item);

  /// Hint in the quick-capture field inside the weekly review and reset.
  ///
  /// In en, this message translates to:
  /// **'What’s on your mind?'**
  String get flowCaptureHint;

  /// Shown under the capture field after saving; count saved so far and the latest title.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} to Inbox · latest: {title}'**
  String flowSavedToInbox(int count, String title);

  /// Shown when Focus or Clarify opens an item that was deleted.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get flowItemGone;

  /// Focus screen title.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTitle;

  /// Under the item title in Focus; the user’s own definition of done.
  ///
  /// In en, this message translates to:
  /// **'Done means: {doneMeans}'**
  String focusDoneMeans(String doneMeans);

  /// Button leaving Focus without finishing the item.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get focusNotNow;

  /// Large heading shown after finishing the item in Focus.
  ///
  /// In en, this message translates to:
  /// **'One less thing'**
  String get focusFinishedTitle;

  /// Weekly review screen title.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get reviewTitle;

  /// Banner when a half-finished weekly review resumes.
  ///
  /// In en, this message translates to:
  /// **'Picking up where you left off.'**
  String get reviewResumed;

  /// Banner button restarting the weekly review from step one.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get reviewStartOver;

  /// Weekly review step 1 question.
  ///
  /// In en, this message translates to:
  /// **'Empty your head'**
  String get reviewEmptyHeadTitle;

  /// Weekly review step 1 hint.
  ///
  /// In en, this message translates to:
  /// **'Anything not written down yet: errands, worries, replies you owe. One thought at a time.'**
  String get reviewEmptyHeadHint;

  /// Weekly review inbox step when every item has been decided.
  ///
  /// In en, this message translates to:
  /// **'Inbox clear'**
  String get reviewInboxClearTitle;

  /// Hint when the inbox is clear and nothing was skipped.
  ///
  /// In en, this message translates to:
  /// **'Every item has a place.'**
  String get reviewInboxClearHint;

  /// Hint when the inbox is clear but some items were skipped.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped for now. They’ll be here next time.'**
  String reviewInboxSkipped(int count);

  /// Hint under an inbox item during the weekly review.
  ///
  /// In en, this message translates to:
  /// **'{count} left in the inbox. Where does this one go?'**
  String reviewInboxLeft(int count);

  /// Button passing over an inbox item during the review.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get reviewSkipForNow;

  /// Chip marking an inbox item as waiting on someone; asks for a name next.
  ///
  /// In en, this message translates to:
  /// **'Waiting on…'**
  String get reviewWaitingOnChoice;

  /// Chip marking an inbox item as already done.
  ///
  /// In en, this message translates to:
  /// **'Already done'**
  String get reviewAlreadyDone;

  /// Dialog title asking for the person an item waits on.
  ///
  /// In en, this message translates to:
  /// **'Who are you waiting on?'**
  String get reviewWhoWaitingOn;

  /// Tooltip on the done circle beside an item in the review.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get reviewMarkDone;

  /// Tooltip on the button that picks a new day for an item.
  ///
  /// In en, this message translates to:
  /// **'Re-plan'**
  String get reviewReplan;

  /// Tooltip on the button moving an item to Someday.
  ///
  /// In en, this message translates to:
  /// **'Let go to Someday'**
  String get reviewLetGo;

  /// Weekly review step 3 question.
  ///
  /// In en, this message translates to:
  /// **'Last week’s open items'**
  String get reviewLastWeekTitle;

  /// Step 3 hint when nothing is left over.
  ///
  /// In en, this message translates to:
  /// **'Nothing left over from last week.'**
  String get reviewLastWeekEmpty;

  /// Step 3 hint when there are open items.
  ///
  /// In en, this message translates to:
  /// **'This week’s items and anything carried over. Re-plan them, or let them go.'**
  String get reviewLastWeekHint;

  /// Waiting-on step hint when nothing waits.
  ///
  /// In en, this message translates to:
  /// **'You’re not waiting on anyone.'**
  String get reviewWaitingEmpty;

  /// Waiting-on step hint when items wait on others.
  ///
  /// In en, this message translates to:
  /// **'Follow up, mark done, or take it back to do yourself.'**
  String get reviewWaitingHint;

  /// Stands in for the person when a waiting item has no name.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get reviewSomeone;

  /// Part of a waiting item’s subtitle; date is a formatted day such as “tomorrow” or “Fri 12 Jan”.
  ///
  /// In en, this message translates to:
  /// **'follow up {date}'**
  String reviewFollowUpOn(String date);

  /// Tooltip on the button picking a follow-up date.
  ///
  /// In en, this message translates to:
  /// **'Follow up on…'**
  String get reviewFollowUpTooltip;

  /// Tooltip: stop waiting and plan the item for today yourself.
  ///
  /// In en, this message translates to:
  /// **'Take it back'**
  String get reviewTakeBack;

  /// Weekly review step 5 question.
  ///
  /// In en, this message translates to:
  /// **'The next 7 days'**
  String get reviewNextWeekTitle;

  /// Step 5 hint when nothing is dated.
  ///
  /// In en, this message translates to:
  /// **'Nothing dated this coming week.'**
  String get reviewNextWeekEmpty;

  /// Step 5 hint when items are dated.
  ///
  /// In en, this message translates to:
  /// **'A glance at what’s coming. Tap one to adjust it.'**
  String get reviewNextWeekHint;

  /// Someday step hint when the list is empty.
  ///
  /// In en, this message translates to:
  /// **'No ideas parked.'**
  String get reviewSomedayEmpty;

  /// Someday step hint when there are ideas.
  ///
  /// In en, this message translates to:
  /// **'Optional. Anything here ready to become a plan?'**
  String get reviewSomedayHint;

  /// Tooltip turning a Someday idea into a planned item.
  ///
  /// In en, this message translates to:
  /// **'Make it a plan'**
  String get reviewMakePlan;

  /// Title of the when-sheet opened from a Someday idea.
  ///
  /// In en, this message translates to:
  /// **'When will you do it?'**
  String get reviewWhenWillYou;

  /// Final weekly review step heading.
  ///
  /// In en, this message translates to:
  /// **'That’s the week'**
  String get reviewCloseTitle;

  /// Final weekly review step hint.
  ///
  /// In en, this message translates to:
  /// **'Your head should feel a little lighter.'**
  String get reviewCloseHint;

  /// Summary at the end of the review; a tally, never a score.
  ///
  /// In en, this message translates to:
  /// **'{cleared} cleared · {planned} planned'**
  String reviewCloseSummary(int cleared, int planned);

  /// Shown under the summary when some inbox items were skipped.
  ///
  /// In en, this message translates to:
  /// **'{skipped} skipped for another time.'**
  String reviewCloseSkipped(int skipped);

  /// Overwhelm reset screen title.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetTitle;

  /// Reset step 1 question.
  ///
  /// In en, this message translates to:
  /// **'Everything on your mind'**
  String get resetMindTitle;

  /// Reset step 1 hint.
  ///
  /// In en, this message translates to:
  /// **'Get it all out, one thought at a time. Nothing needs deciding yet.'**
  String get resetMindHint;

  /// Heading over the list of open items in reset step 1.
  ///
  /// In en, this message translates to:
  /// **'Already on your plate'**
  String get resetOnYourPlate;

  /// Reset step 2 question.
  ///
  /// In en, this message translates to:
  /// **'What must happen today?'**
  String get resetTodayTitle;

  /// Reset step 2 hint; cap is the must-do limit.
  ///
  /// In en, this message translates to:
  /// **'Up to {cap}. Only what truly can’t wait.'**
  String resetTodayHint(int cap);

  /// Reset step 2 when there are no open items.
  ///
  /// In en, this message translates to:
  /// **'Nothing open right now.'**
  String get resetTodayEmpty;

  /// Reset step 3 question.
  ///
  /// In en, this message translates to:
  /// **'What belongs to this week?'**
  String get resetWeekTitle;

  /// Reset step 3 hint.
  ///
  /// In en, this message translates to:
  /// **'It stays visible as one quiet row on Today.'**
  String get resetWeekHint;

  /// Reset step 3 when nothing else is open.
  ///
  /// In en, this message translates to:
  /// **'Nothing else is open.'**
  String get resetWeekEmpty;

  /// Reset step 4 question.
  ///
  /// In en, this message translates to:
  /// **'Let go of the rest?'**
  String get resetLetGoTitle;

  /// Reset step 4 hint when nothing is left.
  ///
  /// In en, this message translates to:
  /// **'Nothing left over.'**
  String get resetLetGoEmpty;

  /// Reset step 4 hint.
  ///
  /// In en, this message translates to:
  /// **'Ticked items go to Someday, or to Trash for 30 days. Untick anything you want to keep as it is.'**
  String get resetLetGoHint;

  /// Reset step 4 button keeping every item.
  ///
  /// In en, this message translates to:
  /// **'Keep them all'**
  String get resetKeepAll;

  /// Reset step 4 button moving ticked items to Someday.
  ///
  /// In en, this message translates to:
  /// **'Move to Someday'**
  String get resetMoveToSomeday;

  /// Reset step 5 question.
  ///
  /// In en, this message translates to:
  /// **'Smallest next action'**
  String get resetSmallestTitle;

  /// Reset step 5 hint when nothing was chosen.
  ///
  /// In en, this message translates to:
  /// **'Nothing was picked, and that’s fine. You’ve cleared some space.'**
  String get resetSmallestEmpty;

  /// Reset step 5 hint.
  ///
  /// In en, this message translates to:
  /// **'Pick one. Optionally, name a first step so small it’s easy.'**
  String get resetSmallestHint;

  /// Reset final button opening Focus on the chosen item.
  ///
  /// In en, this message translates to:
  /// **'Focus on it'**
  String get resetFocusOnIt;

  /// Label of the first-step field.
  ///
  /// In en, this message translates to:
  /// **'Tiny first step (optional)'**
  String get resetFirstStepLabel;

  /// Example in the first-step field.
  ///
  /// In en, this message translates to:
  /// **'e.g. “open the letter”'**
  String get resetFirstStepHint;

  /// Clarify screen title.
  ///
  /// In en, this message translates to:
  /// **'Clarify'**
  String get clarifyTitle;

  /// Clarify step 1 question.
  ///
  /// In en, this message translates to:
  /// **'Is this actionable?'**
  String get clarifyActionableTitle;

  /// Clarify step 1 choice.
  ///
  /// In en, this message translates to:
  /// **'Yes, there’s something to do'**
  String get clarifyActionableYes;

  /// Clarify step 1 choice moving the item to Someday.
  ///
  /// In en, this message translates to:
  /// **'No, keep it as an idea'**
  String get clarifyKeepIdea;

  /// Subtitle of the keep-as-idea choice.
  ///
  /// In en, this message translates to:
  /// **'It waits in Someday, out of Today’s way'**
  String get clarifyKeepIdeaHint;

  /// Clarify step 1 choice moving the item to Trash.
  ///
  /// In en, this message translates to:
  /// **'No, let it go'**
  String get clarifyLetGo;

  /// Subtitle of the let-it-go choice.
  ///
  /// In en, this message translates to:
  /// **'Into Trash for 30 days'**
  String get clarifyLetGoHint;

  /// Clarify step 2 question.
  ///
  /// In en, this message translates to:
  /// **'What’s the next action?'**
  String get clarifyNextActionTitle;

  /// Clarify step 2 hint.
  ///
  /// In en, this message translates to:
  /// **'A concrete step, starting with a verb: call, buy, email, book…'**
  String get clarifyNextActionHint;

  /// Clarify step 3 question.
  ///
  /// In en, this message translates to:
  /// **'Is someone else doing it?'**
  String get clarifyDelegateTitle;

  /// Label of the person field when delegating.
  ///
  /// In en, this message translates to:
  /// **'Who?'**
  String get clarifyWho;

  /// Row for picking a follow-up date, none chosen yet.
  ///
  /// In en, this message translates to:
  /// **'Follow up on… (optional)'**
  String get clarifyFollowUpOptional;

  /// Row showing the chosen follow-up date; date is a formatted day such as “tomorrow”.
  ///
  /// In en, this message translates to:
  /// **'Follow up {date}'**
  String clarifyFollowUpOn(String date);

  /// Clarify step 3 choice.
  ///
  /// In en, this message translates to:
  /// **'No, I’ll do it'**
  String get clarifyDoItMyself;

  /// Clarify step 3 choice.
  ///
  /// In en, this message translates to:
  /// **'Yes, I’m waiting on someone'**
  String get clarifyWaitingYes;

  /// Subtitle of the waiting-on choice.
  ///
  /// In en, this message translates to:
  /// **'Track who, and when to follow up'**
  String get clarifyWaitingYesHint;

  /// Button saving the item as waiting on someone.
  ///
  /// In en, this message translates to:
  /// **'Save as Waiting'**
  String get clarifySaveWaiting;

  /// Subtitle of the This week choice.
  ///
  /// In en, this message translates to:
  /// **'One quiet row on Today until you pick a day'**
  String get clarifyThisWeekHint;

  /// Clarify last step question.
  ///
  /// In en, this message translates to:
  /// **'Anything else?'**
  String get clarifyDetailsTitle;

  /// Clarify last step hint.
  ///
  /// In en, this message translates to:
  /// **'All optional.'**
  String get clarifyDetailsHint;

  /// Switch marking the item as a must-do for today.
  ///
  /// In en, this message translates to:
  /// **'Must-do today'**
  String get clarifyMustDoToday;

  /// Row for adding reminders.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get clarifyRemindMe;

  /// Subtitle when no reminder is set.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get clarifyNoReminder;

  /// Tooltip clearing all chosen reminders.
  ///
  /// In en, this message translates to:
  /// **'Remove reminders'**
  String get clarifyRemoveReminders;

  /// Row for setting a repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get clarifyRepeat;

  /// Subtitle when no repeat is set.
  ///
  /// In en, this message translates to:
  /// **'Doesn’t repeat'**
  String get clarifyNoRepeat;

  /// Tooltip removing the repeat.
  ///
  /// In en, this message translates to:
  /// **'Don’t repeat'**
  String get clarifyDontRepeat;

  /// Label of the done-means field.
  ///
  /// In en, this message translates to:
  /// **'Done means…'**
  String get clarifyDoneMeans;

  /// Example in the done-means field.
  ///
  /// In en, this message translates to:
  /// **'e.g. “form posted”, not “sort out taxes”'**
  String get clarifyDoneMeansHint;

  /// FAQ screen title.
  ///
  /// In en, this message translates to:
  /// **'Questions and answers'**
  String get faqTitle;

  /// FAQ section header.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get faqSectionData;

  /// FAQ section header.
  ///
  /// In en, this message translates to:
  /// **'Using Clearing'**
  String get faqSectionUsing;

  /// FAQ section header.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get faqSectionReminders;

  /// FAQ row subtitle linking to the reminders help screen.
  ///
  /// In en, this message translates to:
  /// **'Battery settings to check on your phone'**
  String get faqRemindersHelpSubtitle;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'Where are my things kept?'**
  String get faqWhereKeptQ;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone. Clearing has no account, no server and no internet access, so nothing you write leaves the phone unless you export it.'**
  String get faqWhereKeptA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'How do I move to a new phone?'**
  String get faqNewPhoneQ;

  /// FAQ answer. Mentions in-app menu path Settings › Backup.
  ///
  /// In en, this message translates to:
  /// **'Use Settings › Backup › Share a backup, and send the file somewhere you can reach from the new phone (email it to yourself, or save it to Drive). On the new phone, install Clearing and choose Restore from a backup. Android’s phone-to-phone transfer also moves Clearing’s data when you set up a new phone.'**
  String get faqNewPhoneA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'What happens if I uninstall Clearing?'**
  String get faqUninstallQ;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Everything in it is deleted with the app. Export a backup first if you might want it back. Clearing reminds you to export once a month, and you can change how often in Backup.'**
  String get faqUninstallA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'Can I use Clearing on two devices?'**
  String get faqTwoDevicesQ;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Not in sync: each phone keeps its own copy. You can move things across with a backup: Restore › Merge adds what’s missing and keeps the newer copy of anything on both.'**
  String get faqTwoDevicesA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'I did something by mistake. Can I undo it?'**
  String get faqUndoQ;

  /// FAQ answer. 'Undo' refers to the snackbar button.
  ///
  /// In en, this message translates to:
  /// **'Right after completing, deleting or moving an item, tap Undo on the note at the bottom of the screen. Deleted items stay in Lists › Trash for 30 days. Done items are in Lists › Done; untick one to bring it back.'**
  String get faqUndoA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'What does “carried over” mean?'**
  String get faqCarriedOverQ;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Something planned for an earlier day that isn’t done yet. It stays on Today, quietly, until you do it or move it. Nothing turns red and nothing is counted against you.'**
  String get faqCarriedOverA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'What happens when I miss a repeating item?'**
  String get faqMissedRepeatQ;

  /// FAQ answer. Quoted option names refer to the repeat editor's missed-item choices.
  ///
  /// In en, this message translates to:
  /// **'You choose per item. “Carry it over” keeps the missed one on Today until done, and the next one waits. “Skip it quietly” lets it go and starts fresh. Either way, missed days never pile up.'**
  String get faqMissedRepeatA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'Why is Today limited to a few must-dos?'**
  String get faqMustDoLimitQ;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'A short list gets done; a long one turns into guilt. Everything else stays visible below. You can change the limit (1 to 5) in Settings.'**
  String get faqMustDoLimitA;

  /// FAQ question.
  ///
  /// In en, this message translates to:
  /// **'Why are there no streaks or scores?'**
  String get faqNoStreaksQ;

  /// FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'They make a missed day feel like failure. Clearing counts what you cleared and planned, and nothing else.'**
  String get faqNoStreaksA;

  /// Reminders help screen title; also the FAQ row linking to it.
  ///
  /// In en, this message translates to:
  /// **'Reminders not arriving?'**
  String get remindersHelpTitle;

  /// Reminders help intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'Clearing schedules every reminder on your phone; nothing goes through a server. Some phones stop apps in the background to save battery, which can delay or drop reminders.'**
  String get remindersHelpIntro;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'First, check'**
  String get remindersHelpFirstCheck;

  /// Checklist row title.
  ///
  /// In en, this message translates to:
  /// **'Notifications are allowed'**
  String get remindersHelpNotificationsTitle;

  /// Android system menu path. Use the names Android shows in this language, or keep English.
  ///
  /// In en, this message translates to:
  /// **'Settings › Apps › Clearing › Notifications'**
  String get remindersHelpNotificationsPath;

  /// Checklist row title.
  ///
  /// In en, this message translates to:
  /// **'Exact timing is on'**
  String get remindersHelpExactTitle;

  /// Checklist row subtitle. 'Exact timing' is a Clearing setting.
  ///
  /// In en, this message translates to:
  /// **'Without it, Android may deliver reminders a few minutes late. See Exact timing in Clearing’s settings.'**
  String get remindersHelpExactBody;

  /// Checklist row title. Do Not Disturb is the Android feature name.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb is off'**
  String get remindersHelpDndTitle;

  /// Checklist row subtitle.
  ///
  /// In en, this message translates to:
  /// **'It silences or hides reminders while it’s on.'**
  String get remindersHelpDndBody;

  /// Section header before per-brand steps.
  ///
  /// In en, this message translates to:
  /// **'Then, for your phone'**
  String get remindersHelpForYourPhone;

  /// Phone brand group heading. Keep brand names.
  ///
  /// In en, this message translates to:
  /// **'Xiaomi, Redmi and POCO'**
  String get remindersHelpBrandXiaomi;

  /// Phone brand group heading. Keep brand names.
  ///
  /// In en, this message translates to:
  /// **'OnePlus, OPPO and realme'**
  String get remindersHelpBrandOnePlus;

  /// Phone brand group heading. Keep brand names.
  ///
  /// In en, this message translates to:
  /// **'vivo and iQOO'**
  String get remindersHelpBrandVivo;

  /// Phone brand group heading. Keep brand names.
  ///
  /// In en, this message translates to:
  /// **'Huawei and Honor'**
  String get remindersHelpBrandHuawei;

  /// Phone brand group heading. Keep brand names.
  ///
  /// In en, this message translates to:
  /// **'Pixel and other phones'**
  String get remindersHelpBrandPixel;

  /// Samsung steps. Menu names are the phone's own; keep them as the phone shows them.
  ///
  /// In en, this message translates to:
  /// **'Settings › Apps › Clearing › Battery › Unrestricted. Also check Settings › Battery › Background usage limits and remove Clearing from “Sleeping apps”.'**
  String get remindersHelpSamsung;

  /// Xiaomi steps. Menu names are the phone's own.
  ///
  /// In en, this message translates to:
  /// **'Settings › Apps › Manage apps › Clearing: turn on Autostart, and set Battery saver to “No restrictions”.'**
  String get remindersHelpXiaomi;

  /// OnePlus/OPPO/realme steps. Menu names are the phone's own.
  ///
  /// In en, this message translates to:
  /// **'Settings › Apps › Clearing › Battery: allow background activity and turn off “Optimise battery use”. On some versions, also allow Auto launch.'**
  String get remindersHelpOnePlus;

  /// vivo/iQOO steps. Menu names are the phone's own.
  ///
  /// In en, this message translates to:
  /// **'Settings › Battery › Background power consumption management: allow Clearing. Also turn on Autostart for Clearing in i Manager.'**
  String get remindersHelpVivo;

  /// Huawei/Honor steps. Menu names are the phone's own.
  ///
  /// In en, this message translates to:
  /// **'Settings › Battery › App launch › Clearing: switch to “Manage manually” and allow Auto-launch, Secondary launch and Run in background.'**
  String get remindersHelpHuawei;

  /// Pixel/other phones steps. Menu names are the phone's own.
  ///
  /// In en, this message translates to:
  /// **'Settings › Apps › Clearing › App battery usage: Unrestricted.'**
  String get remindersHelpPixel;

  /// Footer note on the reminders help screen.
  ///
  /// In en, this message translates to:
  /// **'Menu names vary between versions. dontkillmyapp.com has up-to-date steps for many more phones.'**
  String get remindersHelpFooter;

  /// Shown when an opened template was deleted.
  ///
  /// In en, this message translates to:
  /// **'This template no longer exists.'**
  String get templateGone;

  /// When-sheet title after starting a template.
  ///
  /// In en, this message translates to:
  /// **'When will you do it?'**
  String get templateWhenStart;

  /// Snackbar after starting a template without choosing a day.
  ///
  /// In en, this message translates to:
  /// **'Added to the Inbox'**
  String get templateAddedToInbox;

  /// Snackbar after starting a template and planning it.
  ///
  /// In en, this message translates to:
  /// **'“{title}” added'**
  String templateAdded(String title);

  /// Template screen title for a routine; also the routine row title.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get templateRoutine;

  /// Template screen title.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get templateTemplate;

  /// Overflow menu item.
  ///
  /// In en, this message translates to:
  /// **'Stop the routine'**
  String get templateStopRoutine;

  /// Overflow menu item.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get templateDelete;

  /// Section header for a template's steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get templateSteps;

  /// Semantic label for a step's drag handle.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get templateDragToReorder;

  /// Tooltip on a step's remove button.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get templateRemoveStep;

  /// Hint in the new-step field.
  ///
  /// In en, this message translates to:
  /// **'Add a step'**
  String get templateAddStepHint;

  /// Tooltip on the add-step button.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get templateAddStep;

  /// Label of the done-means field.
  ///
  /// In en, this message translates to:
  /// **'Done means…'**
  String get templateDoneMeans;

  /// Row title and picker title for the template's list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get templateList;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Use it'**
  String get templateUseIt;

  /// Row title when the template isn't a routine yet.
  ///
  /// In en, this message translates to:
  /// **'Make it a routine'**
  String get templateMakeRoutine;

  /// Subtitle of the make-routine row.
  ///
  /// In en, this message translates to:
  /// **'Arrives as a fresh checklist on the days you choose'**
  String get templateMakeRoutineHint;

  /// Button that starts a template.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get templateStartNow;

  /// Note below the start button.
  ///
  /// In en, this message translates to:
  /// **'Starting makes a copy. Changing the template later won’t change items already made from it.'**
  String get templateStartNote;

  /// Templates screen title.
  ///
  /// In en, this message translates to:
  /// **'Routines & templates'**
  String get templatesTitle;

  /// Dialog title and FAB tooltip.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get templatesNew;

  /// Hint in the new-template name field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Packing list'**
  String get templatesNameHint;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get templatesEmptyTitle;

  /// Empty state message.
  ///
  /// In en, this message translates to:
  /// **'A template is a checklist you use again and again. Make it a routine and it arrives on its own schedule.'**
  String get templatesEmptyMessage;

  /// Empty state button.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get templatesStartFromScratch;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get templatesRoutines;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTemplates;

  /// Number of steps in a template.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String templatesStepCount(int count);

  /// Bottom sheet title.
  ///
  /// In en, this message translates to:
  /// **'Print a worksheet'**
  String get worksheetPrintTitle;

  /// Subtitle of the Today worksheet option.
  ///
  /// In en, this message translates to:
  /// **'Must-dos, today, this week, and room to jot things down'**
  String get worksheetDaySubtitle;

  /// Subtitle of the week worksheet option.
  ///
  /// In en, this message translates to:
  /// **'A box for each day'**
  String get worksheetWeekSubtitle;

  /// Print job / PDF name for the day worksheet.
  ///
  /// In en, this message translates to:
  /// **'Clearing – today'**
  String get worksheetJobNameDay;

  /// Print job / PDF name for the week worksheet.
  ///
  /// In en, this message translates to:
  /// **'Clearing – week'**
  String get worksheetJobNameWeek;

  /// Shown when an opened item has been deleted.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get itemNoLongerExists;

  /// Item 'When' subtitle for an inbox item.
  ///
  /// In en, this message translates to:
  /// **'Not decided yet'**
  String get itemWhenNotDecided;

  /// Item 'When' subtitle for a waiting item.
  ///
  /// In en, this message translates to:
  /// **'Waiting on {name}'**
  String itemWhenWaitingOn(String name);

  /// Item 'When' subtitle for a waiting item with no name.
  ///
  /// In en, this message translates to:
  /// **'Waiting on someone'**
  String get itemWhenWaitingOnSomeone;

  /// Item 'When' subtitle for a trashed item.
  ///
  /// In en, this message translates to:
  /// **'In Trash'**
  String get itemWhenInTrash;

  /// Item 'When' subtitle: a planned date and time.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String itemWhenDateAtTime(String date, String time);

  /// Dialog title when leaving an edited repeating item.
  ///
  /// In en, this message translates to:
  /// **'Change future repeats too?'**
  String get itemFutureRepeatsTitle;

  /// Dialog body when leaving an edited repeating item.
  ///
  /// In en, this message translates to:
  /// **'You edited this one. Future repeats can stay as they were, or start from this version.'**
  String get itemFutureRepeatsBody;

  /// Dialog button: apply the edit only to this occurrence.
  ///
  /// In en, this message translates to:
  /// **'Just this one'**
  String get itemJustThisOne;

  /// Dialog button: apply the edit to future occurrences too.
  ///
  /// In en, this message translates to:
  /// **'This and future'**
  String get itemThisAndFuture;

  /// Tooltip: open focus mode for the item.
  ///
  /// In en, this message translates to:
  /// **'Focus on this'**
  String get itemFocusOnThis;

  /// Tooltip: unmark the item as must-do.
  ///
  /// In en, this message translates to:
  /// **'Not a must-do'**
  String get itemNotMustDo;

  /// Tooltip: mark the item as must-do.
  ///
  /// In en, this message translates to:
  /// **'Make it a must-do'**
  String get itemMakeMustDo;

  /// Item menu entry.
  ///
  /// In en, this message translates to:
  /// **'Move to Someday'**
  String get itemMoveToSomeday;

  /// Item menu entry: mark as waiting on someone.
  ///
  /// In en, this message translates to:
  /// **'Someone else is doing it'**
  String get itemSomeoneElseDoingIt;

  /// Item menu entry for a repeating item.
  ///
  /// In en, this message translates to:
  /// **'Use for future repeats'**
  String get itemUseForFutureRepeats;

  /// Item menu entry for a paused repeating item.
  ///
  /// In en, this message translates to:
  /// **'Resume repeating'**
  String get itemResumeRepeating;

  /// Item menu entry for a repeating item.
  ///
  /// In en, this message translates to:
  /// **'Pause repeating'**
  String get itemPauseRepeating;

  /// Item menu entry for a repeating item.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating'**
  String get itemStopRepeating;

  /// Button to reopen a finished item.
  ///
  /// In en, this message translates to:
  /// **'Not done yet'**
  String get itemNotDoneYet;

  /// Hint in the item title field.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get itemTitleHint;

  /// Section header on the item screen.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get itemPlanSection;

  /// Item screen row title for the do-date.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get itemWhen;

  /// Waiting-on subtitle when no name was given.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get itemSomeone;

  /// Item screen row title for the follow-up date.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get itemFollowUp;

  /// Follow-up subtitle when no date is set.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get itemNoDate;

  /// Repeat row subtitle for a one-off item.
  ///
  /// In en, this message translates to:
  /// **'Doesn’t repeat'**
  String get itemDoesntRepeat;

  /// Repeat row subtitle for a paused series; rule is the repeat described in words.
  ///
  /// In en, this message translates to:
  /// **'{rule} · paused'**
  String itemRepeatPaused(String rule);

  /// Tooltip: open the repeat calendar.
  ///
  /// In en, this message translates to:
  /// **'See all dates'**
  String get itemSeeAllDates;

  /// Item screen row title.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get itemDeadline;

  /// Deadline subtitle when no deadline is set.
  ///
  /// In en, this message translates to:
  /// **'None — “do on” is when you plan to do it'**
  String get itemDeadlineNone;

  /// Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove deadline'**
  String get itemRemoveDeadline;

  /// Section header on the item screen.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get itemDetailsSection;

  /// Item screen row title and list picker title.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get itemList;

  /// Label of the 'done means' field.
  ///
  /// In en, this message translates to:
  /// **'Done means…'**
  String get itemDoneMeansLabel;

  /// Hint of the 'done means' field.
  ///
  /// In en, this message translates to:
  /// **'What does finished look like?'**
  String get itemDoneMeansHint;

  /// Label of the notes field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get itemNotes;

  /// Repeat editor title and item screen row title.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatTitle;

  /// Repeat frequency option.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// Repeat frequency option.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// Repeat frequency option.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// Repeat interval for a daily rule.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every 1 day} other{Every {count} days}}'**
  String repeatEveryDays(int count);

  /// Repeat interval for a weekly rule.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every 1 week} other{Every {count} weeks}}'**
  String repeatEveryWeeks(int count);

  /// Repeat interval for a monthly rule.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every 1 month} other{Every {count} months}}'**
  String repeatEveryMonths(int count);

  /// Tooltip: decrease the repeat interval.
  ///
  /// In en, this message translates to:
  /// **'Less often'**
  String get repeatLessOften;

  /// Tooltip: increase the repeat interval.
  ///
  /// In en, this message translates to:
  /// **'More spread out'**
  String get repeatMoreSpreadOut;

  /// Switch: repeat relative to completion.
  ///
  /// In en, this message translates to:
  /// **'Count from when it’s done'**
  String get repeatAfterCompletionTitle;

  /// Subtitle of the after-completion switch.
  ///
  /// In en, this message translates to:
  /// **'For things like haircuts: the next one is set when you finish this one'**
  String get repeatAfterCompletionSubtitle;

  /// Monthly repeat: day-of-month picker title.
  ///
  /// In en, this message translates to:
  /// **'On day'**
  String get repeatOnDay;

  /// Hint under the day-of-month picker.
  ///
  /// In en, this message translates to:
  /// **'short months use their last day'**
  String get repeatOnDayHint;

  /// Repeat start date row.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get repeatStarts;

  /// Section header: when the repeat ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get repeatEnds;

  /// Repeat end option.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeatEndsNever;

  /// Repeat end option.
  ///
  /// In en, this message translates to:
  /// **'On a date'**
  String get repeatEndsOnDate;

  /// Repeat end option: after a number of times.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get repeatEndsAfter;

  /// Repeat end date row.
  ///
  /// In en, this message translates to:
  /// **'Last time on {date}'**
  String repeatLastTimeOn(String date);

  /// Repeat end count row.
  ///
  /// In en, this message translates to:
  /// **'{count} times in all'**
  String repeatTimesInAll(int count);

  /// Tooltip: decrease the repeat count.
  ///
  /// In en, this message translates to:
  /// **'Fewer times'**
  String get repeatFewerTimes;

  /// Tooltip: increase the repeat count.
  ///
  /// In en, this message translates to:
  /// **'More times'**
  String get repeatMoreTimes;

  /// Section header in the repeat editor.
  ///
  /// In en, this message translates to:
  /// **'If one is missed'**
  String get repeatIfMissed;

  /// Missed-repeat option.
  ///
  /// In en, this message translates to:
  /// **'Carry it over'**
  String get repeatCarryOver;

  /// Subtitle of the carry-over option.
  ///
  /// In en, this message translates to:
  /// **'It stays on Today until done; the next one waits'**
  String get repeatCarryOverSubtitle;

  /// Missed-repeat option.
  ///
  /// In en, this message translates to:
  /// **'Skip it quietly'**
  String get repeatSkipQuietly;

  /// Subtitle of the skip option.
  ///
  /// In en, this message translates to:
  /// **'Good for routines: tomorrow is a fresh start'**
  String get repeatSkipQuietlySubtitle;

  /// Repeat calendar mark (lowercase legend and screen-reader label).
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get seriesCalendarDone;

  /// Repeat calendar mark.
  ///
  /// In en, this message translates to:
  /// **'skipped'**
  String get seriesCalendarSkipped;

  /// Repeat calendar mark.
  ///
  /// In en, this message translates to:
  /// **'open now'**
  String get seriesCalendarOpenNow;

  /// Repeat calendar mark.
  ///
  /// In en, this message translates to:
  /// **'coming up'**
  String get seriesCalendarComingUp;

  /// Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get seriesCalendarPreviousMonth;

  /// Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get seriesCalendarNextMonth;

  /// Screen-reader label part for today's cell (lowercase).
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get seriesCalendarToday;

  /// Subtitle of a relative reminder on an item with no date.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a date'**
  String get reminderWaitingForDate;

  /// Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get reminderRemove;

  /// Reminder row title and reminder sheet title.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get reminderRemindMe;

  /// Reminder row title when one already exists.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder'**
  String get reminderAdd;

  /// Subtitle of the first 'Remind me' row.
  ///
  /// In en, this message translates to:
  /// **'Separate from when you plan to do it'**
  String get reminderSeparateHint;

  /// Reminder preset when the item has a date but no time; offset is e.g. '1 hour before'.
  ///
  /// In en, this message translates to:
  /// **'{offset} (counted from 9:00)'**
  String reminderCountedFromNine(String offset);

  /// Reminder sheet option.
  ///
  /// In en, this message translates to:
  /// **'At a time I choose'**
  String get reminderAtTimeIChoose;

  /// Date picker heading for a custom reminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me on'**
  String get reminderRemindMeOn;

  /// Time picker heading for a custom reminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get reminderRemindMeAt;

  /// Snackbar after adding a reminder while reminders are off.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off in Settings'**
  String get reminderOffInSettings;

  /// Snackbar when notification permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Clearing, so this reminder can’t appear. You can allow them in system settings.'**
  String get reminderNotificationsOff;

  /// Snackbar when exact alarms are not allowed.
  ///
  /// In en, this message translates to:
  /// **'Reminders may arrive a few minutes late'**
  String get reminderMayBeLate;

  /// Snackbar action: ask for exact alarms.
  ///
  /// In en, this message translates to:
  /// **'Make exact'**
  String get reminderMakeExact;

  /// Snackbar when the last step is checked.
  ///
  /// In en, this message translates to:
  /// **'All steps done'**
  String get subtaskAllDone;

  /// Snackbar action: complete the item.
  ///
  /// In en, this message translates to:
  /// **'Complete item'**
  String get subtaskCompleteItem;

  /// Steps section title.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get subtaskSteps;

  /// Steps progress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String subtaskProgress(int done, int total);

  /// Tooltip on a step's remove button.
  ///
  /// In en, this message translates to:
  /// **'Remove step {title}'**
  String subtaskRemoveStep(String title);

  /// Hint in the new-step field.
  ///
  /// In en, this message translates to:
  /// **'Add a step'**
  String get subtaskAddHint;

  /// Date picker heading when picking a do-date.
  ///
  /// In en, this message translates to:
  /// **'Do on'**
  String get whenSheetDoOn;

  /// Dialog after picking a date.
  ///
  /// In en, this message translates to:
  /// **'Add a time? Most things don’t need one.'**
  String get whenSheetAddTimeQuestion;

  /// Dialog button.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get whenSheetNoTime;

  /// Dialog button.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get whenSheetAddTime;

  /// Today menu: open the weekly review.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get todayMenuWeeklyReview;

  /// Today menu: open the overwhelm reset.
  ///
  /// In en, this message translates to:
  /// **'Overwhelm reset'**
  String get todayMenuOverwhelmReset;

  /// Today menu: print a paper worksheet.
  ///
  /// In en, this message translates to:
  /// **'Print a worksheet'**
  String get todayMenuPrintWorksheet;

  /// Today header subtitle: items still open today.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String todayLeft(int count);

  /// Today header subtitle when everything is done.
  ///
  /// In en, this message translates to:
  /// **'all clear'**
  String get todayAllClear;

  /// Today empty state title.
  ///
  /// In en, this message translates to:
  /// **'A clear day'**
  String get todayEmptyTitle;

  /// Today empty state message.
  ///
  /// In en, this message translates to:
  /// **'Capture anything on your mind. You can decide what it means later.'**
  String get todayEmptyMessage;

  /// Button on empty Today opening the intro.
  ///
  /// In en, this message translates to:
  /// **'How Clearing works'**
  String get todayHowClearingWorks;

  /// Offer of the overwhelm reset when Today is full.
  ///
  /// In en, this message translates to:
  /// **'Feeling like a lot?'**
  String get todayResetOfferTitle;

  /// Subtitle of the overwhelm reset offer.
  ///
  /// In en, this message translates to:
  /// **'A five-minute reset narrows it to one thing'**
  String get todayResetOfferSubtitle;

  /// Must-do section counter, e.g. 2 of 3.
  ///
  /// In en, this message translates to:
  /// **'{count} of {cap}'**
  String todayMustDoCount(int count, int cap);

  /// Today section header for batch blocks.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get todayBlocks;

  /// Today section header for non-must-do items.
  ///
  /// In en, this message translates to:
  /// **'Also today'**
  String get todayAlsoToday;

  /// Button expanding the collapsed Also today list.
  ///
  /// In en, this message translates to:
  /// **'Show {count} more'**
  String todayShowMore(int count);

  /// Row title for items carried over from earlier days.
  ///
  /// In en, this message translates to:
  /// **'Carried over ({count})'**
  String todayCarriedOver(int count);

  /// Subtitle of the carried-over row.
  ///
  /// In en, this message translates to:
  /// **'Picking up where you left off'**
  String get todayCarriedOverSubtitle;

  /// Screen-reader label: collapse the carried-over items.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get todayHide;

  /// Screen-reader label: expand the carried-over items.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get todayShow;

  /// Row on Today linking to This week items.
  ///
  /// In en, this message translates to:
  /// **'This week ({count})'**
  String todayThisWeekCount(int count);

  /// This week empty state title.
  ///
  /// In en, this message translates to:
  /// **'Nothing set for this week'**
  String get thisWeekEmptyTitle;

  /// This week empty state message.
  ///
  /// In en, this message translates to:
  /// **'Things you mean to do this week, without picking a day, gather here and show as one quiet row on Today.'**
  String get thisWeekEmptyMessage;

  /// Tooltip: move this item to Today.
  ///
  /// In en, this message translates to:
  /// **'Do today'**
  String get thisWeekDoToday;

  /// Inbox header subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} to decide · tap one, or swipe for shortcuts'**
  String inboxToDecide(int count);

  /// Nudge shown when the inbox is long.
  ///
  /// In en, this message translates to:
  /// **'Inbox: {count} — a review takes about 15 minutes'**
  String inboxReviewEstimate(int count);

  /// Subtitle of the inbox review nudge.
  ///
  /// In en, this message translates to:
  /// **'Every item gets a place'**
  String get inboxReviewSubtitle;

  /// Button starting the weekly review from the inbox.
  ///
  /// In en, this message translates to:
  /// **'Start review'**
  String get inboxStartReview;

  /// Inbox swipe action: choose a date.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get inboxSwipePickDate;

  /// Inbox empty state title.
  ///
  /// In en, this message translates to:
  /// **'Inbox is empty'**
  String get inboxEmptyTitle;

  /// Inbox empty state message.
  ///
  /// In en, this message translates to:
  /// **'Thoughts you capture land here until you decide what they mean.'**
  String get inboxEmptyMessage;

  /// Item detail: the item is part of a repeating series.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get itemTileRepeats;

  /// Item detail: who or what the item waits on.
  ///
  /// In en, this message translates to:
  /// **'Waiting on {name}'**
  String itemTileWaitingOn(String name);

  /// Item detail: follow-up date; date is already formatted (e.g. Tomorrow, Mon 3 Jun).
  ///
  /// In en, this message translates to:
  /// **'Follow up {date}'**
  String itemTileFollowUp(String date);

  /// Item detail: deadline; date is already formatted.
  ///
  /// In en, this message translates to:
  /// **'Deadline {date}'**
  String itemTileDeadline(String date);

  /// Item detail: steps done out of total steps.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String itemTileProgress(int done, int total);

  /// Screen-reader label of the item checkbox.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get itemTileMarkDone;

  /// Screen-reader label of a ticked item checkbox.
  ///
  /// In en, this message translates to:
  /// **'Mark not done'**
  String get itemTileMarkNotDone;

  /// Item detail: a This week item carried over from last week.
  ///
  /// In en, this message translates to:
  /// **'From last week'**
  String get itemTileFromLastWeek;

  /// Item detail: carried over from this day; day is already formatted.
  ///
  /// In en, this message translates to:
  /// **'From {day}'**
  String itemTileFromDay(String day);

  /// Item detail: a date with a time; both already formatted.
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String itemTileDayTime(String day, String time);

  /// Item menu: remove the must-do mark.
  ///
  /// In en, this message translates to:
  /// **'Not a must-do'**
  String get itemTileNotMustDo;

  /// Item menu: mark the item as a must-do.
  ///
  /// In en, this message translates to:
  /// **'Make it a must-do'**
  String get itemTileMakeMustDo;

  /// Item menu: snooze the item to tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get itemTileTomorrow;

  /// Item menu: open focus mode for this item.
  ///
  /// In en, this message translates to:
  /// **'Focus on this'**
  String get itemTileFocusOnThis;

  /// Item menu: pick a new date.
  ///
  /// In en, this message translates to:
  /// **'Reschedule…'**
  String get itemTileReschedule;

  /// Item menu: open the item to add steps.
  ///
  /// In en, this message translates to:
  /// **'Break into steps'**
  String get itemTileBreakIntoSteps;

  /// Item menu: move the item to Someday.
  ///
  /// In en, this message translates to:
  /// **'Move to Someday'**
  String get itemTileMoveToSomeday;

  /// Lists screen header subtitle.
  ///
  /// In en, this message translates to:
  /// **'Contexts, ideas, and what’s done'**
  String get listsSubtitle;

  /// Create a new list (row and dialog title).
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get listsNewList;

  /// Row opening routines and templates.
  ///
  /// In en, this message translates to:
  /// **'Routines & templates'**
  String get listsRoutinesTitle;

  /// Subtitle of the routines row.
  ///
  /// In en, this message translates to:
  /// **'Checklists you use again and again'**
  String get listsRoutinesSubtitle;

  /// Section header for Someday, Done and Trash.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get listsNotNow;

  /// Subtitle of the Someday row.
  ///
  /// In en, this message translates to:
  /// **'Ideas, not commitments'**
  String get listsSomedaySubtitle;

  /// Row opening the list of finished items.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get listsDoneTitle;

  /// Subtitle of the Done row.
  ///
  /// In en, this message translates to:
  /// **'Recently done and the archive'**
  String get listsDoneSubtitle;

  /// Row opening the trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get listsTrashTitle;

  /// Subtitle of the Trash row.
  ///
  /// In en, this message translates to:
  /// **'Kept for 30 days'**
  String get listsTrashSubtitle;

  /// Expandable row of hidden lists.
  ///
  /// In en, this message translates to:
  /// **'Hidden lists ({count})'**
  String listsHiddenLists(int count);

  /// List menu: rename the list.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get listsRename;

  /// Dialog title for renaming a list.
  ///
  /// In en, this message translates to:
  /// **'Rename list'**
  String get listsRenameList;

  /// List menu: show a hidden list again.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get listsShow;

  /// List menu: hide the list.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get listsHide;

  /// List menu: delete the list.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get listsDeleteList;

  /// Subtitle explaining deleting a list keeps its items.
  ///
  /// In en, this message translates to:
  /// **'Its items are kept, just unfiled'**
  String get listsDeleteListSubtitle;

  /// List section: active items.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get listSectionToDo;

  /// List section: items still in the inbox.
  ///
  /// In en, this message translates to:
  /// **'Not decided yet'**
  String get listSectionNotDecided;

  /// Repeating time block; weekday and time already formatted.
  ///
  /// In en, this message translates to:
  /// **'Every {weekday} at {time}'**
  String listBlockEvery(String weekday, String time);

  /// One-off time block; date and time already formatted.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String listBlockOn(String date, String time);

  /// Subtitle of a time block row.
  ///
  /// In en, this message translates to:
  /// **'Shows as one entry on Today'**
  String get listBlockSubtitle;

  /// Tooltip: delete a time block.
  ///
  /// In en, this message translates to:
  /// **'Remove time block'**
  String get listRemoveBlock;

  /// Tooltip: schedule a time block for this list.
  ///
  /// In en, this message translates to:
  /// **'Block out time'**
  String get listBlockOutTime;

  /// Tooltip: add an item to the named list.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String listAddTo(String name);

  /// Tooltip: add an item to this list (name unknown).
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get listAddToList;

  /// Empty list title with the list's name.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {name}'**
  String listEmptyTitle(String name);

  /// Empty list title when the name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this list'**
  String get listEmptyTitleThisList;

  /// Empty list message.
  ///
  /// In en, this message translates to:
  /// **'Add things that belong together, like errands to run in one trip.'**
  String get listEmptyMessage;

  /// Trash screen title.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// Button/tooltip: permanently delete.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get trashDeleteForever;

  /// Confirm dialog title for emptying the trash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash?'**
  String get trashEmptyConfirmTitle;

  /// Confirm dialog body for emptying the trash.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item will be deleted for good. This can’t be undone.} other{{count} items will be deleted for good. This can’t be undone.}}'**
  String trashEmptyConfirmBody(int count);

  /// App bar button: empty the trash.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get trashEmpty;

  /// Trash empty state title.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmptyTitle;

  /// Trash empty state message.
  ///
  /// In en, this message translates to:
  /// **'Deleted items stay here for 30 days, in case you want them back.'**
  String get trashEmptyMessage;

  /// Trash item subtitle: purged tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Deleted for good tomorrow'**
  String get trashPurgeTomorrow;

  /// Trash item subtitle: days until purge.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Deleted for good in 1 day} other{Deleted for good in {days} days}}'**
  String trashPurgeInDays(int days);

  /// Tooltip: restore an item from the trash.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get trashRestore;

  /// Confirm dialog title for deleting one item permanently.
  ///
  /// In en, this message translates to:
  /// **'Delete forever?'**
  String get trashDeleteForeverConfirmTitle;

  /// Confirm dialog body; title is the item's title.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be gone for good.'**
  String trashDeleteForeverConfirmBody(String title);

  /// Title of the screen of finished items.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get archiveTitle;

  /// Done screen empty state title.
  ///
  /// In en, this message translates to:
  /// **'Nothing done yet'**
  String get archiveEmptyTitle;

  /// Done screen empty state message.
  ///
  /// In en, this message translates to:
  /// **'Finished items rest here, and search still finds them.'**
  String get archiveEmptyMessage;

  /// Section header for recently finished items.
  ///
  /// In en, this message translates to:
  /// **'Recently done'**
  String get archiveRecentlyDone;

  /// Section trailing note: when items move to the archive.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{archived after 1 day} other{archived after {days} days}}'**
  String archiveArchivedAfter(int days);

  /// Section header for archived items.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveSection;

  /// Someday empty state title.
  ///
  /// In en, this message translates to:
  /// **'No ideas parked here'**
  String get somedayEmptyTitle;

  /// Someday empty state message.
  ///
  /// In en, this message translates to:
  /// **'Things you might do one day, without the pressure.'**
  String get somedayEmptyMessage;

  /// Tooltip: schedule a Someday item.
  ///
  /// In en, this message translates to:
  /// **'Make it a plan'**
  String get somedayMakePlan;

  /// When sheet title for planning a Someday item.
  ///
  /// In en, this message translates to:
  /// **'When will you do it?'**
  String get somedayWhenTitle;

  /// Settings: title of the daily must-do limit.
  ///
  /// In en, this message translates to:
  /// **'Must-do items per day'**
  String get settingsMustDoPerDay;

  /// Settings: subtitle under the must-do limit.
  ///
  /// In en, this message translates to:
  /// **'Keeping this small keeps Today doable'**
  String get settingsMustDoPerDayHint;

  /// Settings: choice of first weekday.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get settingsWeekStartsOn;

  /// Settings: hint under the week start choice.
  ///
  /// In en, this message translates to:
  /// **'for “This week” and weekday choices'**
  String get settingsWeekStartsOnHint;

  /// Settings: switch for the Inbox tab badge.
  ///
  /// In en, this message translates to:
  /// **'Show count on the Inbox tab'**
  String get settingsInboxBadge;

  /// Settings: subtitle of the starter suggestions switch.
  ///
  /// In en, this message translates to:
  /// **'Quick-add ideas in capture and an empty inbox'**
  String get settingsStarterSuggestionsHint;

  /// Settings: opens the starter suggestions editor.
  ///
  /// In en, this message translates to:
  /// **'Edit suggestions'**
  String get settingsEditSuggestions;

  /// Settings: section header for reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsRemindersSection;

  /// Settings: notification intensity segment, no notifications.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsIntensityOff;

  /// Settings: notification intensity segment, silent.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get settingsIntensityGentle;

  /// Settings: notification intensity segment, with sound.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settingsIntensityStandard;

  /// Settings: explains the Off intensity.
  ///
  /// In en, this message translates to:
  /// **'No notifications at all.'**
  String get settingsIntensityOffHint;

  /// Settings: explains the Gentle intensity.
  ///
  /// In en, this message translates to:
  /// **'Only reminders you set, without sound or vibration.'**
  String get settingsIntensityGentleHint;

  /// Settings: explains the Standard intensity.
  ///
  /// In en, this message translates to:
  /// **'Only reminders you set, with sound.'**
  String get settingsIntensityStandardHint;

  /// Settings: quiet hours tile title.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get settingsQuietHours;

  /// Settings: quiet hours subtitle with the start and end times.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}. Early reminders wait until morning; ones you timed exactly still arrive.'**
  String settingsQuietHoursRange(String start, String end);

  /// Settings: time picker title for quiet hours start.
  ///
  /// In en, this message translates to:
  /// **'Quiet from'**
  String get settingsQuietFrom;

  /// Settings: time picker title for quiet hours end.
  ///
  /// In en, this message translates to:
  /// **'Quiet until'**
  String get settingsQuietUntil;

  /// Settings: morning digest switch title.
  ///
  /// In en, this message translates to:
  /// **'Morning summary'**
  String get settingsMorningSummary;

  /// Settings: morning digest subtitle when on, with its time.
  ///
  /// In en, this message translates to:
  /// **'Today’s must-dos at {time}. Nothing on a clear day.'**
  String settingsMorningSummaryOn(String time);

  /// Settings: morning digest subtitle when off.
  ///
  /// In en, this message translates to:
  /// **'One note each morning with today’s must-dos'**
  String get settingsMorningSummaryOff;

  /// Settings: morning digest time tile.
  ///
  /// In en, this message translates to:
  /// **'Summary time'**
  String get settingsSummaryTime;

  /// Settings: opens help for missing reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders not arriving?'**
  String get settingsRemindersNotArriving;

  /// Settings: section header for the weekly review.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get settingsWeeklyReviewSection;

  /// Settings: weekly review reminder switch.
  ///
  /// In en, this message translates to:
  /// **'Remind me to review'**
  String get settingsRemindReview;

  /// Settings: subtitle of the review reminder switch.
  ///
  /// In en, this message translates to:
  /// **'About 15 minutes, once a week'**
  String get settingsRemindReviewHint;

  /// Settings: weekly review weekday choice.
  ///
  /// In en, this message translates to:
  /// **'Review day'**
  String get settingsReviewDay;

  /// Settings: weekly review time tile.
  ///
  /// In en, this message translates to:
  /// **'Review time'**
  String get settingsReviewTime;

  /// Settings: section header for finished items.
  ///
  /// In en, this message translates to:
  /// **'Done items'**
  String get settingsDoneSection;

  /// Settings: auto-archive choice title.
  ///
  /// In en, this message translates to:
  /// **'Move done items to the archive'**
  String get settingsAutoArchive;

  /// Settings: hint under the auto-archive choice.
  ///
  /// In en, this message translates to:
  /// **'still searchable there'**
  String get settingsAutoArchiveHint;

  /// Settings: auto-archive option, 1 day.
  ///
  /// In en, this message translates to:
  /// **'After a day'**
  String get settingsArchiveAfterDay;

  /// Settings: auto-archive option, 7 days.
  ///
  /// In en, this message translates to:
  /// **'After a week'**
  String get settingsArchiveAfterWeek;

  /// Settings: auto-archive option, 30 days.
  ///
  /// In en, this message translates to:
  /// **'After a month'**
  String get settingsArchiveAfterMonth;

  /// Settings: auto-archive option, never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settingsArchiveNever;

  /// Settings: auto-archive option for a custom number of days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{After 1 day} other{After {count} days}}'**
  String settingsArchiveAfterDays(int count);

  /// Settings: section header for backup.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsDataSection;

  /// Settings: subtitle of the Backup tile.
  ///
  /// In en, this message translates to:
  /// **'Export a copy, or restore one'**
  String get settingsBackupHint;

  /// Settings: section header for theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// Settings: theme segment following the phone.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Settings: light theme segment.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Settings: dark theme segment.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Settings: section header for help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelpSection;

  /// Settings: opens the FAQ.
  ///
  /// In en, this message translates to:
  /// **'Questions and answers'**
  String get settingsFaq;

  /// Settings: subtitle of the FAQ tile.
  ///
  /// In en, this message translates to:
  /// **'Backups, new phones, undo and more'**
  String get settingsFaqHint;

  /// Settings: opens the About screen.
  ///
  /// In en, this message translates to:
  /// **'About and feedback'**
  String get settingsAbout;

  /// Settings: shown when the system blocks notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked'**
  String get settingsNotificationsBlocked;

  /// Settings: subtitle of the blocked notifications tile.
  ///
  /// In en, this message translates to:
  /// **'Tap to allow them for Clearing'**
  String get settingsNotificationsBlockedHint;

  /// Settings: exact alarm permission tile.
  ///
  /// In en, this message translates to:
  /// **'Exact timing'**
  String get settingsExactTiming;

  /// Settings: exact timing subtitle when allowed.
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive on the minute'**
  String get settingsExactTimingOn;

  /// Settings: exact timing subtitle when not allowed.
  ///
  /// In en, this message translates to:
  /// **'Off: reminders may arrive a few minutes late. Tap to allow exact timing.'**
  String get settingsExactTimingOff;

  /// Backup screen title and its Settings tile.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// Backup: snackbar after exporting.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// Backup: snackbar when export fails, with the error.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t export: {error}'**
  String backupExportFailed(String error);

  /// Backup: explanation at the top of the screen.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone, with no account and no cloud. Uninstalling Clearing or losing the phone deletes your data unless you’ve exported a copy.'**
  String get backupIntro;

  /// Backup: tile showing when the last export was.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get backupLast;

  /// Backup: no backup yet, or never remind to export.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get backupNever;

  /// Backup: section header for exporting.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get backupExportSection;

  /// Backup: share the backup file.
  ///
  /// In en, this message translates to:
  /// **'Share a backup'**
  String get backupShare;

  /// Backup: subtitle of the share tile.
  ///
  /// In en, this message translates to:
  /// **'Send it to email, Drive, or another app'**
  String get backupShareHint;

  /// Backup: save the backup file to a folder.
  ///
  /// In en, this message translates to:
  /// **'Save to a folder'**
  String get backupSaveToFolder;

  /// Backup: export reminder choice title.
  ///
  /// In en, this message translates to:
  /// **'Remind me to export'**
  String get backupRemindExport;

  /// Backup: export reminder option.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get backupEveryTwoWeeks;

  /// Backup: export reminder option.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get backupMonthly;

  /// Backup: export reminder option for a custom number of days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String backupEveryDays(int count);

  /// Backup: section header for restoring.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestoreSection;

  /// Backup: pick a file to restore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get backupRestoreFrom;

  /// Backup: subtitle of the restore tile.
  ///
  /// In en, this message translates to:
  /// **'You’ll see what’s in it before anything changes'**
  String get backupRestoreFromHint;

  /// Backup: dialog title when the file is not a valid backup.
  ///
  /// In en, this message translates to:
  /// **'Can’t restore this file'**
  String get backupCantRestore;

  /// Backup: confirm dialog title before replacing.
  ///
  /// In en, this message translates to:
  /// **'Replace everything?'**
  String get backupReplaceAllTitle;

  /// Backup: confirm dialog body before replacing.
  ///
  /// In en, this message translates to:
  /// **'Everything now in Clearing on this phone will be replaced by the backup. This can’t be undone.'**
  String get backupReplaceAllBody;

  /// Backup: button to replace everything with the backup.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupReplace;

  /// Backup: snackbar after restoring.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// Backup: preview dialog title when the export date is unknown.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get backupRestoreThis;

  /// Backup: preview dialog title with the export date.
  ///
  /// In en, this message translates to:
  /// **'Backup from {date}'**
  String backupFromDate(String date);

  /// Backup: preview line with item counts by state.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}: {open} open, {someday} someday, {done} done'**
  String backupPreviewItems(int count, int open, int someday, int done);

  /// Backup: preview line with the number of lists.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 list} other{{count} lists}}'**
  String backupPreviewLists(int count);

  /// Backup: preview line with the number of repeating items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 repeating item} other{{count} repeating items}}'**
  String backupPreviewRepeating(int count);

  /// Backup: explains Merge and Replace in the preview dialog.
  ///
  /// In en, this message translates to:
  /// **'Merge adds what’s missing and keeps the newer copy of anything on both. Replace makes this phone match the backup exactly.'**
  String get backupMergeExplain;

  /// Backup: button to merge the backup in.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get backupMerge;

  /// About screen title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// About: the app's tagline.
  ///
  /// In en, this message translates to:
  /// **'Close your mental tabs.'**
  String get aboutTagline;

  /// About: installed version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// About: section header for privacy.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get aboutPrivacySection;

  /// About: the privacy promise.
  ///
  /// In en, this message translates to:
  /// **'No account, no server, no analytics, no ads. Clearing can’t reach the internet at all: everything you write stays on this phone unless you export it yourself.'**
  String get aboutPrivacy;

  /// About: section header for beta feedback.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get aboutBetaSection;

  /// About: opens the share sheet with a feedback template.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get aboutSendFeedback;

  /// About: subtitle of the feedback tile.
  ///
  /// In en, this message translates to:
  /// **'Opens your email or messaging app with a short template'**
  String get aboutSendFeedbackHint;

  /// About: subject line of a feedback message.
  ///
  /// In en, this message translates to:
  /// **'Clearing feedback'**
  String get aboutFeedbackSubject;

  /// Feedback template: first prompt.
  ///
  /// In en, this message translates to:
  /// **'What happened:'**
  String get aboutFeedbackWhatHappened;

  /// Feedback template: second prompt.
  ///
  /// In en, this message translates to:
  /// **'What I expected:'**
  String get aboutFeedbackExpected;

  /// Feedback template: last prompt.
  ///
  /// In en, this message translates to:
  /// **'Anything else:'**
  String get aboutFeedbackElse;

  /// About: send feedback including the error log, with its entry count.
  ///
  /// In en, this message translates to:
  /// **'Send feedback with the error log ({count})'**
  String aboutSendWithErrorLog(int count);

  /// About: subtitle of the error log feedback tile.
  ///
  /// In en, this message translates to:
  /// **'Error types and where they happened; you see it all first'**
  String get aboutErrorLogHint;

  /// Feedback message: divider before the error log.
  ///
  /// In en, this message translates to:
  /// **'--- Error log ---'**
  String get aboutErrorLogHeader;

  /// About: deletes the on-phone error log.
  ///
  /// In en, this message translates to:
  /// **'Clear the error log'**
  String get aboutClearErrorLog;

  /// About: source code tile title.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCode;

  /// About: source code location and licence.
  ///
  /// In en, this message translates to:
  /// **'{url} · MIT licence'**
  String aboutSourceSubtitle(String url);

  /// About: opens the licence page.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get aboutLicences;

  /// Starter suggestions screen title and its Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Starter suggestions'**
  String get suggestionsTitle;

  /// Suggestions: button to add a suggestion.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get suggestionsAdd;

  /// Suggestions: marks a suggestion the user created.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get suggestionsYours;

  /// Suggestions: menu item to edit a suggestion.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get suggestionsEdit;

  /// Suggestions: dialog title when adding.
  ///
  /// In en, this message translates to:
  /// **'New suggestion'**
  String get suggestionsNew;

  /// Suggestions: dialog title when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit suggestion'**
  String get suggestionsEditTitle;

  /// Intro screen title and its Settings tile.
  ///
  /// In en, this message translates to:
  /// **'How Clearing works'**
  String get introTitle;

  /// Intro card 1 title.
  ///
  /// In en, this message translates to:
  /// **'Capture it'**
  String get introCaptureTitle;

  /// Intro card 1 body.
  ///
  /// In en, this message translates to:
  /// **'Get a thought out of your head the moment it appears. One line is enough: it waits in the Inbox until you have a minute.'**
  String get introCaptureBody;

  /// Intro card 2 title.
  ///
  /// In en, this message translates to:
  /// **'Decide what it means'**
  String get introDecideTitle;

  /// Intro card 2 body.
  ///
  /// In en, this message translates to:
  /// **'Later, give each one a place: today, this week, a date, someone else, or Someday if it’s just an idea.'**
  String get introDecideBody;

  /// Intro card 3 title.
  ///
  /// In en, this message translates to:
  /// **'Plan small, close often'**
  String get introPlanTitle;

  /// Intro card 3 body.
  ///
  /// In en, this message translates to:
  /// **'Keep Today to a few must-dos, and review once a week so nothing is forgotten. Missed things are carried over, never held against you.'**
  String get introPlanBody;

  /// Intro: screen reader label for a card's position.
  ///
  /// In en, this message translates to:
  /// **'Card {index} of {total}'**
  String introCardPosition(int index, int total);

  /// Intro: button on the last card.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get introGetStarted;

  /// Search filter chip: items not yet done (inbox, active, waiting).
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get searchStatusOpen;

  /// Search date-range picker heading.
  ///
  /// In en, this message translates to:
  /// **'Planned between'**
  String get searchPlannedBetween;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search titles, notes and steps'**
  String get searchHint;

  /// Tooltip: clears the search text.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClear;

  /// Search filter chip/menu item: no list filter.
  ///
  /// In en, this message translates to:
  /// **'Any list'**
  String get searchAnyList;

  /// Search filter chip showing the chosen date range.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String searchDateRange(String from, String to);

  /// Search filter chip: no date filter; also the tooltip to remove the date filter.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get searchAnyDate;

  /// Search filter chip: only repeating items.
  ///
  /// In en, this message translates to:
  /// **'Repeating'**
  String get searchRepeating;

  /// Search empty state title.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get searchNoMatchesTitle;

  /// Search empty state message.
  ///
  /// In en, this message translates to:
  /// **'Try fewer words, or loosen the filters.'**
  String get searchNoMatchesMessage;

  /// Upcoming header subtitle in week view.
  ///
  /// In en, this message translates to:
  /// **'A week at a time'**
  String get upcomingSubtitleWeek;

  /// Upcoming header subtitle in agenda view.
  ///
  /// In en, this message translates to:
  /// **'The next 30 days'**
  String get upcomingSubtitleAgenda;

  /// Tooltip: switch Upcoming to the agenda view.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get upcomingAgenda;

  /// Tooltip: switch Upcoming to the week view.
  ///
  /// In en, this message translates to:
  /// **'Week view'**
  String get upcomingWeekView;

  /// Upcoming empty state title.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get upcomingEmptyTitle;

  /// Upcoming empty state message.
  ///
  /// In en, this message translates to:
  /// **'Items with a date in the next 30 days show up here.'**
  String get upcomingEmptyMessage;

  /// Tooltip: go to the previous week.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get weekPrevious;

  /// Week view heading for next week; also the tooltip to go forward a week.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get weekNext;

  /// Week view heading for a later week: its first and last dates.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String weekRange(String start, String end);

  /// Week view section: items planned for this week with no set day.
  ///
  /// In en, this message translates to:
  /// **'Any day this week'**
  String get weekAnyDay;

  /// Week view: a past day with nothing open.
  ///
  /// In en, this message translates to:
  /// **'Nothing left'**
  String get weekNothingLeft;

  /// Week view: a coming day with nothing planned.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get weekFree;

  /// Batch block row title: list name and start time.
  ///
  /// In en, this message translates to:
  /// **'{list} · {time}'**
  String blockTileTitle(String list, String time);

  /// Batch block row subtitle when the list has nothing left.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get blockAllDone;

  /// Batch block row subtitle: open items in the list.
  ///
  /// In en, this message translates to:
  /// **'{count} to do, in one go'**
  String blockToDo(int count);

  /// Dialog title: schedule a batch block for a list.
  ///
  /// In en, this message translates to:
  /// **'Block out time'**
  String get blockDialogTitle;

  /// Batch block dialog explanation.
  ///
  /// In en, this message translates to:
  /// **'Work through the whole list in one go.'**
  String get blockDialogMessage;

  /// Batch block dialog option: repeats weekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get blockEveryWeek;

  /// Batch block dialog option: one date only.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get blockOnce;

  /// Batch block dialog: the chosen start time.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String blockAtTime(String time);

  /// Screen reader announcement after capturing one or more items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved} other{Saved {count} items}}'**
  String captureSavedAnnouncement(int count);

  /// Quick capture field hint.
  ///
  /// In en, this message translates to:
  /// **'What’s on your mind?'**
  String get captureHint;

  /// Quick capture helper text.
  ///
  /// In en, this message translates to:
  /// **'Saved to Inbox. Decide what it means later.'**
  String get captureHelper;

  /// Quick capture helper text when opened from a list.
  ///
  /// In en, this message translates to:
  /// **'Saved to Inbox, in {list}.'**
  String captureHelperInList(String list);

  /// Quick capture: how many thoughts were saved this time.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} to Inbox'**
  String captureSavedCount(int count);

  /// Snackbar after moving an item to Trash.
  ///
  /// In en, this message translates to:
  /// **'Moved to Trash'**
  String get commandsTrashed;

  /// Snackbar after moving an item to Someday.
  ///
  /// In en, this message translates to:
  /// **'Kept as an idea in Someday'**
  String get commandsSomeday;

  /// Snackbar after snoozing an item to tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Moved to tomorrow'**
  String get commandsSnoozed;

  /// Snackbar after picking a new date for an item.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get commandsRescheduled;

  /// Dialog title when the must-do limit is reached.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You already have 1 must-do} other{You already have {count} must-dos}}'**
  String commandsMustDoCapTitle(int count);

  /// Must-do limit dialog: asks which one to replace.
  ///
  /// In en, this message translates to:
  /// **'Swap one out to make room?'**
  String get commandsMustDoSwapPrompt;

  /// Must-do limit dialog: leave everything unchanged.
  ///
  /// In en, this message translates to:
  /// **'Keep things as they are'**
  String get commandsMustDoKeep;

  /// Inbox tab tooltip with the number of items waiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Inbox, 1 item} other{Inbox, {count} items}}'**
  String shellInboxTooltip(int count);

  /// Tooltip on the add button that opens quick capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get shellCapture;

  /// Screen reader label for progress in a guided flow.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {count}'**
  String stepTrailLabel(int current, int count);

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'How much Today asks of you.'**
  String get settingsTodayHint;

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Where new thoughts wait for a decision.'**
  String get settingsInboxHint;

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'When and how Clearing may notify you.'**
  String get settingsRemindersHint;

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'A gentle nudge to look over your week.'**
  String get settingsWeeklyReviewHint;

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Where finished things go.'**
  String get settingsDoneHint;

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'It stays on this phone unless you export it.'**
  String get settingsDataHint;

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Light, dark, or follow the phone.'**
  String get settingsAppearanceHint;

  /// One-line explanation under a Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Answers, and how Clearing works.'**
  String get settingsHelpHint;

  /// First welcome page title.
  ///
  /// In en, this message translates to:
  /// **'Close your mental tabs.'**
  String get welcomeTitle;

  /// First welcome page text.
  ///
  /// In en, this message translates to:
  /// **'Clearing is a quiet place for everything on your mind, so you can stop carrying it around.'**
  String get welcomeBody;

  /// Button: start the tour.
  ///
  /// In en, this message translates to:
  /// **'Show me around'**
  String get welcomeShowMe;

  /// Button: skip onboarding.
  ///
  /// In en, this message translates to:
  /// **'Skip the tour'**
  String get welcomeSkip;

  /// Tour page title.
  ///
  /// In en, this message translates to:
  /// **'Capture it'**
  String get welcomeCaptureTitle;

  /// Tour page text.
  ///
  /// In en, this message translates to:
  /// **'The moment something pops into your head, tap + and write one line. It waits in your Inbox until you have a minute.'**
  String get welcomeCaptureBody;

  /// Tour page title.
  ///
  /// In en, this message translates to:
  /// **'Decide what it means'**
  String get welcomeDecideTitle;

  /// Tour page text.
  ///
  /// In en, this message translates to:
  /// **'Later, give each thought a place: today, this week, a date, someone else’s job, or Someday if it’s just an idea.'**
  String get welcomeDecideBody;

  /// Tour page title.
  ///
  /// In en, this message translates to:
  /// **'Keep Today small'**
  String get welcomeTodayTitle;

  /// Tour page text.
  ///
  /// In en, this message translates to:
  /// **'Pick up to three must-dos. Missed things are carried over, never shown in red, never held against you.'**
  String get welcomeTodayBody;

  /// Tour page title.
  ///
  /// In en, this message translates to:
  /// **'Look back once a week'**
  String get welcomeReviewTitle;

  /// Tour page text.
  ///
  /// In en, this message translates to:
  /// **'A 15-minute weekly review clears your head and plans the week, so nothing slips.'**
  String get welcomeReviewBody;

  /// Tour page title.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get welcomePrivateTitle;

  /// Tour page text.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads, no internet access. Everything stays on this phone, and you can export a backup any time.'**
  String get welcomePrivateBody;

  /// Setup page title.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get welcomeSetupTitle;

  /// Setup page hint.
  ///
  /// In en, this message translates to:
  /// **'You can change all of this later in Settings.'**
  String get welcomeSetupHint;

  /// Setup: must-do cap.
  ///
  /// In en, this message translates to:
  /// **'Must-dos per day'**
  String get welcomeSetupMustDo;

  /// Setup: must-do cap hint.
  ///
  /// In en, this message translates to:
  /// **'Fewer is calmer. Three is a good start.'**
  String get welcomeSetupMustDoHint;

  /// Setup: week start.
  ///
  /// In en, this message translates to:
  /// **'Your week starts on'**
  String get welcomeSetupWeek;

  /// Setup: notification intensity.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get welcomeSetupReminders;

  /// Setup: review reminder switch.
  ///
  /// In en, this message translates to:
  /// **'Remind me to do a weekly review'**
  String get welcomeSetupReview;

  /// Setup: review day and time.
  ///
  /// In en, this message translates to:
  /// **'{day} at {time}'**
  String welcomeSetupReviewWhen(String day, String time);

  /// Setup: finish button.
  ///
  /// In en, this message translates to:
  /// **'Start using Clearing'**
  String get welcomeSetupDone;

  /// Last page title.
  ///
  /// In en, this message translates to:
  /// **'You’re all set'**
  String get welcomeReadyTitle;

  /// Last page text.
  ///
  /// In en, this message translates to:
  /// **'Tip: add the Today and quick-capture widgets to your home screen. Long-press the home screen, then Widgets › Clearing.'**
  String get welcomeReadyBody;

  /// Last page button.
  ///
  /// In en, this message translates to:
  /// **'Capture my first thought'**
  String get welcomeCaptureFirst;

  /// Last page button.
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get welcomeGoToday;

  /// Screen reader position in the welcome.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String welcomePageLabel(int page, int total);

  /// Title when replaying the tour.
  ///
  /// In en, this message translates to:
  /// **'How Clearing works'**
  String get welcomeTourTitle;

  /// Small label on a tip card.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tipLabel;

  /// Dismiss a tip.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tipGotIt;

  /// Tip on Today.
  ///
  /// In en, this message translates to:
  /// **'Tap the ring when something’s done. Long-press any item for more options.'**
  String get tipTodayRing;

  /// Tip on the Inbox.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to plan an item for today or this week. Swipe left to pick a date, keep it for Someday, or delete it. Or tap it to decide step by step.'**
  String get tipInboxSwipe;

  /// Tip on Upcoming.
  ///
  /// In en, this message translates to:
  /// **'See a whole week at a time with the week icon at the top.'**
  String get tipUpcomingWeek;

  /// Tip on Lists.
  ///
  /// In en, this message translates to:
  /// **'Open a list and tap the calendar icon to block out time for it, like “Errands, Saturday 10:00”.'**
  String get tipListsBlock;

  /// Tip on an item.
  ///
  /// In en, this message translates to:
  /// **'Feeling stuck? Tap the focus icon at the top to see only this item.'**
  String get tipItemFocus;

  /// Tip in the capture sheet.
  ///
  /// In en, this message translates to:
  /// **'Press Enter after each thought: the field stays open for the next one.'**
  String get tipCaptureBurst;

  /// Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Show tips as you go'**
  String get settingsShowTips;

  /// Settings switch hint.
  ///
  /// In en, this message translates to:
  /// **'Short hints the first time you visit each screen'**
  String get settingsShowTipsHint;

  /// Settings action.
  ///
  /// In en, this message translates to:
  /// **'Show all tips again'**
  String get settingsResetTips;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Tips will show again'**
  String get settingsTipsReset;

  /// Settings action: tour and setup again.
  ///
  /// In en, this message translates to:
  /// **'Replay the welcome'**
  String get settingsReplayWelcome;

  /// Settings action hint.
  ///
  /// In en, this message translates to:
  /// **'The tour, and setting up the basics'**
  String get settingsReplayWelcomeHint;

  /// Help hub title and settings entry.
  ///
  /// In en, this message translates to:
  /// **'Help and guides'**
  String get helpTitle;

  /// Settings entry subtitle.
  ///
  /// In en, this message translates to:
  /// **'Guides, questions and answers'**
  String get helpSubtitle;

  /// Help hub section.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get helpGetStarted;

  /// Help hub section.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get helpGuides;

  /// Help hub section.
  ///
  /// In en, this message translates to:
  /// **'More help'**
  String get helpMore;

  /// Help hub: tour row hint.
  ///
  /// In en, this message translates to:
  /// **'Five short pages'**
  String get helpTourHint;

  /// Guide title.
  ///
  /// In en, this message translates to:
  /// **'Capturing thoughts'**
  String get guideCaptureTitle;

  /// Guide lead sentence.
  ///
  /// In en, this message translates to:
  /// **'Get it out of your head first; decide later.'**
  String get guideCaptureLead;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Tap + anywhere'**
  String get guideCapture1Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'The capture button is on every tab. Write one line and press Enter; the field stays open for the next thought.'**
  String get guideCapture1Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Paste a brain-dump'**
  String get guideCapture2Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Paste several lines at once and each line becomes its own item.'**
  String get guideCapture2Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Share from other apps'**
  String get guideCapture3Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Share text from a message or a web page to Clearing to capture it.'**
  String get guideCapture3Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'From your home screen'**
  String get guideCapture4Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Add the quick-capture widget: long-press the home screen, then Widgets › Clearing.'**
  String get guideCapture4Body;

  /// Guide title.
  ///
  /// In en, this message translates to:
  /// **'Deciding what things mean'**
  String get guideDecideTitle;

  /// Guide lead sentence.
  ///
  /// In en, this message translates to:
  /// **'Every thought in the Inbox gets a place, in a few taps.'**
  String get guideDecideLead;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Clarify step by step'**
  String get guideDecide1Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Tap an Inbox item. Clearing asks: is it actionable, what’s the next action, is someone else doing it, and when?'**
  String get guideDecide1Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Swipe shortcuts'**
  String get guideDecide2Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Swipe right for Today or This week; swipe left to pick a date, keep it for Someday, or delete it.'**
  String get guideDecide2Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Done means…'**
  String get guideDecide3Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'For anything vague, write what finished looks like, and break it into steps.'**
  String get guideDecide3Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Waiting on someone'**
  String get guideDecide4Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'If someone else is doing it, note who, and when to follow up.'**
  String get guideDecide4Body;

  /// Guide title.
  ///
  /// In en, this message translates to:
  /// **'Today and must-dos'**
  String get guideTodayTitle;

  /// Guide lead sentence.
  ///
  /// In en, this message translates to:
  /// **'Today shows what you planned for today, and keeps it small.'**
  String get guideTodayLead;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Must-dos'**
  String get guideToday1Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Star up to three things that truly must happen. Everything else stays visible below.'**
  String get guideToday1Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Carried over'**
  String get guideToday2Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Things from earlier days wait quietly at the bottom. Nothing turns red.'**
  String get guideToday2Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get guideToday3Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Things for this week, without a day, gather in one row.'**
  String get guideToday3Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Done, and undo'**
  String get guideToday4Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Tap the ring when done. Changed your mind? Tap Undo, or untick it in Lists › Done.'**
  String get guideToday4Body;

  /// Guide title.
  ///
  /// In en, this message translates to:
  /// **'Dates, reminders and repeats'**
  String get guideTimeTitle;

  /// Guide lead sentence.
  ///
  /// In en, this message translates to:
  /// **'When you’ll do it, when it’s due, and when to be reminded are three separate things.'**
  String get guideTimeLead;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Do on, deadline, remind me'**
  String get guideTime1Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'“When” is the day you plan to do it. A deadline is when it’s due. A reminder is a notification; you can have up to three.'**
  String get guideTime1Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get guideTime2Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Daily, weekly or monthly, or counted from when you finish (good for haircuts). Missed repeats never pile up.'**
  String get guideTime2Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get guideTime3Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Early reminders wait until morning; ones you timed exactly still arrive.'**
  String get guideTime3Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Morning summary'**
  String get guideTime4Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Turn on one note each morning with today’s must-dos, in Settings › Reminders.'**
  String get guideTime4Body;

  /// Guide title.
  ///
  /// In en, this message translates to:
  /// **'Reviews and resets'**
  String get guideReviewTitle;

  /// Guide lead sentence.
  ///
  /// In en, this message translates to:
  /// **'Two short routines that keep your head clear.'**
  String get guideReviewLead;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get guideReview1Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'About 15 minutes: empty your head, sort the Inbox, look back at last week and ahead at the next.'**
  String get guideReview1Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Overwhelm reset'**
  String get guideReview2Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'When it’s all too much, five quick steps narrow everything down to one thing.'**
  String get guideReview2Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get guideReview3Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Shows a single item and nothing else, until it’s done.'**
  String get guideReview3Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Print a worksheet'**
  String get guideReview4Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Print today or this week on one page, with room to write.'**
  String get guideReview4Body;

  /// Guide title.
  ///
  /// In en, this message translates to:
  /// **'Lists, blocks and templates'**
  String get guideOrganizeTitle;

  /// Guide lead sentence.
  ///
  /// In en, this message translates to:
  /// **'Group things by context, and reuse what you do often.'**
  String get guideOrganizeLead;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get guideOrganize1Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Life Admin, Errands, and your own lists. An item can be in a list and planned for a day.'**
  String get guideOrganize1Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Time blocks'**
  String get guideOrganize2Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Block out time for a whole list, like Errands on Saturday morning, and it shows as one entry on Today.'**
  String get guideOrganize2Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Templates and routines'**
  String get guideOrganize3Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Save checklists you use again and again. Make one a routine and it arrives on its own schedule.'**
  String get guideOrganize3Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get guideOrganize4Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Find anything, including done items, from the search icon.'**
  String get guideOrganize4Body;

  /// Guide title.
  ///
  /// In en, this message translates to:
  /// **'Your data and privacy'**
  String get guideDataTitle;

  /// Guide lead sentence.
  ///
  /// In en, this message translates to:
  /// **'Clearing keeps everything on this phone.'**
  String get guideDataLead;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'No account, no internet'**
  String get guideData1Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'There’s no server and no tracking; the app can’t reach the internet at all.'**
  String get guideData1Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get guideData2Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Export a copy in Settings › Backup, and restore it on any phone.'**
  String get guideData2Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Moving phones'**
  String get guideData3Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Android’s phone-to-phone transfer brings Clearing’s data along, or use a backup.'**
  String get guideData3Body;

  /// Guide point heading.
  ///
  /// In en, this message translates to:
  /// **'Trash and archive'**
  String get guideData4Title;

  /// Guide point text.
  ///
  /// In en, this message translates to:
  /// **'Deleted items stay in Trash for 30 days; done items move to the archive and stay searchable.'**
  String get guideData4Body;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

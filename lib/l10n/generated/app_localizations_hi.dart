// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Clearing';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonDone => 'हो गया';

  @override
  String get commonNext => 'आगे';

  @override
  String get commonSkip => 'छोड़ें';

  @override
  String get commonBack => 'वापस';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get commonUndo => 'वापस लें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonSearch => 'खोजें';

  @override
  String get commonSettings => 'सेटिंग्स';

  @override
  String get commonMore => 'और';

  @override
  String get commonNone => 'कोई नहीं';

  @override
  String get commonFinish => 'पूरा करें';

  @override
  String get commonOk => 'ठीक है';

  @override
  String get commonRemove => 'हटाएँ';

  @override
  String get commonCreate => 'बनाएँ';

  @override
  String get commonName => 'नाम';

  @override
  String get whenToday => 'आज';

  @override
  String get whenThisWeek => 'इस हफ़्ते';

  @override
  String get whenAnytime => 'कभी भी';

  @override
  String get whenPickDate => 'तारीख़ चुनें';

  @override
  String get whenAnytimeHint => 'कोई ख़ास दिन नहीं';

  @override
  String get whenQuestion => 'कब?';

  @override
  String get tabToday => 'आज';

  @override
  String get tabInbox => 'इनबॉक्स';

  @override
  String get tabUpcoming => 'आगे';

  @override
  String get tabLists => 'सूचियाँ';

  @override
  String get someday => 'किसी दिन';

  @override
  String get waitingOn => 'इंतज़ार में';

  @override
  String get mustDo => 'ज़रूरी';

  @override
  String get dateTomorrow => 'कल';

  @override
  String get dateYesterday => 'बीता कल';

  @override
  String repeatEveryDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count दिन',
      one: 'हर दिन',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count हफ़्ते',
      one: 'हर हफ़्ते',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count महीने',
      one: 'हर महीने',
    );
    return '$_temp0';
  }

  @override
  String get repeatAfterDone => 'पूरा होने के बाद से';

  @override
  String repeatOnDays(String days) {
    return '$days को';
  }

  @override
  String repeatOnMonthDay(String day) {
    return '$day तारीख़ को';
  }

  @override
  String repeatUntil(String date) {
    return '$date तक';
  }

  @override
  String repeatTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार',
      one: 'एक बार',
    );
    return '$_temp0';
  }

  @override
  String get offsetAtTime => 'उसी समय';

  @override
  String offsetMinutes(int count) {
    return '$count मिनट पहले';
  }

  @override
  String offsetHours(int count) {
    return '$count घंटे पहले';
  }

  @override
  String offsetDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: '1 दिन पहले',
    );
    return '$_temp0';
  }

  @override
  String get notifReviewTitle => 'साप्ताहिक समीक्षा का समय';

  @override
  String get notifReviewBody =>
      'लगभग 15 मिनट: मन हल्का करें और हफ़्ते की योजना बनाएँ।';

  @override
  String get notifBackupTitle => 'बैकअप का समय';

  @override
  String get notifBackupBody =>
      'एक कॉपी एक्सपोर्ट कर लें, ताकि फ़ोन खोने पर योजनाएँ न खोएँ।';

  @override
  String get notifDigestTitle => 'आज';

  @override
  String notifDoneMeans(String text) {
    return 'पूरा होने का मतलब: $text';
  }

  @override
  String notifBlockTitle(String list) {
    return '$list का समय';
  }

  @override
  String notifBlockBody(String list) {
    return '$list के सारे काम एक साथ निपटाएँ।';
  }

  @override
  String notifDigestMustDos(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ज़रूरी: $titles',
      one: '1 ज़रूरी: $titles',
    );
    return '$_temp0';
  }

  @override
  String notifDigestMoreToday(int count) {
    return 'आज $count और';
  }

  @override
  String notifDigestOnToday(int count) {
    return 'आज $count काम';
  }

  @override
  String get notifActionDone => 'हो गया';

  @override
  String get notifActionSnoozeHour => '1 घंटे बाद';

  @override
  String get notifActionTomorrow => 'कल';

  @override
  String get worksheetDocToday => 'Clearing: आज';

  @override
  String get worksheetDocWeek => 'Clearing: हफ़्ता';

  @override
  String worksheetMoreInApp(int count) {
    return '+$count और, ऐप में';
  }

  @override
  String worksheetMore(int count) {
    return '+$count और';
  }

  @override
  String get worksheetBlocks => 'समय-खंड';

  @override
  String get worksheetAlsoToday => 'आज और';

  @override
  String get worksheetOnYourMind => 'मन में जो है';

  @override
  String get worksheetAnyDay => 'कोई भी दिन · मन में जो है';

  @override
  String worksheetWeekOf(String date) {
    return '$date वाला हफ़्ता';
  }

  @override
  String get worksheetList => 'सूची';

  @override
  String worksheetCarriedOver(String item) {
    return '$item (पिछले दिनों से बाकी)';
  }

  @override
  String get flowCaptureHint => 'आपके मन में क्या है?';

  @override
  String flowSavedToInbox(int count, String title) {
    return 'इनबॉक्स में $count सहेजे गए · सबसे नया: $title';
  }

  @override
  String get flowItemGone => 'यह काम अब मौजूद नहीं है।';

  @override
  String get focusTitle => 'फ़ोकस';

  @override
  String focusDoneMeans(String doneMeans) {
    return 'पूरा होने का मतलब: $doneMeans';
  }

  @override
  String get focusNotNow => 'अभी नहीं';

  @override
  String get focusFinishedTitle => 'एक काम कम';

  @override
  String get reviewTitle => 'साप्ताहिक समीक्षा';

  @override
  String get reviewResumed => 'जहाँ आपने छोड़ा था, वहीं से शुरू कर रहे हैं।';

  @override
  String get reviewStartOver => 'फिर से शुरू करें';

  @override
  String get reviewEmptyHeadTitle => 'मन खाली करें';

  @override
  String get reviewEmptyHeadHint =>
      'जो कुछ अभी तक लिखा नहीं है: छोटे काम, चिंताएँ, जिन्हें जवाब देना है। एक बार में एक बात।';

  @override
  String get reviewInboxClearTitle => 'इनबॉक्स खाली है';

  @override
  String get reviewInboxClearHint => 'हर काम की अपनी जगह है।';

  @override
  String reviewInboxSkipped(int count) {
    return '$count अभी के लिए छोड़े गए। ये अगली बार यहीं मिलेंगे।';
  }

  @override
  String reviewInboxLeft(int count) {
    return 'इनबॉक्स में $count बाकी हैं। इसे कहाँ रखें?';
  }

  @override
  String get reviewSkipForNow => 'अभी छोड़ें';

  @override
  String get reviewWaitingOnChoice => 'इंतज़ार में…';

  @override
  String get reviewAlreadyDone => 'पहले ही हो गया';

  @override
  String get reviewWhoWaitingOn => 'आप किसका इंतज़ार कर रहे हैं?';

  @override
  String get reviewMarkDone => 'हो गया चिह्नित करें';

  @override
  String get reviewReplan => 'फिर से तय करें';

  @override
  String get reviewLetGo => 'किसी दिन में भेजें';

  @override
  String get reviewLastWeekTitle => 'पिछले हफ़्ते के बाकी काम';

  @override
  String get reviewLastWeekEmpty => 'पिछले हफ़्ते का कुछ भी बाकी नहीं है।';

  @override
  String get reviewLastWeekHint =>
      'इस हफ़्ते के काम और पिछले दिनों से बाकी सब। इन्हें फिर से तय करें, या जाने दें।';

  @override
  String get reviewWaitingEmpty => 'आप किसी का इंतज़ार नहीं कर रहे हैं।';

  @override
  String get reviewWaitingHint =>
      'याद दिलाएँ, हो गया चिह्नित करें, या खुद करने के लिए वापस लें।';

  @override
  String get reviewSomeone => 'कोई';

  @override
  String reviewFollowUpOn(String date) {
    return 'फ़ॉलो-अप $date';
  }

  @override
  String get reviewFollowUpTooltip => 'फ़ॉलो-अप की तारीख़…';

  @override
  String get reviewTakeBack => 'वापस लें';

  @override
  String get reviewNextWeekTitle => 'अगले 7 दिन';

  @override
  String get reviewNextWeekEmpty =>
      'आने वाले हफ़्ते में कोई तारीख़ वाला काम नहीं है।';

  @override
  String get reviewNextWeekHint =>
      'आगे क्या है, एक नज़र में। बदलने के लिए किसी पर टैप करें।';

  @override
  String get reviewSomedayEmpty => 'कोई विचार रखा हुआ नहीं है।';

  @override
  String get reviewSomedayHint =>
      'ज़रूरी नहीं। क्या इनमें से कुछ अब योजना बन सकता है?';

  @override
  String get reviewMakePlan => 'योजना बनाएँ';

  @override
  String get reviewWhenWillYou => 'आप इसे कब करेंगे?';

  @override
  String get reviewCloseTitle => 'हफ़्ता पूरा हुआ';

  @override
  String get reviewCloseHint => 'अब मन थोड़ा हल्का लगना चाहिए।';

  @override
  String reviewCloseSummary(int cleared, int planned) {
    return '$cleared निपटाए · $planned तय किए';
  }

  @override
  String reviewCloseSkipped(int skipped) {
    return '$skipped किसी और समय के लिए छोड़े गए।';
  }

  @override
  String get resetTitle => 'बोझ हल्का करें';

  @override
  String get resetMindTitle => 'आपके मन की हर बात';

  @override
  String get resetMindHint =>
      'सब कुछ लिख डालें, एक बार में एक बात। अभी कुछ तय करने की ज़रूरत नहीं।';

  @override
  String get resetOnYourPlate => 'पहले से आपके पास';

  @override
  String get resetTodayTitle => 'आज क्या ज़रूरी है?';

  @override
  String resetTodayHint(int cap) {
    return 'ज़्यादा से ज़्यादा $cap। सिर्फ़ वही जो सच में रुक नहीं सकता।';
  }

  @override
  String get resetTodayEmpty => 'अभी कुछ भी बाकी नहीं है।';

  @override
  String get resetWeekTitle => 'इस हफ़्ते क्या करना है?';

  @override
  String get resetWeekHint =>
      'यह आज में एक शांत पंक्ति के रूप में दिखता रहेगा।';

  @override
  String get resetWeekEmpty => 'और कुछ बाकी नहीं है।';

  @override
  String get resetLetGoTitle => 'बाकी को जाने दें?';

  @override
  String get resetLetGoEmpty => 'कुछ भी बाकी नहीं है।';

  @override
  String get resetLetGoHint =>
      'चुने गए काम किसी दिन में जाएँगे, या 30 दिनों के लिए ट्रैश में। जो जैसा है वैसा रखना हो, उसका निशान हटा दें।';

  @override
  String get resetKeepAll => 'सब रखें';

  @override
  String get resetMoveToSomeday => 'किसी दिन में भेजें';

  @override
  String get resetSmallestTitle => 'सबसे छोटा अगला कदम';

  @override
  String get resetSmallestEmpty =>
      'कुछ नहीं चुना गया, और यह ठीक है। आपने थोड़ी जगह बना ली है।';

  @override
  String get resetSmallestHint =>
      'एक चुनें। चाहें तो इतना छोटा पहला कदम लिखें कि वह आसान लगे।';

  @override
  String get resetFocusOnIt => 'इस पर फ़ोकस करें';

  @override
  String get resetFirstStepLabel => 'छोटा-सा पहला कदम (वैकल्पिक)';

  @override
  String get resetFirstStepHint => 'जैसे “चिट्ठी खोलें”';

  @override
  String get clarifyTitle => 'स्पष्ट करें';

  @override
  String get clarifyActionableTitle => 'क्या इस पर कुछ करना है?';

  @override
  String get clarifyActionableYes => 'हाँ, कुछ करना है';

  @override
  String get clarifyKeepIdea => 'नहीं, इसे विचार के रूप में रखें';

  @override
  String get clarifyKeepIdeaHint => 'यह किसी दिन में रहेगा, आज से दूर';

  @override
  String get clarifyLetGo => 'नहीं, जाने दें';

  @override
  String get clarifyLetGoHint => '30 दिनों के लिए ट्रैश में';

  @override
  String get clarifyNextActionTitle => 'अगला कदम क्या है?';

  @override
  String get clarifyNextActionHint =>
      'एक साफ़ कदम, किसी क्रिया से शुरू करें: फ़ोन करें, खरीदें, ईमेल करें, बुक करें…';

  @override
  String get clarifyDelegateTitle => 'क्या कोई और इसे कर रहा है?';

  @override
  String get clarifyWho => 'कौन?';

  @override
  String get clarifyFollowUpOptional => 'फ़ॉलो-अप की तारीख़… (वैकल्पिक)';

  @override
  String clarifyFollowUpOn(String date) {
    return 'फ़ॉलो-अप $date';
  }

  @override
  String get clarifyDoItMyself => 'नहीं, मैं करूँगा/करूँगी';

  @override
  String get clarifyWaitingYes => 'हाँ, मैं किसी का इंतज़ार कर रहा/रही हूँ';

  @override
  String get clarifyWaitingYesHint =>
      'किसका इंतज़ार है और कब याद दिलाना है, यह रखें';

  @override
  String get clarifySaveWaiting => 'इंतज़ार में सहेजें';

  @override
  String get clarifyThisWeekHint => 'दिन चुनने तक आज में एक शांत पंक्ति';

  @override
  String get clarifyDetailsTitle => 'और कुछ?';

  @override
  String get clarifyDetailsHint => 'सब वैकल्पिक है।';

  @override
  String get clarifyMustDoToday => 'आज ज़रूरी';

  @override
  String get clarifyRemindMe => 'याद दिलाएँ';

  @override
  String get clarifyNoReminder => 'कोई रिमाइंडर नहीं';

  @override
  String get clarifyRemoveReminders => 'रिमाइंडर हटाएँ';

  @override
  String get clarifyRepeat => 'दोहराएँ';

  @override
  String get clarifyNoRepeat => 'दोहराया नहीं जाता';

  @override
  String get clarifyDontRepeat => 'न दोहराएँ';

  @override
  String get clarifyDoneMeans => 'पूरा होने का मतलब…';

  @override
  String get clarifyDoneMeansHint =>
      'जैसे “फ़ॉर्म भेज दिया”, न कि “टैक्स का काम निपटाना”';

  @override
  String get faqTitle => 'सवाल और जवाब';

  @override
  String get faqSectionData => 'आपका डेटा';

  @override
  String get faqSectionUsing => 'Clearing का इस्तेमाल';

  @override
  String get faqSectionReminders => 'रिमाइंडर';

  @override
  String get faqRemindersHelpSubtitle =>
      'आपके फ़ोन की बैटरी सेटिंग्स जिन्हें देखना चाहिए';

  @override
  String get faqWhereKeptQ => 'मेरी चीज़ें कहाँ रखी जाती हैं?';

  @override
  String get faqWhereKeptA =>
      'सिर्फ़ इसी फ़ोन पर। Clearing में न कोई अकाउंट है, न सर्वर, न इंटरनेट एक्सेस। इसलिए आप जो भी लिखते हैं, वह फ़ोन से बाहर नहीं जाता, जब तक आप उसे एक्सपोर्ट न करें।';

  @override
  String get faqNewPhoneQ => 'नए फ़ोन पर कैसे ले जाएँ?';

  @override
  String get faqNewPhoneA =>
      'सेटिंग्स › बैकअप में जाकर बैकअप शेयर करें, और फ़ाइल ऐसी जगह भेजें जहाँ नए फ़ोन से पहुँच सकें (ख़ुद को ईमेल करें, या Drive में सेव करें)। नए फ़ोन पर Clearing इंस्टॉल करें और बैकअप से रीस्टोर चुनें। नया फ़ोन सेट करते समय Android का फ़ोन-से-फ़ोन ट्रांसफ़र भी Clearing का डेटा ले आता है।';

  @override
  String get faqUninstallQ => 'Clearing अनइंस्टॉल करने पर क्या होगा?';

  @override
  String get faqUninstallA =>
      'ऐप के साथ उसमें रखी हर चीज़ मिट जाती है। अगर बाद में चाहिए हो सकती है, तो पहले बैकअप एक्सपोर्ट कर लें। Clearing महीने में एक बार एक्सपोर्ट करने की याद दिलाता है, और यह कितनी बार हो, आप बैकअप में बदल सकते हैं।';

  @override
  String get faqTwoDevicesQ =>
      'क्या मैं Clearing दो डिवाइस पर इस्तेमाल कर सकता हूँ?';

  @override
  String get faqTwoDevicesA =>
      'सिंक के साथ नहीं: हर फ़ोन अपनी अलग कॉपी रखता है। बैकअप से चीज़ें एक से दूसरे पर ले जा सकते हैं: रीस्टोर › मिलाएँ (Merge) जो नहीं है उसे जोड़ देता है, और जो दोनों पर है उसकी नई कॉपी रखता है।';

  @override
  String get faqUndoQ => 'ग़लती से कुछ हो गया। क्या उसे वापस कर सकते हैं?';

  @override
  String get faqUndoA =>
      'किसी काम को पूरा करने, मिटाने या हटाने के तुरंत बाद, स्क्रीन के नीचे आए संदेश पर “पहले जैसा करें” दबाएँ। मिटाए गए काम 30 दिन तक सूचियाँ › ट्रैश में रहते हैं। पूरे किए काम सूचियाँ › पूरे हुए में हैं; किसी को वापस लाने के लिए उसका टिक हटा दें।';

  @override
  String get faqCarriedOverQ => '“पिछले दिनों से बाकी” का क्या मतलब है?';

  @override
  String get faqCarriedOverA =>
      'ऐसा काम जो किसी पिछले दिन के लिए तय था और अभी पूरा नहीं हुआ। वह चुपचाप आज में रहता है, जब तक आप उसे कर न लें या कहीं और न ले जाएँ। कुछ लाल नहीं होता, और कुछ भी आपके ख़िलाफ़ नहीं गिना जाता।';

  @override
  String get faqMissedRepeatQ => 'दोहराने वाला काम छूट जाए तो क्या होता है?';

  @override
  String get faqMissedRepeatA =>
      'यह आप हर काम के लिए चुनते हैं। “आगे ले जाएँ” छूटे काम को पूरा होने तक आज में रखता है, और अगला इंतज़ार करता है। “चुपचाप छोड़ दें” उसे जाने देता है और नई शुरुआत करता है। दोनों में, छूटे दिन कभी जमा नहीं होते।';

  @override
  String get faqMustDoLimitQ => 'आज में बस कुछ ही ज़रूरी काम क्यों?';

  @override
  String get faqMustDoLimitA =>
      'छोटी सूची पूरी हो जाती है; लंबी सूची बोझ बन जाती है। बाकी सब नीचे दिखता रहता है। यह सीमा (1 से 5) आप सेटिंग्स में बदल सकते हैं।';

  @override
  String get faqNoStreaksQ => 'स्ट्रीक या स्कोर क्यों नहीं हैं?';

  @override
  String get faqNoStreaksA =>
      'इनसे छूटा हुआ दिन हार जैसा लगता है। Clearing सिर्फ़ यह गिनता है कि आपने क्या निपटाया और क्या तय किया, और कुछ नहीं।';

  @override
  String get remindersHelpTitle => 'रिमाइंडर नहीं आ रहे?';

  @override
  String get remindersHelpIntro =>
      'Clearing हर रिमाइंडर आपके फ़ोन पर ही तय करता है; कुछ भी सर्वर से होकर नहीं जाता। कुछ फ़ोन बैटरी बचाने के लिए बैकग्राउंड में ऐप्स रोक देते हैं, जिससे रिमाइंडर देर से आ सकते हैं या छूट सकते हैं।';

  @override
  String get remindersHelpFirstCheck => 'पहले यह देखें';

  @override
  String get remindersHelpNotificationsTitle => 'नोटिफ़िकेशन की अनुमति है';

  @override
  String get remindersHelpNotificationsPath =>
      'Settings › Apps › Clearing › Notifications';

  @override
  String get remindersHelpExactTitle => 'सटीक समय चालू है';

  @override
  String get remindersHelpExactBody =>
      'इसके बिना Android रिमाइंडर कुछ मिनट देर से दे सकता है। Clearing की सेटिंग्स में “सटीक समय” देखें।';

  @override
  String get remindersHelpDndTitle => 'Do Not Disturb बंद है';

  @override
  String get remindersHelpDndBody =>
      'चालू रहने पर यह रिमाइंडर की आवाज़ बंद कर देता है या उन्हें छिपा देता है।';

  @override
  String get remindersHelpForYourPhone => 'फिर, अपने फ़ोन के लिए';

  @override
  String get remindersHelpBrandXiaomi => 'Xiaomi, Redmi और POCO';

  @override
  String get remindersHelpBrandOnePlus => 'OnePlus, OPPO और realme';

  @override
  String get remindersHelpBrandVivo => 'vivo और iQOO';

  @override
  String get remindersHelpBrandHuawei => 'Huawei और Honor';

  @override
  String get remindersHelpBrandPixel => 'Pixel और दूसरे फ़ोन';

  @override
  String get remindersHelpSamsung =>
      'Settings › Apps › Clearing › Battery › Unrestricted. साथ ही Settings › Battery › Background usage limits भी देखें, और Clearing को “Sleeping apps” से हटा दें।';

  @override
  String get remindersHelpXiaomi =>
      'Settings › Apps › Manage apps › Clearing: Autostart चालू करें, और Battery saver को “No restrictions” पर रखें।';

  @override
  String get remindersHelpOnePlus =>
      'Settings › Apps › Clearing › Battery: बैकग्राउंड गतिविधि की अनुमति दें और “Optimise battery use” बंद करें। कुछ वर्ज़न में Auto launch की अनुमति भी दें।';

  @override
  String get remindersHelpVivo =>
      'Settings › Battery › Background power consumption management: Clearing को अनुमति दें। साथ ही i Manager में Clearing के लिए Autostart चालू करें।';

  @override
  String get remindersHelpHuawei =>
      'Settings › Battery › App launch › Clearing: “Manage manually” पर करें, और Auto-launch, Secondary launch और Run in background की अनुमति दें।';

  @override
  String get remindersHelpPixel =>
      'Settings › Apps › Clearing › App battery usage: Unrestricted.';

  @override
  String get remindersHelpFooter =>
      'मेन्यू के नाम वर्ज़न के हिसाब से बदलते हैं। dontkillmyapp.com पर और भी कई फ़ोन के लिए ताज़ा तरीक़े मिलेंगे।';

  @override
  String get templateGone => 'यह टेम्पलेट अब मौजूद नहीं है।';

  @override
  String get templateWhenStart => 'आप इसे कब करेंगे?';

  @override
  String get templateAddedToInbox => 'इनबॉक्स में जोड़ा गया';

  @override
  String templateAdded(String title) {
    return '“$title” जोड़ा गया';
  }

  @override
  String get templateRoutine => 'दिनचर्या';

  @override
  String get templateTemplate => 'टेम्पलेट';

  @override
  String get templateStopRoutine => 'दिनचर्या रोकें';

  @override
  String get templateDelete => 'टेम्पलेट मिटाएँ';

  @override
  String get templateSteps => 'चरण';

  @override
  String get templateDragToReorder => 'क्रम बदलने के लिए खींचें';

  @override
  String get templateRemoveStep => 'चरण हटाएँ';

  @override
  String get templateAddStepHint => 'एक चरण जोड़ें';

  @override
  String get templateAddStep => 'चरण जोड़ें';

  @override
  String get templateDoneMeans => 'पूरा होने का मतलब…';

  @override
  String get templateList => 'सूची';

  @override
  String get templateUseIt => 'इस्तेमाल करें';

  @override
  String get templateMakeRoutine => 'इसे दिनचर्या बनाएँ';

  @override
  String get templateMakeRoutineHint =>
      'आपके चुने दिनों पर नई चेकलिस्ट की तरह आएगा';

  @override
  String get templateStartNow => 'अभी शुरू करें';

  @override
  String get templateStartNote =>
      'शुरू करने पर एक कॉपी बनती है। बाद में टेम्पलेट बदलने से, उससे पहले बने कामों पर असर नहीं पड़ेगा।';

  @override
  String get templatesTitle => 'दिनचर्या और टेम्पलेट';

  @override
  String get templatesNew => 'नया टेम्पलेट';

  @override
  String get templatesNameHint => 'जैसे, पैकिंग की सूची';

  @override
  String get templatesEmptyTitle => 'अभी कोई टेम्पलेट नहीं';

  @override
  String get templatesEmptyMessage =>
      'टेम्पलेट एक चेकलिस्ट है जिसे आप बार-बार इस्तेमाल करते हैं। इसे दिनचर्या बना दें, तो यह अपने तय समय पर ख़ुद आ जाएगा।';

  @override
  String get templatesStartFromScratch => 'शुरू से बनाएँ';

  @override
  String get templatesRoutines => 'दिनचर्याएँ';

  @override
  String get templatesTemplates => 'टेम्पलेट';

  @override
  String templatesStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चरण',
      one: '1 चरण',
    );
    return '$_temp0';
  }

  @override
  String get worksheetPrintTitle => 'वर्कशीट प्रिंट करें';

  @override
  String get worksheetDaySubtitle =>
      'ज़रूरी काम, आज, इस हफ़्ते, और कुछ लिखने की जगह';

  @override
  String get worksheetWeekSubtitle => 'हर दिन के लिए एक खाना';

  @override
  String get worksheetJobNameDay => 'Clearing – आज';

  @override
  String get worksheetJobNameWeek => 'Clearing – हफ़्ता';

  @override
  String get itemNoLongerExists => 'यह काम अब मौजूद नहीं है।';

  @override
  String get itemWhenNotDecided => 'अभी तय नहीं किया';

  @override
  String itemWhenWaitingOn(String name) {
    return '$name का इंतज़ार';
  }

  @override
  String get itemWhenWaitingOnSomeone => 'किसी का इंतज़ार';

  @override
  String get itemWhenInTrash => 'ट्रैश में';

  @override
  String itemWhenDateAtTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String get itemFutureRepeatsTitle => 'आगे के दोहराव भी बदलें?';

  @override
  String get itemFutureRepeatsBody =>
      'आपने इसे बदला है। आगे के दोहराव पहले जैसे रह सकते हैं, या इस नए रूप से शुरू हो सकते हैं।';

  @override
  String get itemJustThisOne => 'सिर्फ़ यह वाला';

  @override
  String get itemThisAndFuture => 'यह और आगे वाले';

  @override
  String get itemFocusOnThis => 'इस पर फ़ोकस करें';

  @override
  String get itemNotMustDo => 'ज़रूरी नहीं';

  @override
  String get itemMakeMustDo => 'इसे ज़रूरी बनाएँ';

  @override
  String get itemMoveToSomeday => 'किसी दिन में डालें';

  @override
  String get itemSomeoneElseDoingIt => 'कोई और कर रहा है';

  @override
  String get itemUseForFutureRepeats => 'आगे के दोहराव के लिए इस्तेमाल करें';

  @override
  String get itemResumeRepeating => 'फिर से दोहराएँ';

  @override
  String get itemPauseRepeating => 'दोहराना रोकें';

  @override
  String get itemStopRepeating => 'दोहराना बंद करें';

  @override
  String get itemNotDoneYet => 'अभी पूरा नहीं हुआ';

  @override
  String get itemTitleHint => 'शीर्षक';

  @override
  String get itemPlanSection => 'योजना';

  @override
  String get itemWhen => 'कब';

  @override
  String get itemSomeone => 'कोई';

  @override
  String get itemFollowUp => 'फ़ॉलो-अप';

  @override
  String get itemNoDate => 'कोई तारीख़ नहीं';

  @override
  String get itemDoesntRepeat => 'दोहराया नहीं जाता';

  @override
  String itemRepeatPaused(String rule) {
    return '$rule · रुका हुआ';
  }

  @override
  String get itemSeeAllDates => 'सभी तारीख़ें देखें';

  @override
  String get itemDeadline => 'आख़िरी तारीख़';

  @override
  String get itemDeadlineNone =>
      'कोई नहीं — “करने का दिन” वह है जब आप इसे करने की सोचते हैं';

  @override
  String get itemRemoveDeadline => 'आख़िरी तारीख़ हटाएँ';

  @override
  String get itemDetailsSection => 'विवरण';

  @override
  String get itemList => 'सूची';

  @override
  String get itemDoneMeansLabel => 'पूरा होने का मतलब…';

  @override
  String get itemDoneMeansHint => 'पूरा होने पर यह कैसा दिखेगा?';

  @override
  String get itemNotes => 'नोट्स';

  @override
  String get repeatTitle => 'दोहराएँ';

  @override
  String get repeatDaily => 'रोज़';

  @override
  String get repeatWeekly => 'हर हफ़्ते';

  @override
  String get repeatMonthly => 'हर महीने';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count दिन',
      one: 'हर 1 दिन',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count हफ़्ते',
      one: 'हर 1 हफ़्ते',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count महीने',
      one: 'हर 1 महीने',
    );
    return '$_temp0';
  }

  @override
  String get repeatLessOften => 'कम बार';

  @override
  String get repeatMoreSpreadOut => 'ज़्यादा अंतराल';

  @override
  String get repeatAfterCompletionTitle => 'पूरा होने के दिन से गिनें';

  @override
  String get repeatAfterCompletionSubtitle =>
      'जैसे बाल कटवाना: यह वाला पूरा होने पर ही अगला तय होता है';

  @override
  String get repeatOnDay => 'तारीख़';

  @override
  String get repeatOnDayHint => 'छोटे महीनों में आख़िरी दिन';

  @override
  String get repeatStarts => 'शुरू';

  @override
  String get repeatEnds => 'ख़त्म';

  @override
  String get repeatEndsNever => 'कभी नहीं';

  @override
  String get repeatEndsOnDate => 'किसी तारीख़ को';

  @override
  String get repeatEndsAfter => 'इतनी बार के बाद';

  @override
  String repeatLastTimeOn(String date) {
    return 'आख़िरी बार $date को';
  }

  @override
  String repeatTimesInAll(int count) {
    return 'कुल $count बार';
  }

  @override
  String get repeatFewerTimes => 'कम बार';

  @override
  String get repeatMoreTimes => 'ज़्यादा बार';

  @override
  String get repeatIfMissed => 'अगर कोई छूट जाए';

  @override
  String get repeatCarryOver => 'आगे ले जाएँ';

  @override
  String get repeatCarryOverSubtitle =>
      'यह पूरा होने तक आज में रहेगा; अगला इंतज़ार करेगा';

  @override
  String get repeatSkipQuietly => 'चुपचाप छोड़ दें';

  @override
  String get repeatSkipQuietlySubtitle =>
      'दिनचर्या के लिए अच्छा: कल एक नई शुरुआत है';

  @override
  String get seriesCalendarDone => 'हो गया';

  @override
  String get seriesCalendarSkipped => 'छोड़ा गया';

  @override
  String get seriesCalendarOpenNow => 'अभी बाकी';

  @override
  String get seriesCalendarComingUp => 'आने वाला';

  @override
  String get seriesCalendarPreviousMonth => 'पिछला महीना';

  @override
  String get seriesCalendarNextMonth => 'अगला महीना';

  @override
  String get seriesCalendarToday => 'आज';

  @override
  String get reminderWaitingForDate => 'तारीख़ का इंतज़ार';

  @override
  String get reminderRemove => 'रिमाइंडर हटाएँ';

  @override
  String get reminderRemindMe => 'याद दिलाएँ';

  @override
  String get reminderAdd => 'रिमाइंडर जोड़ें';

  @override
  String get reminderSeparateHint => 'करने के दिन से अलग';

  @override
  String reminderCountedFromNine(String offset) {
    return '$offset (9:00 से गिनकर)';
  }

  @override
  String get reminderAtTimeIChoose => 'मेरे चुने समय पर';

  @override
  String get reminderRemindMeOn => 'इस दिन याद दिलाएँ';

  @override
  String get reminderRemindMeAt => 'इस समय याद दिलाएँ';

  @override
  String get reminderOffInSettings => 'सेटिंग्स में रिमाइंडर बंद हैं';

  @override
  String get reminderNotificationsOff =>
      'Clearing के लिए सूचनाएँ बंद हैं, इसलिए यह रिमाइंडर नहीं दिखेगा। आप इन्हें सिस्टम सेटिंग्स में चालू कर सकते हैं।';

  @override
  String get reminderMayBeLate => 'रिमाइंडर कुछ मिनट देर से आ सकते हैं';

  @override
  String get reminderMakeExact => 'सही समय पर करें';

  @override
  String get subtaskAllDone => 'सभी चरण पूरे हुए';

  @override
  String get subtaskCompleteItem => 'काम पूरा करें';

  @override
  String get subtaskSteps => 'चरण';

  @override
  String subtaskProgress(int done, int total) {
    return '$total में से $done';
  }

  @override
  String subtaskRemoveStep(String title) {
    return 'चरण हटाएँ: $title';
  }

  @override
  String get subtaskAddHint => 'चरण जोड़ें';

  @override
  String get whenSheetDoOn => 'करने का दिन';

  @override
  String get whenSheetAddTimeQuestion =>
      'समय भी जोड़ें? ज़्यादातर कामों के लिए ज़रूरी नहीं।';

  @override
  String get whenSheetNoTime => 'समय नहीं';

  @override
  String get whenSheetAddTime => 'समय जोड़ें';

  @override
  String get todayMenuWeeklyReview => 'साप्ताहिक समीक्षा';

  @override
  String get todayMenuOverwhelmReset => 'बोझ हल्का करें';

  @override
  String get todayMenuPrintWorksheet => 'वर्कशीट प्रिंट करें';

  @override
  String todayLeft(int count) {
    return '$count बाकी';
  }

  @override
  String get todayAllClear => 'सब हो गया';

  @override
  String get todayEmptyTitle => 'एक खाली दिन';

  @override
  String get todayEmptyMessage =>
      'मन में जो भी है, लिख लें। उसका क्या करना है, यह बाद में तय कर सकते हैं।';

  @override
  String get todayHowClearingWorks => 'Clearing कैसे काम करता है';

  @override
  String get todayResetOfferTitle => 'बहुत ज़्यादा लग रहा है?';

  @override
  String get todayResetOfferSubtitle => 'पाँच मिनट में इसे एक काम तक छोटा करें';

  @override
  String todayMustDoCount(int count, int cap) {
    return '$cap में से $count';
  }

  @override
  String get todayBlocks => 'समय-खंड';

  @override
  String get todayAlsoToday => 'आज और';

  @override
  String todayShowMore(int count) {
    return '$count और दिखाएँ';
  }

  @override
  String todayCarriedOver(int count) {
    return 'पिछले दिनों से बाकी ($count)';
  }

  @override
  String get todayCarriedOverSubtitle => 'जहाँ छोड़ा था, वहीं से आगे';

  @override
  String get todayHide => 'छिपाएँ';

  @override
  String get todayShow => 'दिखाएँ';

  @override
  String todayThisWeekCount(int count) {
    return 'इस हफ़्ते ($count)';
  }

  @override
  String get thisWeekEmptyTitle => 'इस हफ़्ते के लिए कुछ तय नहीं';

  @override
  String get thisWeekEmptyMessage =>
      'जो काम आप इस हफ़्ते करना चाहते हैं, पर दिन तय नहीं किया, वे यहाँ जमा होते हैं और आज में एक शांत पंक्ति में दिखते हैं।';

  @override
  String get thisWeekDoToday => 'आज करें';

  @override
  String inboxToDecide(int count) {
    return '$count तय करने हैं · किसी पर टैप करें, या शॉर्टकट के लिए स्वाइप करें';
  }

  @override
  String inboxReviewEstimate(int count) {
    return 'इनबॉक्स: $count — समीक्षा में लगभग 15 मिनट लगते हैं';
  }

  @override
  String get inboxReviewSubtitle => 'हर काम को उसकी जगह मिलती है';

  @override
  String get inboxStartReview => 'समीक्षा शुरू करें';

  @override
  String get inboxSwipePickDate => 'तारीख़ चुनें';

  @override
  String get inboxEmptyTitle => 'इनबॉक्स खाली है';

  @override
  String get inboxEmptyMessage =>
      'आप जो भी लिखते हैं, वह यहाँ आता है, जब तक आप तय न करें कि उसका क्या करना है।';

  @override
  String get itemTileRepeats => 'दोहराता है';

  @override
  String itemTileWaitingOn(String name) {
    return '$name का इंतज़ार';
  }

  @override
  String itemTileFollowUp(String date) {
    return '$date को फ़ॉलो-अप';
  }

  @override
  String itemTileDeadline(String date) {
    return 'आख़िरी तारीख़ $date';
  }

  @override
  String itemTileProgress(int done, int total) {
    return '$total में से $done';
  }

  @override
  String get itemTileMarkDone => 'हो गया मार्क करें';

  @override
  String get itemTileMarkNotDone => 'अधूरा मार्क करें';

  @override
  String get itemTileFromLastWeek => 'पिछले हफ़्ते से';

  @override
  String itemTileFromDay(String day) {
    return '$day से';
  }

  @override
  String itemTileDayTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get itemTileNotMustDo => 'ज़रूरी से हटाएँ';

  @override
  String get itemTileMakeMustDo => 'इसे ज़रूरी बनाएँ';

  @override
  String get itemTileTomorrow => 'कल';

  @override
  String get itemTileFocusOnThis => 'इस पर फ़ोकस करें';

  @override
  String get itemTileReschedule => 'समय बदलें…';

  @override
  String get itemTileBreakIntoSteps => 'चरणों में बाँटें';

  @override
  String get itemTileMoveToSomeday => 'किसी दिन में भेजें';

  @override
  String get listsSubtitle => 'संदर्भ, विचार, और जो हो गया';

  @override
  String get listsNewList => 'नई सूची';

  @override
  String get listsRoutinesTitle => 'दिनचर्या और टेम्पलेट';

  @override
  String get listsRoutinesSubtitle =>
      'चेकलिस्ट जो आप बार-बार इस्तेमाल करते हैं';

  @override
  String get listsNotNow => 'अभी नहीं';

  @override
  String get listsSomedaySubtitle => 'विचार, वादे नहीं';

  @override
  String get listsDoneTitle => 'पूरे हुए';

  @override
  String get listsDoneSubtitle => 'हाल में पूरे हुए और आर्काइव';

  @override
  String get listsTrashTitle => 'ट्रैश';

  @override
  String get listsTrashSubtitle => '30 दिन तक रखे जाते हैं';

  @override
  String listsHiddenLists(int count) {
    return 'छिपी सूचियाँ ($count)';
  }

  @override
  String get listsRename => 'नाम बदलें';

  @override
  String get listsRenameList => 'सूची का नाम बदलें';

  @override
  String get listsShow => 'दिखाएँ';

  @override
  String get listsHide => 'छिपाएँ';

  @override
  String get listsDeleteList => 'सूची हटाएँ';

  @override
  String get listsDeleteListSubtitle =>
      'इसके काम बने रहेंगे, बस किसी सूची में नहीं होंगे';

  @override
  String get listSectionToDo => 'करना है';

  @override
  String get listSectionNotDecided => 'अभी तय नहीं';

  @override
  String listBlockEvery(String weekday, String time) {
    return 'हर $weekday को $time बजे';
  }

  @override
  String listBlockOn(String date, String time) {
    return '$date को $time बजे';
  }

  @override
  String get listBlockSubtitle => 'आज में एक ही पंक्ति में दिखता है';

  @override
  String get listRemoveBlock => 'समय-खंड हटाएँ';

  @override
  String get listBlockOutTime => 'समय तय करें';

  @override
  String listAddTo(String name) {
    return '$name में जोड़ें';
  }

  @override
  String get listAddToList => 'सूची में जोड़ें';

  @override
  String listEmptyTitle(String name) {
    return '$name में कुछ नहीं';
  }

  @override
  String get listEmptyTitleThisList => 'इस सूची में कुछ नहीं';

  @override
  String get listEmptyMessage =>
      'जो काम साथ में होते हैं, उन्हें यहाँ जोड़ें, जैसे एक ही बार में निपटाने वाले बाहर के काम।';

  @override
  String get trashTitle => 'ट्रैश';

  @override
  String get trashDeleteForever => 'हमेशा के लिए हटाएँ';

  @override
  String get trashEmptyConfirmTitle => 'ट्रैश खाली करें?';

  @override
  String trashEmptyConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count काम हमेशा के लिए हट जाएँगे। इन्हें वापस नहीं लाया जा सकेगा।',
      one: '1 काम हमेशा के लिए हट जाएगा। इसे वापस नहीं लाया जा सकेगा।',
    );
    return '$_temp0';
  }

  @override
  String get trashEmpty => 'खाली करें';

  @override
  String get trashEmptyTitle => 'ट्रैश खाली है';

  @override
  String get trashEmptyMessage =>
      'हटाए गए काम 30 दिन तक यहाँ रहते हैं, ताकि ज़रूरत हो तो वापस ला सकें।';

  @override
  String get trashPurgeTomorrow => 'कल हमेशा के लिए हट जाएगा';

  @override
  String trashPurgeInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन में हमेशा के लिए हट जाएगा',
      one: '1 दिन में हमेशा के लिए हट जाएगा',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'वापस लाएँ';

  @override
  String get trashDeleteForeverConfirmTitle => 'हमेशा के लिए हटाएँ?';

  @override
  String trashDeleteForeverConfirmBody(String title) {
    return '“$title” हमेशा के लिए हट जाएगा।';
  }

  @override
  String get archiveTitle => 'पूरे हुए';

  @override
  String get archiveEmptyTitle => 'अभी तक कुछ पूरा नहीं हुआ';

  @override
  String get archiveEmptyMessage =>
      'पूरे हुए काम यहाँ रहते हैं, और खोज में भी मिलते हैं।';

  @override
  String get archiveRecentlyDone => 'हाल में पूरे हुए';

  @override
  String archiveArchivedAfter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन बाद आर्काइव',
      one: '1 दिन बाद आर्काइव',
    );
    return '$_temp0';
  }

  @override
  String get archiveSection => 'आर्काइव';

  @override
  String get somedayEmptyTitle => 'यहाँ कोई विचार नहीं रखा';

  @override
  String get somedayEmptyMessage =>
      'जो काम आप शायद किसी दिन करें, बिना किसी दबाव के।';

  @override
  String get somedayMakePlan => 'इसकी योजना बनाएँ';

  @override
  String get somedayWhenTitle => 'आप इसे कब करेंगे?';

  @override
  String get settingsMustDoPerDay => 'हर दिन के ज़रूरी काम';

  @override
  String get settingsMustDoPerDayHint =>
      'इसे कम रखने से आज के काम पूरे हो पाते हैं';

  @override
  String get settingsWeekStartsOn => 'हफ़्ता शुरू होता है';

  @override
  String get settingsWeekStartsOnHint => '“इस हफ़्ते” और दिन चुनने के लिए';

  @override
  String get settingsInboxBadge => 'इनबॉक्स टैब पर गिनती दिखाएँ';

  @override
  String get settingsStarterSuggestionsHint =>
      'लिखते समय और खाली इनबॉक्स में जल्दी जोड़ने के सुझाव';

  @override
  String get settingsEditSuggestions => 'सुझाव बदलें';

  @override
  String get settingsRemindersSection => 'रिमाइंडर';

  @override
  String get settingsIntensityOff => 'बंद';

  @override
  String get settingsIntensityGentle => 'हल्के';

  @override
  String get settingsIntensityStandard => 'सामान्य';

  @override
  String get settingsIntensityOffHint => 'कोई नोटिफ़िकेशन नहीं।';

  @override
  String get settingsIntensityGentleHint =>
      'सिर्फ़ आपके लगाए रिमाइंडर, बिना आवाज़ या वाइब्रेशन के।';

  @override
  String get settingsIntensityStandardHint =>
      'सिर्फ़ आपके लगाए रिमाइंडर, आवाज़ के साथ।';

  @override
  String get settingsQuietHours => 'शांत समय';

  @override
  String settingsQuietHoursRange(String start, String end) {
    return '$start – $end. पहले से आने वाले रिमाइंडर सुबह तक रुकेंगे; जिनका समय आपने ठीक तय किया है, वे फिर भी आएँगे।';
  }

  @override
  String get settingsQuietFrom => 'शांत समय शुरू';

  @override
  String get settingsQuietUntil => 'शांत समय खत्म';

  @override
  String get settingsMorningSummary => 'सुबह का सारांश';

  @override
  String settingsMorningSummaryOn(String time) {
    return 'आज के ज़रूरी काम $time बजे। खाली दिन पर कुछ नहीं।';
  }

  @override
  String get settingsMorningSummaryOff =>
      'हर सुबह आज के ज़रूरी कामों का एक नोट';

  @override
  String get settingsSummaryTime => 'सारांश का समय';

  @override
  String get settingsRemindersNotArriving => 'रिमाइंडर नहीं आ रहे?';

  @override
  String get settingsWeeklyReviewSection => 'साप्ताहिक समीक्षा';

  @override
  String get settingsRemindReview => 'समीक्षा के लिए याद दिलाएँ';

  @override
  String get settingsRemindReviewHint => 'लगभग 15 मिनट, हफ़्ते में एक बार';

  @override
  String get settingsReviewDay => 'समीक्षा का दिन';

  @override
  String get settingsReviewTime => 'समीक्षा का समय';

  @override
  String get settingsDoneSection => 'पूरे हुए काम';

  @override
  String get settingsAutoArchive => 'पूरे हुए काम आर्काइव में भेजें';

  @override
  String get settingsAutoArchiveHint => 'वहाँ भी खोज सकते हैं';

  @override
  String get settingsArchiveAfterDay => 'एक दिन बाद';

  @override
  String get settingsArchiveAfterWeek => 'एक हफ़्ते बाद';

  @override
  String get settingsArchiveAfterMonth => 'एक महीने बाद';

  @override
  String get settingsArchiveNever => 'कभी नहीं';

  @override
  String settingsArchiveAfterDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन बाद',
      one: '1 दिन बाद',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataSection => 'आपका डेटा';

  @override
  String get settingsBackupHint => 'कॉपी एक्सपोर्ट करें, या रीस्टोर करें';

  @override
  String get settingsAppearanceSection => 'दिखावट';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsThemeLight => 'लाइट';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsHelpSection => 'मदद';

  @override
  String get settingsFaq => 'सवाल और जवाब';

  @override
  String get settingsFaqHint => 'बैकअप, नया फ़ोन, वापस लेना और बहुत कुछ';

  @override
  String get settingsAbout => 'जानकारी और सुझाव';

  @override
  String get settingsNotificationsBlocked => 'नोटिफ़िकेशन बंद हैं';

  @override
  String get settingsNotificationsBlockedHint =>
      'Clearing के लिए इन्हें चालू करने के लिए टैप करें';

  @override
  String get settingsExactTiming => 'ठीक समय पर';

  @override
  String get settingsExactTimingOn => 'रिमाइंडर ठीक समय पर आते हैं';

  @override
  String get settingsExactTimingOff =>
      'बंद: रिमाइंडर कुछ मिनट देर से आ सकते हैं। ठीक समय के लिए टैप करें।';

  @override
  String get backupTitle => 'बैकअप';

  @override
  String get backupSaved => 'बैकअप सेव हो गया';

  @override
  String backupExportFailed(String error) {
    return 'एक्सपोर्ट नहीं हो पाया: $error';
  }

  @override
  String get backupIntro =>
      'सब कुछ इसी फ़ोन पर रहता है, बिना अकाउंट और बिना क्लाउड के। Clearing हटाने या फ़ोन खोने पर आपका डेटा मिट जाएगा, जब तक आपने कॉपी एक्सपोर्ट न की हो।';

  @override
  String get backupLast => 'पिछला बैकअप';

  @override
  String get backupNever => 'कभी नहीं';

  @override
  String get backupExportSection => 'एक्सपोर्ट';

  @override
  String get backupShare => 'बैकअप शेयर करें';

  @override
  String get backupShareHint => 'ईमेल, Drive या किसी दूसरे ऐप पर भेजें';

  @override
  String get backupSaveToFolder => 'किसी फ़ोल्डर में सेव करें';

  @override
  String get backupRemindExport => 'एक्सपोर्ट के लिए याद दिलाएँ';

  @override
  String get backupEveryTwoWeeks => 'हर 2 हफ़्ते';

  @override
  String get backupMonthly => 'हर महीने';

  @override
  String backupEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count दिन',
      one: 'हर दिन',
    );
    return '$_temp0';
  }

  @override
  String get backupRestoreSection => 'रीस्टोर';

  @override
  String get backupRestoreFrom => 'बैकअप से रीस्टोर करें';

  @override
  String get backupRestoreFromHint =>
      'कुछ भी बदलने से पहले आप देख पाएँगे कि उसमें क्या है';

  @override
  String get backupCantRestore => 'यह फ़ाइल रीस्टोर नहीं हो सकती';

  @override
  String get backupReplaceAllTitle => 'सब कुछ बदल दें?';

  @override
  String get backupReplaceAllBody =>
      'इस फ़ोन पर Clearing में जो कुछ अभी है, उसकी जगह बैकअप आ जाएगा। इसे वापस नहीं लिया जा सकता।';

  @override
  String get backupReplace => 'बदलें';

  @override
  String get backupRestored => 'बैकअप रीस्टोर हो गया';

  @override
  String get backupRestoreThis => 'यह बैकअप रीस्टोर करें?';

  @override
  String backupFromDate(String date) {
    return '$date का बैकअप';
  }

  @override
  String backupPreviewItems(int count, int open, int someday, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count काम',
      one: '1 काम',
    );
    return '$_temp0: $open बाकी, $someday किसी दिन, $done पूरे हुए';
  }

  @override
  String backupPreviewLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सूचियाँ',
      one: '1 सूची',
    );
    return '$_temp0';
  }

  @override
  String backupPreviewRepeating(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दोहराए जाने वाले काम',
      one: '1 दोहराया जाने वाला काम',
    );
    return '$_temp0';
  }

  @override
  String get backupMergeExplain =>
      'मिलाएँ से जो नहीं है वह जुड़ जाता है, और दोनों में मौजूद चीज़ों की नई कॉपी रहती है। बदलें से यह फ़ोन बिल्कुल बैकअप जैसा हो जाता है।';

  @override
  String get backupMerge => 'मिलाएँ';

  @override
  String get aboutTitle => 'जानकारी';

  @override
  String get aboutTagline => 'मन के खुले टैब बंद करें।';

  @override
  String aboutVersion(String version) {
    return 'वर्शन $version';
  }

  @override
  String get aboutPrivacySection => 'आपकी प्राइवेसी';

  @override
  String get aboutPrivacy =>
      'न अकाउंट, न सर्वर, न एनालिटिक्स, न विज्ञापन। Clearing इंटरनेट से जुड़ ही नहीं सकता: आप जो भी लिखते हैं, वह इसी फ़ोन पर रहता है, जब तक आप खुद उसे एक्सपोर्ट न करें।';

  @override
  String get aboutBetaSection => 'बीटा';

  @override
  String get aboutSendFeedback => 'सुझाव भेजें';

  @override
  String get aboutSendFeedbackHint =>
      'आपका ईमेल या मैसेजिंग ऐप एक छोटे टेम्पलेट के साथ खुलेगा';

  @override
  String get aboutFeedbackSubject => 'Clearing के लिए सुझाव';

  @override
  String get aboutFeedbackWhatHappened => 'क्या हुआ:';

  @override
  String get aboutFeedbackExpected => 'मुझे क्या उम्मीद थी:';

  @override
  String get aboutFeedbackElse => 'और कुछ:';

  @override
  String aboutSendWithErrorLog(int count) {
    return 'एरर लॉग के साथ सुझाव भेजें ($count)';
  }

  @override
  String get aboutErrorLogHint =>
      'एरर के प्रकार और वे कहाँ हुए; भेजने से पहले आप सब देख पाएँगे';

  @override
  String get aboutErrorLogHeader => '--- एरर लॉग ---';

  @override
  String get aboutClearErrorLog => 'एरर लॉग साफ़ करें';

  @override
  String get aboutSourceCode => 'सोर्स कोड';

  @override
  String aboutSourceSubtitle(String url) {
    return '$url · MIT लाइसेंस';
  }

  @override
  String get aboutLicences => 'ओपन-सोर्स लाइसेंस';

  @override
  String get suggestionsTitle => 'शुरुआती सुझाव';

  @override
  String get suggestionsAdd => 'जोड़ें';

  @override
  String get suggestionsYours => 'आपका';

  @override
  String get suggestionsEdit => 'बदलें';

  @override
  String get suggestionsNew => 'नया सुझाव';

  @override
  String get suggestionsEditTitle => 'सुझाव बदलें';

  @override
  String get introTitle => 'Clearing कैसे काम करता है';

  @override
  String get introCaptureTitle => 'लिख लें';

  @override
  String get introCaptureBody =>
      'कोई बात मन में आते ही उसे लिख लें। एक लाइन काफ़ी है: वह इनबॉक्स में तब तक रहेगी जब तक आपके पास एक मिनट न हो।';

  @override
  String get introDecideTitle => 'तय करें कि इसका क्या करना है';

  @override
  String get introDecideBody =>
      'बाद में हर एक को जगह दें: आज, इस हफ़्ते, कोई तारीख़, कोई और व्यक्ति, या किसी दिन, अगर यह बस एक विचार है।';

  @override
  String get introPlanTitle => 'कम योजना, अक्सर पूरा करें';

  @override
  String get introPlanBody =>
      'आज में बस कुछ ज़रूरी काम रखें, और हफ़्ते में एक बार समीक्षा करें ताकि कुछ न छूटे। छूटे हुए काम आगे बढ़ जाते हैं, इसके लिए आपको कोई दोष नहीं।';

  @override
  String introCardPosition(int index, int total) {
    return '$total में से कार्ड $index';
  }

  @override
  String get introGetStarted => 'शुरू करें';

  @override
  String get searchStatusOpen => 'खुले';

  @override
  String get searchPlannedBetween => 'इनके बीच तय किए गए';

  @override
  String get searchHint => 'शीर्षक, नोट्स और चरण खोजें';

  @override
  String get searchClear => 'मिटाएँ';

  @override
  String get searchAnyList => 'कोई भी सूची';

  @override
  String searchDateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get searchAnyDate => 'कोई भी तारीख़';

  @override
  String get searchRepeating => 'दोहराने वाले';

  @override
  String get searchNoMatchesTitle => 'कुछ नहीं मिला';

  @override
  String get searchNoMatchesMessage =>
      'कम शब्दों से खोजें, या फ़िल्टर थोड़े ढीले करें।';

  @override
  String get upcomingSubtitleWeek => 'एक बार में एक हफ़्ता';

  @override
  String get upcomingSubtitleAgenda => 'अगले 30 दिन';

  @override
  String get upcomingAgenda => 'सूची के रूप में देखें';

  @override
  String get upcomingWeekView => 'हफ़्ते के रूप में देखें';

  @override
  String get upcomingEmptyTitle => 'कुछ तय नहीं है';

  @override
  String get upcomingEmptyMessage =>
      'अगले 30 दिनों में तारीख़ वाले काम यहाँ दिखेंगे।';

  @override
  String get weekPrevious => 'पिछला हफ़्ता';

  @override
  String get weekNext => 'अगला हफ़्ता';

  @override
  String weekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get weekAnyDay => 'इस हफ़्ते किसी भी दिन';

  @override
  String get weekNothingLeft => 'कुछ बाकी नहीं';

  @override
  String get weekFree => 'खाली';

  @override
  String blockTileTitle(String list, String time) {
    return '$list · $time';
  }

  @override
  String get blockAllDone => 'सब हो गया';

  @override
  String blockToDo(int count) {
    return '$count काम, एक साथ';
  }

  @override
  String get blockDialogTitle => 'समय तय करें';

  @override
  String get blockDialogMessage => 'पूरी सूची एक साथ निपटाएँ।';

  @override
  String get blockEveryWeek => 'हर हफ़्ते';

  @override
  String get blockOnce => 'एक बार';

  @override
  String blockAtTime(String time) {
    return '$time बजे';
  }

  @override
  String captureSavedAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count काम सेव हो गए',
      one: 'सेव हो गया',
    );
    return '$_temp0';
  }

  @override
  String get captureHint => 'आपके मन में क्या है?';

  @override
  String get captureHelper =>
      'इनबॉक्स में सेव होगा। इसका क्या करना है, बाद में तय करें।';

  @override
  String captureHelperInList(String list) {
    return 'इनबॉक्स में, $list सूची में सेव होगा।';
  }

  @override
  String captureSavedCount(int count) {
    return '$count इनबॉक्स में सेव हुए';
  }

  @override
  String get commandsTrashed => 'ट्रैश में डाल दिया';

  @override
  String get commandsSomeday => 'किसी दिन में एक विचार के रूप में रखा';

  @override
  String get commandsSnoozed => 'कल पर डाल दिया';

  @override
  String get commandsRescheduled => 'नई तारीख़ तय हो गई';

  @override
  String commandsMustDoCapTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपके पास पहले से $count ज़रूरी काम हैं',
      one: 'आपके पास पहले से 1 ज़रूरी काम है',
    );
    return '$_temp0';
  }

  @override
  String get commandsMustDoSwapPrompt => 'जगह बनाने के लिए किसी एक को हटाएँ?';

  @override
  String get commandsMustDoKeep => 'जैसा है वैसा रहने दें';

  @override
  String shellInboxTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इनबॉक्स, $count काम',
      one: 'इनबॉक्स, 1 काम',
    );
    return '$_temp0';
  }

  @override
  String get shellCapture => 'लिखें';

  @override
  String stepTrailLabel(int current, int count) {
    return '$count में से चरण $current';
  }

  @override
  String get settingsTodayHint => 'आज आपसे कितना माँगता है।';

  @override
  String get settingsInboxHint => 'जहाँ नए विचार फ़ैसले का इंतज़ार करते हैं।';

  @override
  String get settingsRemindersHint =>
      'Clearing आपको कब और कैसे सूचना दे सकता है।';

  @override
  String get settingsWeeklyReviewHint =>
      'अपने हफ़्ते पर एक नज़र डालने की हल्की-सी याद।';

  @override
  String get settingsDoneHint => 'पूरे हुए काम कहाँ जाते हैं।';

  @override
  String get settingsDataHint =>
      'जब तक आप एक्सपोर्ट न करें, यह इसी फ़ोन पर रहता है।';

  @override
  String get settingsAppearanceHint => 'हल्का, गहरा, या फ़ोन के अनुसार।';

  @override
  String get settingsHelpHint => 'जवाब, और Clearing कैसे काम करता है।';

  @override
  String get welcomeTitle => 'मन के खुले टैब बंद करें।';

  @override
  String get welcomeBody =>
      'Clearing आपके मन की हर बात के लिए एक शांत जगह है, ताकि आपको सब कुछ याद रखने का बोझ न उठाना पड़े।';

  @override
  String get welcomeShowMe => 'मुझे दिखाएँ';

  @override
  String get welcomeSkip => 'टूर छोड़ें';

  @override
  String get welcomeCaptureTitle => 'लिख लें';

  @override
  String get welcomeCaptureBody =>
      'जैसे ही कुछ याद आए, + दबाएँ और एक लाइन लिख दें। यह इनबॉक्स में तब तक रहेगा जब तक आपके पास एक मिनट न हो।';

  @override
  String get welcomeDecideTitle => 'तय करें कि इसका क्या करना है';

  @override
  String get welcomeDecideBody =>
      'बाद में हर बात को जगह दें: आज, इस हफ़्ते, कोई तारीख़, किसी और का काम, या किसी दिन, अगर यह बस एक विचार है।';

  @override
  String get welcomeTodayTitle => 'आज को छोटा रखें';

  @override
  String get welcomeTodayBody =>
      'ज़्यादा से ज़्यादा तीन ज़रूरी काम चुनें। छूटे काम आगे ले जाए जाते हैं, कभी लाल नहीं दिखते, कभी आपके ख़िलाफ़ नहीं गिने जाते।';

  @override
  String get welcomeReviewTitle => 'हफ़्ते में एक बार पीछे देखें';

  @override
  String get welcomeReviewBody =>
      '15 मिनट की साप्ताहिक समीक्षा मन हल्का करती है और हफ़्ते की योजना बनाती है, ताकि कुछ न छूटे।';

  @override
  String get welcomePrivateTitle => 'शुरू से ही निजी';

  @override
  String get welcomePrivateBody =>
      'न खाता, न विज्ञापन, न इंटरनेट। सब कुछ इसी फ़ोन पर रहता है, और आप कभी भी बैकअप एक्सपोर्ट कर सकते हैं।';

  @override
  String get welcomeSetupTitle => 'इसे अपने हिसाब से बनाएँ';

  @override
  String get welcomeSetupHint => 'यह सब आप बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get welcomeSetupMustDo => 'हर दिन ज़रूरी काम';

  @override
  String get welcomeSetupMustDoHint =>
      'कम हों तो मन शांत रहता है। तीन से शुरुआत अच्छी है।';

  @override
  String get welcomeSetupWeek => 'आपका हफ़्ता शुरू होता है';

  @override
  String get welcomeSetupReminders => 'रिमाइंडर';

  @override
  String get welcomeSetupReview => 'साप्ताहिक समीक्षा की याद दिलाएँ';

  @override
  String welcomeSetupReviewWhen(String day, String time) {
    return '$day, $time बजे';
  }

  @override
  String get welcomeSetupDone => 'Clearing शुरू करें';

  @override
  String get welcomeReadyTitle => 'सब तैयार है';

  @override
  String get welcomeReadyBody =>
      'सुझाव: होम स्क्रीन पर आज और झटपट लिखें विजेट जोड़ें। होम स्क्रीन को दबाकर रखें, फिर विजेट › Clearing।';

  @override
  String get welcomeCaptureFirst => 'पहली बात लिखें';

  @override
  String get welcomeGoToday => 'आज पर जाएँ';

  @override
  String welcomePageLabel(int page, int total) {
    return 'पेज $page / $total';
  }

  @override
  String get welcomeTourTitle => 'Clearing कैसे काम करता है';

  @override
  String get tipLabel => 'सुझाव';

  @override
  String get tipGotIt => 'समझ गया';

  @override
  String get tipTodayRing =>
      'कोई काम हो जाए तो गोले पर टैप करें। और विकल्पों के लिए किसी भी काम को दबाकर रखें।';

  @override
  String get tipInboxSwipe =>
      'दाएँ स्वाइप करें: आज या इस हफ़्ते के लिए। बाएँ स्वाइप करें: तारीख़ चुनें, किसी दिन के लिए रखें, या हटाएँ। या टैप करके एक-एक कदम में तय करें।';

  @override
  String get tipUpcomingWeek =>
      'ऊपर हफ़्ते वाले आइकन से पूरा हफ़्ता एक साथ देखें।';

  @override
  String get tipListsBlock =>
      'कोई सूची खोलें और कैलेंडर आइकन टैप करके उसके लिए समय तय करें, जैसे “बाहर के काम, शनिवार 10:00”।';

  @override
  String get tipItemFocus =>
      'अटक गए? ऊपर फ़ोकस आइकन टैप करें और सिर्फ़ यही काम देखें।';

  @override
  String get tipCaptureBurst =>
      'हर बात के बाद Enter दबाएँ: अगली बात के लिए जगह खुली रहती है।';

  @override
  String get settingsShowTips => 'चलते-चलते सुझाव दिखाएँ';

  @override
  String get settingsShowTipsHint => 'हर स्क्रीन पर पहली बार छोटे संकेत';

  @override
  String get settingsResetTips => 'सारे सुझाव फिर से दिखाएँ';

  @override
  String get settingsTipsReset => 'सुझाव फिर से दिखेंगे';

  @override
  String get settingsReplayWelcome => 'स्वागत फिर से देखें';

  @override
  String get settingsReplayWelcomeHint => 'टूर, और ज़रूरी चीज़ें सेट करना';

  @override
  String get helpTitle => 'मदद और गाइड';

  @override
  String get helpSubtitle => 'गाइड, सवाल और जवाब';

  @override
  String get helpGetStarted => 'शुरुआत';

  @override
  String get helpGuides => 'गाइड';

  @override
  String get helpMore => 'और मदद';

  @override
  String get helpTourHint => 'पाँच छोटे पेज';

  @override
  String get guideCaptureTitle => 'विचार लिख लेना';

  @override
  String get guideCaptureLead => 'पहले दिमाग़ से बाहर निकालें; फ़ैसला बाद में।';

  @override
  String get guideCapture1Title => 'कहीं से भी + दबाएँ';

  @override
  String get guideCapture1Body =>
      'लिखने का बटन हर टैब पर है। एक लाइन लिखें और Enter दबाएँ; अगली बात के लिए जगह खुली रहती है।';

  @override
  String get guideCapture2Title => 'एक साथ सब चिपकाएँ';

  @override
  String get guideCapture2Body =>
      'एक साथ कई लाइनें चिपकाएँ, हर लाइन अलग काम बन जाएगी।';

  @override
  String get guideCapture3Title => 'दूसरे ऐप से शेयर करें';

  @override
  String get guideCapture3Body =>
      'किसी मैसेज या वेब पेज का टेक्स्ट Clearing में शेयर करके लिख लें।';

  @override
  String get guideCapture4Title => 'होम स्क्रीन से';

  @override
  String get guideCapture4Body =>
      'झटपट लिखें विजेट जोड़ें: होम स्क्रीन को दबाकर रखें, फिर विजेट › Clearing।';

  @override
  String get guideDecideTitle => 'तय करना कि क्या करना है';

  @override
  String get guideDecideLead =>
      'इनबॉक्स की हर बात को कुछ टैप में जगह मिलती है।';

  @override
  String get guideDecide1Title => 'एक-एक कदम में स्पष्ट करें';

  @override
  String get guideDecide1Body =>
      'इनबॉक्स के किसी काम पर टैप करें। Clearing पूछता है: क्या कुछ करना है, अगला कदम क्या है, क्या कोई और कर रहा है, और कब?';

  @override
  String get guideDecide2Title => 'स्वाइप के शॉर्टकट';

  @override
  String get guideDecide2Body =>
      'दाएँ स्वाइप: आज या इस हफ़्ते। बाएँ स्वाइप: तारीख़ चुनें, किसी दिन के लिए रखें, या हटाएँ।';

  @override
  String get guideDecide3Title => 'पूरा होने का मतलब…';

  @override
  String get guideDecide3Body =>
      'जो काम धुंधला लगे, उसमें लिखें कि पूरा होना कैसा दिखेगा, और उसे चरणों में बाँटें।';

  @override
  String get guideDecide4Title => 'किसी के इंतज़ार में';

  @override
  String get guideDecide4Body =>
      'अगर कोई और कर रहा है, तो लिखें कौन, और कब पूछना है।';

  @override
  String get guideTodayTitle => 'आज और ज़रूरी काम';

  @override
  String get guideTodayLead =>
      'आज वही दिखाता है जो आपने आज के लिए तय किया, और उसे छोटा रखता है।';

  @override
  String get guideToday1Title => 'ज़रूरी काम';

  @override
  String get guideToday1Body =>
      'ज़्यादा से ज़्यादा तीन सच में ज़रूरी कामों पर स्टार लगाएँ। बाकी सब नीचे दिखता रहता है।';

  @override
  String get guideToday2Title => 'पिछले दिनों से बाकी';

  @override
  String get guideToday2Body =>
      'पिछले दिनों के काम नीचे चुपचाप इंतज़ार करते हैं। कुछ भी लाल नहीं होता।';

  @override
  String get guideToday3Title => 'इस हफ़्ते';

  @override
  String get guideToday3Body =>
      'इस हफ़्ते के काम, बिना किसी दिन के, एक ही पंक्ति में रहते हैं।';

  @override
  String get guideToday4Title => 'हो गया, और वापस लेना';

  @override
  String get guideToday4Body =>
      'हो जाने पर गोले पर टैप करें। मन बदल गया? वापस लें दबाएँ, या सूचियाँ › पूरे हुए में टिक हटाएँ।';

  @override
  String get guideTimeTitle => 'तारीख़ें, रिमाइंडर और दोहराना';

  @override
  String get guideTimeLead =>
      'कब करेंगे, कब तक करना है, और कब याद दिलाना है, ये तीन अलग बातें हैं।';

  @override
  String get guideTime1Title => 'कब करें, आख़िरी तारीख़, याद दिलाएँ';

  @override
  String get guideTime1Body =>
      '“कब” वह दिन है जब आप करने वाले हैं। आख़िरी तारीख़ वह है जब तक करना है। रिमाइंडर एक सूचना है; तीन तक लगा सकते हैं।';

  @override
  String get guideTime2Title => 'दोहराना';

  @override
  String get guideTime2Body =>
      'हर दिन, हर हफ़्ते, हर महीने, या पूरा करने के बाद से गिनकर (जैसे बाल कटवाना)। छूटे हुए दोहराव कभी जमा नहीं होते।';

  @override
  String get guideTime3Title => 'शांत समय';

  @override
  String get guideTime3Body =>
      'पहले वाले रिमाइंडर सुबह तक रुकते हैं; जिनका समय आपने ख़ुद तय किया, वे समय पर आते हैं।';

  @override
  String get guideTime4Title => 'सुबह का सार';

  @override
  String get guideTime4Body =>
      'सेटिंग्स › रिमाइंडर में हर सुबह आज के ज़रूरी कामों की एक सूचना चालू करें।';

  @override
  String get guideReviewTitle => 'समीक्षा और मन हल्का करना';

  @override
  String get guideReviewLead => 'दो छोटी आदतें जो मन को साफ़ रखती हैं।';

  @override
  String get guideReview1Title => 'साप्ताहिक समीक्षा';

  @override
  String get guideReview1Body =>
      'लगभग 15 मिनट: मन ख़ाली करें, इनबॉक्स सँभालें, पिछले हफ़्ते को देखें और अगले की तैयारी करें।';

  @override
  String get guideReview2Title => 'बोझ हल्का करें';

  @override
  String get guideReview2Body =>
      'जब सब बहुत ज़्यादा लगे, पाँच छोटे कदम सब कुछ एक काम तक ले आते हैं।';

  @override
  String get guideReview3Title => 'फ़ोकस';

  @override
  String get guideReview3Body =>
      'सिर्फ़ एक काम दिखाता है, और कुछ नहीं, जब तक वह पूरा न हो।';

  @override
  String get guideReview4Title => 'वर्कशीट प्रिंट करें';

  @override
  String get guideReview4Body =>
      'आज या इस हफ़्ते को एक पेज पर प्रिंट करें, लिखने की जगह के साथ।';

  @override
  String get guideOrganizeTitle => 'सूचियाँ, समय-खंड और टेम्पलेट';

  @override
  String get guideOrganizeLead =>
      'कामों को जगह के हिसाब से रखें, और बार-बार होने वाले काम दोबारा इस्तेमाल करें।';

  @override
  String get guideOrganize1Title => 'सूचियाँ';

  @override
  String get guideOrganize1Body =>
      'ज़िंदगी के काम, बाहर के काम, और आपकी अपनी सूचियाँ। कोई काम सूची में भी हो सकता है और किसी दिन के लिए तय भी।';

  @override
  String get guideOrganize2Title => 'समय-खंड';

  @override
  String get guideOrganize2Body =>
      'पूरी सूची के लिए समय तय करें, जैसे शनिवार सुबह बाहर के काम, और वह आज में एक ही पंक्ति में दिखेगा।';

  @override
  String get guideOrganize3Title => 'टेम्पलेट और दिनचर्या';

  @override
  String get guideOrganize3Body =>
      'बार-बार काम आने वाली चेकलिस्ट सहेजें। किसी को दिनचर्या बनाएँ, वह अपने समय पर आ जाएगी।';

  @override
  String get guideOrganize4Title => 'खोजें';

  @override
  String get guideOrganize4Body =>
      'खोज आइकन से कुछ भी ढूँढें, पूरे हुए काम भी।';

  @override
  String get guideDataTitle => 'आपका डेटा और निजता';

  @override
  String get guideDataLead => 'Clearing सब कुछ इसी फ़ोन पर रखता है।';

  @override
  String get guideData1Title => 'न खाता, न इंटरनेट';

  @override
  String get guideData1Body =>
      'न कोई सर्वर, न कोई ट्रैकिंग; यह ऐप इंटरनेट से जुड़ ही नहीं सकता।';

  @override
  String get guideData2Title => 'बैकअप';

  @override
  String get guideData2Body =>
      'सेटिंग्स › बैकअप में एक कॉपी एक्सपोर्ट करें, और किसी भी फ़ोन पर रीस्टोर करें।';

  @override
  String get guideData3Title => 'नया फ़ोन';

  @override
  String get guideData3Body =>
      'Android का फ़ोन-से-फ़ोन ट्रांसफ़र Clearing का डेटा साथ ले आता है, या बैकअप का इस्तेमाल करें।';

  @override
  String get guideData4Title => 'ट्रैश और आर्काइव';

  @override
  String get guideData4Body =>
      'हटाए गए काम 30 दिन ट्रैश में रहते हैं; पूरे हुए काम आर्काइव में जाते हैं और खोजे जा सकते हैं।';
}

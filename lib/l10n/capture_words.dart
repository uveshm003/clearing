/// The words smart capture understands, per language (FR-01a).
///
/// Every language's words are matched at once, since people mix languages
/// when they type. To teach the parser a new language, add its words to each
/// table below; patterns are case-insensitive, and a space between words also
/// matches several spaces. Keep entries lowercase.
library;

/// Weekday names, by [DateTime.weekday] (1 = Monday).
///
/// Short forms in [ambiguousWeekdays] are only read as days after "on",
/// "this", "next", "every", "by" or "due", or as the last word, since they're
/// also everyday words ("sat down", "sun cream").
const weekdayWords = <int, List<String>>{
  1: ['monday', 'mon', 'सोमवार', 'somvar'],
  2: ['tuesday', 'tues', 'tue', 'मंगलवार', 'mangalvar'],
  3: ['wednesday', 'weds', 'wed', 'बुधवार', 'budhvar'],
  4: ['thursday', 'thurs', 'thur', 'thu', 'गुरुवार', 'बृहस्पतिवार', 'guruvar'],
  5: ['friday', 'fri', 'शुक्रवार', 'shukravar'],
  6: ['saturday', 'sat', 'शनिवार', 'shanivar'],
  7: ['sunday', 'sun', 'रविवार', 'ravivar'],
};

const ambiguousWeekdays = {'sat', 'sun', 'wed', 'mon'};

/// Month names, by month number.
const monthWords = <int, List<String>>{
  1: ['january', 'jan', 'जनवरी'],
  2: ['february', 'feb', 'फ़रवरी', 'फरवरी'],
  3: ['march', 'mar', 'मार्च'],
  4: ['april', 'apr', 'अप्रैल'],
  5: ['may', 'मई'],
  6: ['june', 'jun', 'जून'],
  7: ['july', 'jul', 'जुलाई'],
  8: ['august', 'aug', 'अगस्त'],
  9: ['september', 'sept', 'sep', 'सितंबर', 'सितम्बर'],
  10: ['october', 'oct', 'अक्टूबर', 'अक्तूबर'],
  11: ['november', 'nov', 'नवंबर', 'नवम्बर'],
  12: ['december', 'dec', 'दिसंबर', 'दिसम्बर'],
};

/// Words for a day relative to today, as a number of days from today.
const relativeDayWords = <String, int>{
  'today': 0,
  'tod': 0,
  'tonight': 0,
  'tomorrow': 1,
  'tmrw': 1,
  'tmr': 1,
  'tomo': 1,
  'day after tomorrow': 2,
  'आज': 0,
  'aaj': 0,
  'आज रात': 0,
  // "Kal" is also "yesterday", but nobody plans for yesterday.
  'कल': 1,
  'kal': 1,
  'परसों': 2,
  'parson': 2,
};

/// Words for "this week" (a soft horizon, not a date).
const thisWeekWords = ['this week', 'इस हफ़्ते', 'इस हफ्ते', 'is hafte'];

/// Words for "next week" (the first day of next week).
const nextWeekWords = ['next week', 'अगले हफ़्ते', 'अगले हफ्ते', 'agle hafte'];

/// Words for "next month" (the first of next month).
const nextMonthWords = ['next month', 'अगले महीने', 'agle mahine'];

/// Words for the coming weekend, and the one after.
const weekendWords = ['this weekend', 'weekend', 'वीकेंड', 'इस वीकेंड'];
const nextWeekendWords = ['next weekend', 'अगले वीकेंड'];

/// Before a weekday: "next Friday" means the Friday of next week.
const nextWords = ['next', 'अगले', 'agle'];

/// Before a weekday, meaning the coming one.
const thisWords = ['on', 'this', 'coming', 'इस'];

/// Units for "in 3 days", by length in days (a month is handled apart).
const dayUnits = ['day', 'days', 'दिन', 'din'];
const weekUnits = [
  'week',
  'weeks',
  'हफ़्ते',
  'हफ्ते',
  'हफ़्ता',
  'हफ्ता',
  'hafte',
];
const monthUnits = ['month', 'months', 'महीने', 'महीना', 'mahine'];

/// "in" before a span ("in 3 days"), or "में" after it ("3 दिन में").
const inWords = ['in'];
const afterInWords = ['में', 'mein', 'me'];

/// Small numbers written as words.
const numberWords = <String, int>{
  'a': 1,
  'an': 1,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'एक': 1,
  'दो': 2,
  'तीन': 3,
  'चार': 4,
  'पाँच': 5,
  'पांच': 5,
};

/// Repeats.
const everyWords = ['every', 'each', 'हर'];
const dailyWords = [
  'daily',
  'everyday',
  'every day',
  'each day',
  'रोज़',
  'रोज',
  'रोज़ाना',
  'रोजाना',
  'हर दिन',
  'roz',
  'rozana',
];
const weeklyWords = [
  'weekly',
  'every week',
  'हर हफ़्ते',
  'हर हफ्ते',
  'har hafte',
];
const monthlyWords = ['monthly', 'every month', 'हर महीने', 'har mahine'];
const yearlyWords = ['yearly', 'annually', 'every year', 'हर साल', 'har saal'];
const weekdaysWords = ['every weekday', 'weekdays'];

/// Before a date, making it a deadline rather than a do-date.
const deadlineWords = ['by', 'due', 'before', 'तक'];

/// Times of day, as minutes from midnight.
const timeOfDayWords = <String, int>{
  'noon': 12 * 60,
  'midday': 12 * 60,
  'morning': 9 * 60,
  'this morning': 9 * 60,
  'in the morning': 9 * 60,
  'afternoon': 15 * 60,
  'this afternoon': 15 * 60,
  'evening': 18 * 60,
  'this evening': 18 * 60,
  'tonight': 20 * 60,
  'सुबह': 9 * 60,
  'दोपहर': 14 * 60,
  'शाम': 18 * 60,
  'रात': 21 * 60,
};

/// Hindi time words before "9 बजे": they set am or pm.
const hindiMorning = ['सुबह', 'subah'];
const hindiAfternoonEvening = [
  'दोपहर',
  'शाम',
  'रात',
  'dopahar',
  'shaam',
  'raat',
];
const oClockWords = ['बजे', 'baje'];

/// Words left dangling at the end of a title once a date or time is taken
/// out ("Pay rent on" → "Pay rent").
const danglingWords = {
  'on',
  'at',
  'by',
  'for',
  'in',
  'the',
  'every',
  'due',
  'before',
  'from',
  'and',
  'को',
  'पर',
  'में',
  'तक',
};

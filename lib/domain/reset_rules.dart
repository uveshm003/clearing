import 'enums.dart';
import 'item.dart';
import 'local_date.dart';
import 'today_rules.dart';

/// The items an overwhelm reset sorts (PRD §4.4): the inbox, and active
/// items that aren't planned for a later day. Future appointments, Waiting
/// and Someday stay out of it.
bool isResetCandidate(Item item, LocalDate today) =>
    item.status == ItemStatus.inbox ||
    (item.status == ItemStatus.active &&
        !(item.doDate?.isAfter(today) ?? false));

/// Whether "Let go" should start with [item] ticked. Dated and repeating
/// items are commitments someone chose on purpose, so they start unticked.
bool letGoByDefault(Item item) => item.doDate == null && item.seriesId == null;

/// Items already on Today as must-dos start ticked in "Must happen today".
bool mustDoByDefault(Item item, LocalDate today) =>
    item.mustDo && isOnToday(item, today);

import '../domain/notification_plan.dart';
import 'l10n.dart';

/// Notification words in the current language, for the domain's planner.
NotificationTexts notificationTexts() {
  final s = l10n;
  return NotificationTexts(
    reviewTitle: s.notifReviewTitle,
    reviewBody: s.notifReviewBody,
    backupTitle: s.notifBackupTitle,
    backupBody: s.notifBackupBody,
    digestTitle: s.notifDigestTitle,
    doneMeans: s.notifDoneMeans,
    blockTitle: s.notifBlockTitle,
    blockBody: s.notifBlockBody,
    digestMustDos: s.notifDigestMustDos,
    digestMoreToday: s.notifDigestMoreToday,
    digestOnToday: s.notifDigestOnToday,
  );
}

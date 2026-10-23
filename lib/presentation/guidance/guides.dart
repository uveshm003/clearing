import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// The help centre's short guides, one per area of the app.
enum GuideTopic { capture, decide, today, time, review, organize, data }

/// A guide: a lead sentence and four points, each a heading and a line.
typedef Guide = ({
  IconData icon,
  String title,
  String lead,
  List<({IconData icon, String title, String body})> points,
});

Guide guideFor(AppLocalizations l, GuideTopic topic) => switch (topic) {
  GuideTopic.capture => (
    icon: Icons.edit_note,
    title: l.guideCaptureTitle,
    lead: l.guideCaptureLead,
    points: [
      (
        icon: Icons.add_circle_outline,
        title: l.guideCapture1Title,
        body: l.guideCapture1Body,
      ),
      (
        icon: Icons.content_paste,
        title: l.guideCapture2Title,
        body: l.guideCapture2Body,
      ),
      (
        icon: Icons.share_outlined,
        title: l.guideCapture3Title,
        body: l.guideCapture3Body,
      ),
      (
        icon: Icons.widgets_outlined,
        title: l.guideCapture4Title,
        body: l.guideCapture4Body,
      ),
    ],
  ),
  GuideTopic.decide => (
    icon: Icons.alt_route,
    title: l.guideDecideTitle,
    lead: l.guideDecideLead,
    points: [
      (
        icon: Icons.help_outline,
        title: l.guideDecide1Title,
        body: l.guideDecide1Body,
      ),
      (icon: Icons.swipe, title: l.guideDecide2Title, body: l.guideDecide2Body),
      (
        icon: Icons.flag_outlined,
        title: l.guideDecide3Title,
        body: l.guideDecide3Body,
      ),
      (
        icon: Icons.person_outline,
        title: l.guideDecide4Title,
        body: l.guideDecide4Body,
      ),
    ],
  ),
  GuideTopic.today => (
    icon: Icons.wb_sunny_outlined,
    title: l.guideTodayTitle,
    lead: l.guideTodayLead,
    points: [
      (
        icon: Icons.star_outline_rounded,
        title: l.guideToday1Title,
        body: l.guideToday1Body,
      ),
      (icon: Icons.history, title: l.guideToday2Title, body: l.guideToday2Body),
      (
        icon: Icons.view_week_outlined,
        title: l.guideToday3Title,
        body: l.guideToday3Body,
      ),
      (
        icon: Icons.check_circle_outline,
        title: l.guideToday4Title,
        body: l.guideToday4Body,
      ),
    ],
  ),
  GuideTopic.time => (
    icon: Icons.schedule,
    title: l.guideTimeTitle,
    lead: l.guideTimeLead,
    points: [
      (
        icon: Icons.event_outlined,
        title: l.guideTime1Title,
        body: l.guideTime1Body,
      ),
      (icon: Icons.repeat, title: l.guideTime2Title, body: l.guideTime2Body),
      (
        icon: Icons.bedtime_outlined,
        title: l.guideTime3Title,
        body: l.guideTime3Body,
      ),
      (
        icon: Icons.wb_twilight,
        title: l.guideTime4Title,
        body: l.guideTime4Body,
      ),
    ],
  ),
  GuideTopic.review => (
    icon: Icons.self_improvement_outlined,
    title: l.guideReviewTitle,
    lead: l.guideReviewLead,
    points: [
      (
        icon: Icons.fact_check_outlined,
        title: l.guideReview1Title,
        body: l.guideReview1Body,
      ),
      (
        icon: Icons.self_improvement_outlined,
        title: l.guideReview2Title,
        body: l.guideReview2Body,
      ),
      (
        icon: Icons.center_focus_strong_outlined,
        title: l.guideReview3Title,
        body: l.guideReview3Body,
      ),
      (
        icon: Icons.print_outlined,
        title: l.guideReview4Title,
        body: l.guideReview4Body,
      ),
    ],
  ),
  GuideTopic.organize => (
    icon: Icons.list_alt_outlined,
    title: l.guideOrganizeTitle,
    lead: l.guideOrganizeLead,
    points: [
      (
        icon: Icons.list_alt_outlined,
        title: l.guideOrganize1Title,
        body: l.guideOrganize1Body,
      ),
      (
        icon: Icons.event_available_outlined,
        title: l.guideOrganize2Title,
        body: l.guideOrganize2Body,
      ),
      (
        icon: Icons.checklist,
        title: l.guideOrganize3Title,
        body: l.guideOrganize3Body,
      ),
      (
        icon: Icons.search,
        title: l.guideOrganize4Title,
        body: l.guideOrganize4Body,
      ),
    ],
  ),
  GuideTopic.data => (
    icon: Icons.lock_outline,
    title: l.guideDataTitle,
    lead: l.guideDataLead,
    points: [
      (
        icon: Icons.cloud_off_outlined,
        title: l.guideData1Title,
        body: l.guideData1Body,
      ),
      (
        icon: Icons.backup_outlined,
        title: l.guideData2Title,
        body: l.guideData2Body,
      ),
      (
        icon: Icons.phonelink_setup_outlined,
        title: l.guideData3Title,
        body: l.guideData3Body,
      ),
      (
        icon: Icons.delete_outline,
        title: l.guideData4Title,
        body: l.guideData4Body,
      ),
    ],
  ),
};

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// The optional three-card intro (PRD §9): never forced, offered on an empty
/// Today and in Settings.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  /// The three cards: icon, title and body, in the current language.
  static List<(IconData, String, String)> cards(BuildContext context) {
    final l10n = context.l10n;
    return [
      (Icons.edit_note, l10n.introCaptureTitle, l10n.introCaptureBody),
      (Icons.alt_route, l10n.introDecideTitle, l10n.introDecideBody),
      (Icons.wb_sunny_outlined, l10n.introPlanTitle, l10n.introPlanBody),
    ];
  }

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pages = PageController();
  var _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = IntroScreen.cards(context);
    final last = _page == cards.length - 1;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.introTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final (i, (icon, title, body)) in cards.indexed)
                    Semantics(
                      label: l10n.introCardPosition(i + 1, cards.length),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Icon(icon, size: 64, color: scheme.primary),
                            const SizedBox(height: 24),
                            Text(
                              title,
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              body,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    Container(
                      width: i == _page ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: i == _page ? scheme.primary : scheme.outline,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (!last)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.commonSkip),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: last
                        ? () => Navigator.pop(context)
                        : () => _pages.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                    child: Text(last ? l10n.introGetStarted : l10n.commonNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

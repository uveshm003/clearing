import 'package:flutter/material.dart';

/// The optional three-card intro (PRD §9): never forced, offered on an empty
/// Today and in Settings.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  static const cards = [
    (
      Icons.edit_note,
      'Capture it',
      'Get a thought out of your head the moment it appears. One line is '
          'enough: it waits in the Inbox until you have a minute.',
    ),
    (
      Icons.alt_route,
      'Decide what it means',
      'Later, give each one a place: today, this week, a date, someone '
          'else, or Someday if it’s just an idea.',
    ),
    (
      Icons.wb_sunny_outlined,
      'Plan small, close often',
      'Keep Today to a few must-dos, and review once a week so nothing is '
          'forgotten. Missed things are carried over, never held against '
          'you.',
    ),
  ];

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

  bool get _last => _page == IntroScreen.cards.length - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('How Clearing works'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final (i, (icon, title, body))
                      in IntroScreen.cards.indexed)
                    Semantics(
                      label: 'Card ${i + 1} of ${IntroScreen.cards.length}',
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
                  for (var i = 0; i < IntroScreen.cards.length; i++)
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
                  if (!_last)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Skip'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _last
                        ? () => Navigator.pop(context)
                        : () => _pages.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                    child: Text(_last ? 'Get started' : 'Next'),
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

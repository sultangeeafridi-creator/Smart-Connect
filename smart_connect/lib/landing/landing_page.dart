import 'package:flutter/material.dart';

import '../widgets/cinematic_filled_button.dart';
import 'faq_page.dart';
import 'world_connect_page.dart';

enum ThemeModeOption { auto, light, dark }

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  ThemeModeOption _themeModeOption = ThemeModeOption.auto;

  ThemeMode get _themeMode {
    switch (_themeModeOption) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.auto:
        return ThemeMode.system;
    }
  }

  void _updateTheme(ThemeModeOption option) {
    setState(() {
      _themeModeOption = option;
    });
    widget.onThemeModeChanged(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Name and Logo
                  const Icon(
                    Icons.hub_outlined,
                    size: 64,
                    color: Color(0xff176b87),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Smart Connect',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff176b87),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Welcome Section
                  Text(
                    'Say hello',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Guideline 1
                  _GuidelineCard(
                    icon: Icons.favorite_outline,
                    title: 'Bring curiosity and kindness',
                    description:
                        'Make the person on the other side feel welcome.',
                  ),
                  const SizedBox(height: 16),

                  // Guideline 2
                  _GuidelineCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Keep it appropriate',
                    description: 'Help every conversation feel comfortable.',
                  ),
                  const SizedBox(height: 16),

                  // Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'We may limit access when these guidelines aren\'t respected.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Continue Button
                  CinematicFilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WorldConnectPage(
                            onThemeModeChanged: widget.onThemeModeChanged,
                          ),
                        ),
                      );
                    },
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 32),

                  // Appearance Selector
                  _AppearanceSelector(
                    currentOption: _themeModeOption,
                    onChanged: _updateTheme,
                  ),
                  const SizedBox(height: 16),

                  // FAQ Link
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FaqPage(
                            onThemeModeChanged: widget.onThemeModeChanged,
                          ),
                        ),
                      );
                    },
                    child: const Text('View FAQs'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidelineCard extends StatelessWidget {
  const _GuidelineCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSelector extends StatelessWidget {
  const _AppearanceSelector({
    required this.currentOption,
    required this.onChanged,
  });

  final ThemeModeOption currentOption;
  final ValueChanged<ThemeModeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeModeOption>(
          segments: const [
            ButtonSegment(
              value: ThemeModeOption.auto,
              label: Text('Auto'),
              icon: Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeModeOption.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment(
              value: ThemeModeOption.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode),
            ),
          ],
          selected: {currentOption},
          onSelectionChanged: (Set<ThemeModeOption> selected) {
            onChanged(selected.first);
          },
        ),
      ],
    );
  }
}

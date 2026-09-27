import 'package:flutter/material.dart';

enum ThemeModeOption { auto, light, dark }

class FaqPage extends StatefulWidget {
  const FaqPage({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
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
                  const SizedBox(height: 32),

                  // FAQ Heading
                  Text(
                    'Frequently Asked Questions',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // FAQ 1
                  _FaqCard(
                    question: 'What is Smart Connect?',
                    answer: 'Smart Connect is a platform that helps you meet people for meaningful 1-to-1 conversations. It uses your profile and interests to help connect you with people who share similar interests, making it easier to start a conversation.',
                  ),
                  const SizedBox(height: 16),

                  // FAQ 2
                  _FaqCard(
                    question: 'Why do people use Smart Connect?',
                    answer: 'People use Smart Connect to discover new people, share ideas, discuss their interests, practice languages, talk about movies and series, have friendly discussions, and build meaningful connections with people who have similar interests.',
                  ),
                  const SizedBox(height: 32),

                  // Appearance Selector
                  _AppearanceSelector(
                    currentOption: _themeModeOption,
                    onChanged: _updateTheme,
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

class _FaqCard extends StatefulWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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

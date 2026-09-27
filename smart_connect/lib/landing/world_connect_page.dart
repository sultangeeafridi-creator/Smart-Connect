import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../auth/login_page.dart';
import '../connect/account_settings_pages.dart';
import '../widgets/cinematic_filled_button.dart';

enum ThemeModeOption { auto, light, dark }

class WorldConnectPage extends StatefulWidget {
  const WorldConnectPage({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<WorldConnectPage> createState() => _WorldConnectPageState();
}

class _WorldConnectPageState extends State<WorldConnectPage> {
  bool _is18OrOlder = false;
  ThemeModeOption _themeModeOption = ThemeModeOption.auto;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _videoUnavailable = false;

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

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/v2.mp4');
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.play();
      if (mounted) setState(() => _isVideoInitialized = true);
    } catch (_) {
      if (mounted) setState(() => _videoUnavailable = true);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
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

                  // World Network Video
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isVideoInitialized
                        ? VideoPlayer(_videoController)
                        : Center(
                            child: _videoUnavailable
                                ? const Icon(
                                    Icons.public_rounded,
                                    color: Colors.white70,
                                    size: 56,
                                  )
                                : const CircularProgressIndicator(),
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Heading
                  Text(
                    'Connect Across the World',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Meet people from different countries, discover shared interests, practice languages, and have engaging conversations with the help of AI.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Age Confirmation
                  Row(
                    children: [
                      Checkbox(
                        value: _is18OrOlder,
                        onChanged: (value) {
                          setState(() {
                            _is18OrOlder = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _is18OrOlder = !_is18OrOlder;
                            });
                          },
                          child: const Text('I am 18 or older.'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Terms
                  Text(
                    'By continuing, you agree to our ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: [
                      _LinkText(
                        'Terms of Use',
                        onTap: () => _openPolicy(const TermsPrivacyPage()),
                      ),
                      const Text(', ', style: TextStyle(fontSize: 12)),
                      _LinkText(
                        'Privacy Policy',
                        onTap: () => _openPolicy(const TermsPrivacyPage()),
                      ),
                      const Text(', and ', style: TextStyle(fontSize: 12)),
                      _LinkText(
                        'Acceptable Use Policy',
                        onTap: () => _openPolicy(const RulesPage()),
                      ),
                      const Text('.', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Agree and Continue Button
                  CinematicFilledButton(
                    onPressed: _is18OrOlder
                        ? () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => LoginPage(
                                  onThemeModeChanged: widget.onThemeModeChanged,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Agree & Continue'),
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

  void _openPolicy(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
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

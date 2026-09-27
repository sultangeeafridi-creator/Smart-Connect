import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'device_check_pages.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.name,
    required this.email,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final String name;
  final String? email;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.primary,
                child: Text(name.characters.first.toUpperCase()),
              ),
              title: Text(name),
              subtitle: Text(email ?? 'Email not available'),
            ),
          ),
          const SizedBox(height: 22),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            subtitle: const Text('Sign out of this account on this device.'),
            onTap: onSignOut,
          ),
          ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: colors.error),
            title: Text(
              'Delete account',
              style: TextStyle(color: colors.error),
            ),
            subtitle: const Text('Remove this account from Smart Connect.'),
            onTap: () => _confirmDeletion(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Delete this account?'),
        content: const Text(
          'This removes the account from this app. You will need to create a new account to use Smart Connect again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed == true) onDeleteAccount();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeMode _themeMode = Theme.of(context).brightness == Brightness.dark
      ? ThemeMode.dark
      : ThemeMode.light;

  void _setTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SectionHeading(title: 'APPEARANCE'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                ],
                selected: {_themeMode},
                onSelectionChanged: (selection) => _setTheme(selection.first),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(title: 'DEVICES'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: const Text('Camera'),
                  subtitle: const Text('Preview your camera.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      _openDeviceCheck(context, const CameraCheckPage()),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.mic_none_rounded),
                  title: const Text('Microphone'),
                  subtitle: const Text(
                    'Check that your microphone picks up sound.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      _openDeviceCheck(context, const MicrophoneCheckPage()),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.volume_up_outlined),
                  title: const Text('Speakers'),
                  subtitle: const Text('Play a short test tone.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      _openDeviceCheck(context, const SpeakerCheckPage()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDeviceCheck(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  static const _rules = [
    (
      Icons.favorite_border_rounded,
      'Respect others',
      'Treat everyone with kindness. Harassment, hate, and threats are not allowed.',
    ),
    (
      Icons.block_outlined,
      'Keep it appropriate',
      'No explicit, suggestive, or otherwise inappropriate content or behavior.',
    ),
    (
      Icons.verified_user_outlined,
      'Adults only',
      'Smart Connect is strictly for people aged 18 and older.',
    ),
    (
      Icons.gavel_outlined,
      'Follow the law',
      'Do not use the platform to plan, promote, or carry out illegal activity.',
    ),
    (
      Icons.campaign_outlined,
      'No spam or commercial misuse',
      'Do not spam, advertise, solicit, or use conversations for commercial purposes.',
    ),
    (
      Icons.report_gmailerrorred_outlined,
      'Report violations',
      'Contact the Smart Connect team if someone breaks these rules. Leave any conversation that feels unsafe.',
    ),
    (
      Icons.shield_outlined,
      'Use the service responsibly',
      'Do not disrupt, abuse, or misuse Smart Connect or its safety features.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community rules')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'A better conversation starts with respect.',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'These rules apply whenever you meet or message someone on Smart Connect.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          for (final rule in _rules)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Icon(
                  rule.$1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  rule.$2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(rule.$3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Privacy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'The essentials',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _PolicyCard(
            icon: Icons.handshake_outlined,
            title: 'Terms of use',
            paragraphs: const [
              'You must be 18 or older to use Smart Connect.',
              'No harassment, hate, threats, or inappropriate content or behavior.',
              'No illegal activity, spam, advertising, or commercial misuse.',
              'You agree to follow the Community Rules and use the service responsibly.',
              'Violations may lead to restricted access or removal from the service.',
            ],
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy basics',
            paragraphs: const [
              'Keep personal details such as your phone number, home address, and passwords private when chatting.',
              'Camera and microphone access is requested only when you open a feature that needs that device.',
              'Contact Us opens an email draft addressed to support and includes your account email so a reply can reach you.',
              'You can sign out or request account deletion from Account settings.',
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'These are the in-app rules and policy summary. A complete privacy notice and legal terms should be published before Smart Connect is made publicly available.',
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.icon,
    required this.title,
    required this.paragraphs,
  });

  final IconData icon;
  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final paragraph in paragraphs) ...[
              Text(paragraph),
              if (paragraph != paragraphs.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({
    super.key,
    required this.email,
    required this.supportEmail,
  });

  final String? email;
  final String supportEmail;

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _messageController = TextEditingController();
  bool _isOpeningEmail = false;

  int get _wordCount => _messageController.text
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _openEmailDraft() async {
    if (_messageController.text.trim().isEmpty || _wordCount > 500) return;
    setState(() => _isOpeningEmail = true);
    final body = StringBuffer()
      ..writeln('Reply to: ${widget.email ?? 'Not provided'}')
      ..writeln()
      ..write(_messageController.text.trim());
    final uri = Uri(
      scheme: 'mailto',
      path: widget.supportEmail,
      queryParameters: {
        'subject': 'Smart Connect support',
        'body': body.toString(),
      },
    );
    try {
      final opened = await launchUrl(uri);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? 'Email draft opened. Review it and press Send in your email app.'
                : 'No email app could open this draft.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open your email app.')),
      );
    } finally {
      if (mounted) setState(() => _isOpeningEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overLimit = _wordCount > 500;
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          Text(
            'We’re listening.',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Write to the Smart Connect team. Your email app will open with a draft you can review and send.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Reply to'),
              subtitle: Text(
                widget.email ?? 'Add your account email to receive a reply.',
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _messageController,
            onChanged: (_) => setState(() {}),
            minLines: 7,
            maxLines: 12,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              labelText: 'Your message',
              hintText: 'Tell us how we can help…',
              helperText: 'Up to 500 words',
              errorText: overLimit
                  ? 'Please keep your message within 500 words.'
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_wordCount / 500 words',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: overLimit ? colors.error : colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isOpeningEmail || _wordCount == 0 || overLimit
                  ? null
                  : _openEmailDraft,
              icon: _isOpeningEmail
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.mail_outline_rounded),
              label: const Text('Open email to send'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

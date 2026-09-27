import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_view_model.dart';
import '../auth/login_page.dart';
import '../widgets/cinematic_filled_button.dart';
import 'account_settings_pages.dart';
import 'country_data.dart';

enum _ConnectTab { meet, chats, profile }

enum ChatMode { video, text }

class ConnectHomePage extends StatefulWidget {
  const ConnectHomePage({
    super.key,
    this.firstName,
    this.email,
    this.preferredCountry,
    required this.onThemeModeChanged,
  });

  final String? firstName;
  final String? email;
  final String? preferredCountry;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ConnectHomePage> createState() => _ConnectHomePageState();
}

class _ConnectHomePageState extends State<ConnectHomePage> {
  _ConnectTab _tab = _ConnectTab.meet;
  ChatMode _mode = ChatMode.video;
  String? _countryOverride;

  String get _country =>
      _countryOverride ?? widget.preferredCountry ?? 'Anywhere';

  void _openLobby() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchLobbyPage(mode: _mode, country: _country),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab.index,
          children: [
            _buildMeetPage(context),
            _buildChatsPage(context),
            _buildProfilePage(context),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab.index,
        onDestinationSelected: (index) =>
            setState(() => _tab = _ConnectTab.values[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public_rounded),
            label: 'Meet',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'You',
          ),
        ],
      ),
    );
  }

  Widget _buildMeetPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.hub_rounded, color: colors.primary),
            ),
            const SizedBox(width: 11),
            Text(
              'smart connect',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            const Spacer(),
            IconButton.filledTonal(
              tooltip: 'Your profile',
              onPressed: () => setState(() => _tab = _ConnectTab.profile),
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'Hey, ${widget.firstName?.isNotEmpty == true ? widget.firstName : 'there'} 👋',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.7),
        ),
        const SizedBox(height: 5),
        Text(
          'One hello can take you anywhere.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        _buildWorldCard(context),
        const SizedBox(height: 22),
        Text(
          'How would you like to meet?',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ChatMode>(
          segments: const [
            ButtonSegment(
              value: ChatMode.video,
              icon: Icon(Icons.videocam_outlined),
              label: Text('Video'),
            ),
            ButtonSegment(
              value: ChatMode.text,
              icon: Icon(Icons.forum_outlined),
              label: Text('Text'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) =>
              setState(() => _mode = selection.first),
        ),
        const SizedBox(height: 14),
        Material(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _showCountryOptions,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    countryFlag(_country),
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meet people from',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _country,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 54,
          child: CinematicFilledButton(
            onPressed: _openLobby,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _mode == ChatMode.video
                      ? Icons.videocam_rounded
                      : Icons.chat_rounded,
                ),
                const SizedBox(width: 9),
                Text(
                  _mode == ChatMode.video
                      ? 'Start video chat'
                      : 'Start text chat',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 17,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'You stay in control. Leave a chat whenever you want.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorldCard(BuildContext context) {
    return Container(
      height: 238,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff123f54), Color(0xff176b87), Color(0xff1a8a91)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -50,
            child: _OrbitArtwork(color: Colors.white.withValues(alpha: 0.13)),
          ),
          Positioned(
            right: 25,
            top: 40,
            child: Icon(
              Icons.hub_rounded,
              size: 88,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.explore_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'A WORLD OF CONVERSATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 240,
                  child: Text(
                    'Meet beyond\nyour usual circle.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose video or text and meet someone new.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.82)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 42,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your conversations live here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'When you meet someone, you’ll find your recent chats here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => setState(() => _tab = _ConnectTab.meet),
              icon: const Icon(Icons.public_rounded),
              label: const Text('Meet someone'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = widget.firstName?.isNotEmpty == true
        ? widget.firstName!
        : 'Smart Connect member';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.primary,
                  child: Text(
                    name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (widget.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.email!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _buildProfileAction(
          context,
          icon: Icons.manage_accounts_outlined,
          title: 'Account',
          subtitle: 'Sign out or delete your account',
          onTap: () => _openPage(
            AccountPage(
              name: name,
              email: widget.email,
              onSignOut: _signOut,
              onDeleteAccount: _deleteAccount,
            ),
          ),
        ),
        _buildProfileAction(
          context,
          icon: Icons.tune_rounded,
          title: 'Settings',
          subtitle: 'Theme, camera, microphone, and speakers',
          onTap: () => _openPage(
            SettingsPage(onThemeModeChanged: widget.onThemeModeChanged),
          ),
        ),
        _buildProfileAction(
          context,
          icon: Icons.shield_outlined,
          title: 'Rules',
          subtitle: 'How we keep conversations respectful',
          onTap: () => _openPage(const RulesPage()),
        ),
        _buildProfileAction(
          context,
          icon: Icons.policy_outlined,
          title: 'Terms & Privacy',
          subtitle: 'Read the essentials',
          onTap: () => _openPage(const TermsPrivacyPage()),
        ),
        _buildProfileAction(
          context,
          icon: Icons.mail_outline_rounded,
          title: 'Contact us',
          subtitle: 'Send a message to the Smart Connect team',
          onTap: () => _openPage(
            ContactUsPage(
              email: widget.email,
              supportEmail: 'Sultangeeafridi@gmail.com',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: colors.surfaceContainerLow,
          child: ListTile(
            leading: Text(
              countryFlag(_country),
              style: const TextStyle(fontSize: 22),
            ),
            title: const Text('Preferred country'),
            subtitle: Text(_country),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _showCountryOptions() async {
    final selectedCountry = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCountries = countryNames
                .where(
                  (country) => country.toLowerCase().startsWith(
                    query.trim().toLowerCase(),
                  ),
                )
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.78,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Text(
                        'Meet people from',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) =>
                            setModalState(() => query = value),
                        decoration: InputDecoration(
                          hintText: 'Search countries',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () =>
                                      setModalState(() => query = ''),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filteredCountries.isEmpty
                          ? const Center(child: Text('No countries found'))
                          : ListView.builder(
                              itemCount: filteredCountries.length,
                              itemBuilder: (context, index) {
                                final country = filteredCountries[index];
                                return ListTile(
                                  leading: Text(
                                    countryFlag(country),
                                    style: const TextStyle(fontSize: 23),
                                  ),
                                  title: Text(country),
                                  trailing: country == _country
                                      ? Icon(
                                          Icons.check_circle_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        )
                                      : null,
                                  onTap: () => Navigator.pop(context, country),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selectedCountry != null && mounted) {
      setState(() => _countryOverride = selectedCountry);
    }
  }

  Future<void> _signOut() async {
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            LoginPage(onThemeModeChanged: widget.onThemeModeChanged),
      ),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    await context.read<AuthViewModel>().deleteAccount();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            LoginPage(onThemeModeChanged: widget.onThemeModeChanged),
      ),
      (route) => false,
    );
  }
}

class _OrbitArtwork extends StatelessWidget {
  const _OrbitArtwork({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final size in [230.0, 170.0, 110.0])
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.2),
              ),
            ),
          Icon(Icons.circle, size: 13, color: color),
        ],
      ),
    );
  }
}

class MatchLobbyPage extends StatelessWidget {
  const MatchLobbyPage({super.key, required this.mode, required this.country});

  final ChatMode mode;
  final String country;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isVideo = mode == ChatMode.video;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your next connection'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: 390,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff102935), Color(0xff17495c)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -35,
                      top: -30,
                      child: _OrbitArtwork(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 116,
                            height: 116,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Icon(
                              isVideo
                                  ? Icons.videocam_outlined
                                  : Icons.chat_bubble_outline_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            isVideo ? 'Video room' : 'Text room',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A new conversation is just ahead.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.public,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              country,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.tertiaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: colors.tertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is your connection lobby preview. Live ${isVideo ? 'video' : 'text'} matching will be enabled when the app is connected to its matching service.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: colors.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to discovery'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You can leave a conversation at any time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/appwrite_service.dart';
import '../privacy/privacy_dashboard.dart';
import '../biometric/biometric_setup_wizard.dart';
import '../subscription/subscription_screen.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection('Account'),
          _buildAccountSettings(),
          const Divider(),
          _buildSection('Preferences'),
          _buildPreferencesSettings(),
          const Divider(),
          _buildSection('Security'),
          _buildSecuritySettings(),
          const Divider(),
          _buildSection('About'),
          _buildAboutSettings(),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          subtitle: const Text('Edit your profile information'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to profile page
          },
        ),
        ListTile(
          leading: const Icon(Icons.card_membership),
          title: const Text('Subscription'),
          subtitle: const Text('Manage your subscription'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubscriptionScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.key),
          title: const Text('API Keys'),
          subtitle: const Text('Manage Binance API keys'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to API keys page
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSettings() {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          subtitle: const Text('Enable push notifications'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _saveSetting('notifications_enabled', value);
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme'),
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() => _darkModeEnabled = value);
            _saveSetting('dark_mode_enabled', value);
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(_selectedLanguage),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguagePicker(),
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Biometric Authentication'),
          subtitle: const Text('Use fingerprint or face ID'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BiometricSetupWizard(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy'),
          subtitle: const Text('Control your data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrivacyDashboard(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to change password page
          },
        ),
      ],
    );
  }

  Widget _buildAboutSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to terms
          },
        ),
        ListTile(
          leading: const Icon(Icons.policy),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to privacy policy
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to support
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = [
      'English',
      'Español',
      'Français',
      'Deutsch',
      '中文',
      '日本語'
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: languages.map((language) {
          return ListTile(
            title: Text(language),
            trailing: _selectedLanguage == language
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              setState(() => _selectedLanguage = language);
              _saveSetting('selected_language', language);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();

              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

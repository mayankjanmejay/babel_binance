import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyDashboard extends ConsumerStatefulWidget {
  const PrivacyDashboard({super.key});

  @override
  ConsumerState<PrivacyDashboard> createState() => _PrivacyDashboardState();
}

class _PrivacyDashboardState extends ConsumerState<PrivacyDashboard> {
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  bool _personalizedAdsEnabled = false;
  bool _locationTrackingEnabled = false;
  bool _biometricEnabled = false;
  bool _dataSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _crashReportingEnabled = prefs.getBool('crash_reporting_enabled') ?? true;
      _personalizedAdsEnabled = prefs.getBool('personalized_ads_enabled') ?? false;
      _locationTrackingEnabled = prefs.getBool('location_tracking_enabled') ?? false;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _dataSharingEnabled = prefs.getBool('data_sharing_enabled') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Control Your Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage how your data is collected and used',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _buildPrivacySection(
            title: 'Data Collection',
            children: [
              _buildSwitchTile(
                title: 'Analytics',
                subtitle: 'Help us improve by sharing usage data',
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() => _analyticsEnabled = value);
                  _savePreference('analytics_enabled', value);
                },
                icon: Icons.analytics,
              ),
              _buildSwitchTile(
                title: 'Crash Reporting',
                subtitle: 'Automatically send crash reports',
                value: _crashReportingEnabled,
                onChanged: (value) {
                  setState(() => _crashReportingEnabled = value);
                  _savePreference('crash_reporting_enabled', value);
                },
                icon: Icons.bug_report,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPrivacySection(
            title: 'Personalization',
            children: [
              _buildSwitchTile(
                title: 'Personalized Ads',
                subtitle: 'Show ads based on your interests',
                value: _personalizedAdsEnabled,
                onChanged: (value) {
                  setState(() => _personalizedAdsEnabled = value);
                  _savePreference('personalized_ads_enabled', value);
                },
                icon: Icons.ads_click,
              ),
              _buildSwitchTile(
                title: 'Location Tracking',
                subtitle: 'Use location for relevant features',
                value: _locationTrackingEnabled,
                onChanged: (value) {
                  setState(() => _locationTrackingEnabled = value);
                  _savePreference('location_tracking_enabled', value);
                },
                icon: Icons.location_on,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPrivacySection(
            title: 'Security',
            children: [
              _buildSwitchTile(
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face ID',
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                  _savePreference('biometric_enabled', value);
                },
                icon: Icons.fingerprint,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPrivacySection(
            title: 'Data Sharing',
            children: [
              _buildSwitchTile(
                title: 'Share Data with Partners',
                subtitle: 'Share anonymized data with third parties',
                value: _dataSharingEnabled,
                onChanged: (value) {
                  setState(() => _dataSharingEnabled = value);
                  _savePreference('data_sharing_enabled', value);
                },
                icon: Icons.share,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPrivacySection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDataExportDialog(),
            icon: const Icon(Icons.download),
            label: const Text('Export My Data'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteDataDialog(),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete My Data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // Navigate to privacy policy
          },
          child: const Text('View Privacy Policy'),
        ),
      ],
    );
  }

  void _showDataExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Your Data'),
        content: const Text(
          'We\'ll prepare a copy of your data and send it to your registered email address within 48 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export requested. Check your email in 48 hours.'),
                ),
              );
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Your Data'),
        content: const Text(
          'This will permanently delete all your data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement data deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

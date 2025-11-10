import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class BiometricSetupWizard extends ConsumerStatefulWidget {
  const BiometricSetupWizard({super.key});

  @override
  ConsumerState<BiometricSetupWizard> createState() => _BiometricSetupWizardState();
}

class _BiometricSetupWizardState extends ConsumerState<BiometricSetupWizard> {
  int _currentStep = 0;
  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final available = await authService.isBiometricsAvailable();
    final biometrics = await authService.getAvailableBiometrics();

    setState(() {
      _isAvailable = available;
      _availableBiometrics = biometrics;
      _isLoading = false;
    });
  }

  Future<void> _enableBiometric() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final authenticated = await authService.authenticateWithBiometrics();

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', true);

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication enabled!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Setup'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: _currentStep < 2 ? _nextStep : null,
              onStepCancel: _currentStep > 0 ? _previousStep : null,
              steps: [
                Step(
                  title: const Text('Welcome'),
                  content: _buildWelcomeStep(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Check Availability'),
                  content: _buildAvailabilityStep(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Enable Biometric'),
                  content: _buildEnableStep(),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        Icon(
          Icons.fingerprint,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Secure Your Account',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Use your fingerprint, face, or other biometric features to quickly and securely access your account.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBenefitItem('Quick and easy login'),
                _buildBenefitItem('Enhanced security'),
                _buildBenefitItem('No need to remember passwords'),
                _buildBenefitItem('Works with your device security'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildAvailabilityStep() {
    return Column(
      children: [
        if (_isAvailable) ...[
          Icon(
            Icons.check_circle,
            size: 100,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'Biometric Available!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your device supports biometric authentication.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Methods',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ..._availableBiometrics.map(
                    (type) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(_getBiometricIcon(type)),
                          const SizedBox(width: 12),
                          Text(_getBiometricName(type)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Icon(
            Icons.error,
            size: 100,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Not Available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Biometric authentication is not available on this device or not configured.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'What to do',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Go to your device settings\n'
                    '2. Enable fingerprint or face recognition\n'
                    '3. Return to this app and try again',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnableStep() {
    return Column(
      children: [
        Icon(
          Icons.security,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Enable Now',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tap the button below to authenticate and enable biometric login.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAvailable ? _enableBiometric : null,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Enable Biometric Authentication'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Skip for Now'),
        ),
      ],
    );
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      default:
        return Icons.security;
    }
  }

  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      default:
        return 'Biometric';
    }
  }
}

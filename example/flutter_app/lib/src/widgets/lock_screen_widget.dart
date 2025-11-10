import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';

class LockScreenWidget extends ConsumerStatefulWidget {
  final Widget child;
  final bool enabled;

  const LockScreenWidget({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  ConsumerState<LockScreenWidget> createState() => _LockScreenWidgetState();
}

class _LockScreenWidgetState extends ConsumerState<LockScreenWidget>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enabled) {
      _isLocked = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.enabled) {
      if (state == AppLifecycleState.paused) {
        // App went to background
        setState(() => _isLocked = true);
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final authService = ref.read(authServiceProvider);
    final authenticated = await authService.authenticateWithBiometrics();

    if (authenticated) {
      setState(() => _isLocked = false);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
      }
    }
  }

  void _authenticateWithPin() {
    // In production, verify PIN against stored hash
    if (_pinController.text == '1234') {
      // Example PIN
      setState(() => _isLocked = false);
      _pinController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return widget.child;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'App Locked',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _pinController,
                      decoration: InputDecoration(
                        hintText: 'Enter PIN',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _authenticateWithPin,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 8,
                      ),
                      onSubmitted: (_) => _authenticateWithPin(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use Biometrics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
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

// Usage provider for lock screen state
final lockScreenStateProvider = StateProvider<bool>((ref) => false);

// Lock screen wrapper widget for easy integration
class LockScreenWrapper extends ConsumerWidget {
  final Widget child;

  const LockScreenWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLockEnabled = ref.watch(lockScreenStateProvider);

    return LockScreenWidget(
      enabled: isLockEnabled,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/subscription_service.dart';
import '../../services/analytics_service.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  Offerings? _offerings;
  bool _isLoading = true;
  CustomerInfo? _customerInfo;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final offerings = await subscriptionService.getOfferings();
      final customerInfo = await subscriptionService.getCustomerInfo();

      setState(() {
        _offerings = offerings;
        _customerInfo = customerInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchasePackage(Package package) async {
    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final customerInfo = await subscriptionService.purchasePackage(package);

      // Log purchase event
      await ref.read(analyticsServiceProvider).logPurchase(
            value: package.storeProduct.price,
            currency: package.storeProduct.currencyCode,
            itemId: package.identifier,
          );

      setState(() => _customerInfo = customerInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final customerInfo = await subscriptionService.restorePurchases();

      setState(() => _customerInfo = customerInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        actions: [
          TextButton(
            onPressed: _restorePurchases,
            child: const Text('Restore'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offerings == null
              ? const Center(child: Text('No subscription plans available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_customerInfo?.entitlements.active.isNotEmpty ?? false)
                        _buildActiveSubscriptionBanner(),
                      const SizedBox(height: 24),
                      Text(
                        'Choose Your Plan',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock premium features and enhanced trading capabilities',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      _buildFeaturesList(),
                      const SizedBox(height: 32),
                      ..._buildSubscriptionPlans(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActiveSubscriptionBanner() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Subscription',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'You have access to all premium features',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('Unlimited API calls'),
            _buildFeatureItem('Advanced analytics and insights'),
            _buildFeatureItem('Real-time price alerts'),
            _buildFeatureItem('Portfolio tracking'),
            _buildFeatureItem('AI-powered trading suggestions'),
            _buildFeatureItem('Priority customer support'),
            _buildFeatureItem('Ad-free experience'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  List<Widget> _buildSubscriptionPlans() {
    if (_offerings?.current == null) return [];

    final packages = _offerings!.current!.availablePackages;

    return packages.map((package) {
      final isPopular = package.packageType == PackageType.annual;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildPlanCard(
          title: _getPackageTitle(package.packageType),
          price: package.storeProduct.priceString,
          period: _getPackagePeriod(package.packageType),
          features: _getPackageFeatures(package.packageType),
          isPopular: isPopular,
          onTap: () => _purchasePackage(package),
        ),
      );
    }).toList();
  }

  String _getPackageTitle(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Annual';
      case PackageType.lifetime:
        return 'Lifetime';
      default:
        return 'Premium';
    }
  }

  String _getPackagePeriod(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'per month';
      case PackageType.annual:
        return 'per year';
      case PackageType.lifetime:
        return 'one-time payment';
      default:
        return '';
    }
  }

  List<String> _getPackageFeatures(PackageType type) {
    final baseFeatures = [
      'All premium features',
      'Unlimited API access',
      'Advanced analytics',
    ];

    if (type == PackageType.annual) {
      return [...baseFeatures, 'Save 20% vs monthly', 'Priority support'];
    } else if (type == PackageType.lifetime) {
      return [...baseFeatures, 'One-time payment', 'Lifetime updates'];
    }

    return baseFeatures;
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isPopular ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPopular
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isPopular) const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(period),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  child: Text(isPopular ? 'Get Started' : 'Subscribe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

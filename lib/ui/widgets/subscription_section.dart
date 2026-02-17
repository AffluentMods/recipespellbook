import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/subscription_provider.dart';
import '../../services/revenuecat_service.dart';

/// Subscription section for settings_screen.dart.
///
/// Shows current plan status and upgrade/manage options.
///
/// Usage:
/// ```dart
/// import '../../ui/widgets/subscription_section.dart';
///
/// // In settings ListView children, after AccountSection:
/// const SubscriptionSection(),
/// ```
class SubscriptionSection extends ConsumerWidget {
  const SubscriptionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Subscription',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: status.isPro
              ? _ProContent(status: status)
              : const _FreeContent(),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  FREE — Show upgrade prompt
// ════════════════════════════════════════════

class _FreeContent extends ConsumerWidget {
  const _FreeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_outline, size: 32, color: Colors.amber),
          ),
          const SizedBox(height: 12),
          Text(
            'Upgrade to Pro',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Unlock cloud sync, smart import, and more.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => ref.read(subscriptionProvider.notifier).presentPaywall(),
              icon: const Icon(Icons.star, size: 18),
              label: const Text('View Plans'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              final restored = await ref.read(subscriptionProvider.notifier).restore();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(restored
                        ? 'Purchases restored successfully!'
                        : 'No previous purchases found.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Restore purchases'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  PRO — Show current plan + manage
// ════════════════════════════════════════════

class _ProContent extends ConsumerWidget {
  final SubscriptionStatus status;
  const _ProContent({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Plan badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade700,
                Colors.orange.shade600,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Affluent Labs Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    status.tier.displayName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Status details
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (status.isCancelled) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cancelled — access until ${_formatDate(status.expirationDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (status.tier != SubscriptionTier.lifetime &&
                  status.expirationDate != null &&
                  !status.isCancelled) ...[
                _DetailRow(
                  label: 'Renews',
                  value: _formatDate(status.expirationDate),
                ),
                const SizedBox(height: 4),
              ],

              if (status.tier == SubscriptionTier.lifetime)
                _DetailRow(label: 'Plan', value: 'Lifetime — never expires'),
            ],
          ),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Manage subscription
        ListTile(
          leading: Icon(Icons.credit_card, color: theme.colorScheme.outline),
          title: const Text('Manage subscription'),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => ref.read(subscriptionProvider.notifier).presentCustomerCenter(),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  PRO GATE — Use anywhere to gate features
// ════════════════════════════════════════════

/// Wraps a child widget and shows a paywall prompt if the user is not Pro.
///
/// Usage:
/// ```dart
/// ProGate(
///   child: SmartImportButton(...),
///   feature: 'Smart Import',
/// )
/// ```
class ProGate extends ConsumerWidget {
  final Widget child;
  final String feature;

  /// If true, shows the child but tapping triggers paywall.
  /// If false (default), replaces child with upgrade prompt.
  final bool showLocked;

  const ProGate({
    super.key,
    required this.child,
    required this.feature,
    this.showLocked = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);

    if (isPro) return child;

    if (showLocked) {
      return GestureDetector(
        onTap: () => ref.read(subscriptionProvider.notifier).presentPaywall(),
        child: Stack(
          children: [
            Opacity(opacity: 0.5, child: IgnorePointer(child: child)),
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('PRO',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    // Replace with upgrade prompt
    return _InlineUpgradePrompt(feature: feature);
  }
}

class _InlineUpgradePrompt extends ConsumerWidget {
  final String feature;
  const _InlineUpgradePrompt({required this.feature});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('Upgrade to Pro to unlock', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref.read(subscriptionProvider.notifier).presentPaywall(),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
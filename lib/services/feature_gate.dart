import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';
import '../services/revenuecat_service.dart';

// ════════════════════════════════════════════════════════════════
//  FEATURE DEFINITIONS
// ════════════════════════════════════════════════════════════════

/// All gated features in the app, mapped to the minimum tier required.
enum GatedFeature {
  /// Cloud sync between personal devices
  cloudSync(SubscriptionTier.premium, 'Cloud Sync', Icons.cloud_sync),

  /// Step-by-step photos on recipes
  stepPhotos(SubscriptionTier.premium, 'Step Photos', Icons.photo_library),

  /// Family sharing (shared cookbooks, lists, meal plans)
  familySharing(SubscriptionTier.cloudSync, 'Family Sharing', Icons.family_restroom),

  /// Shared shopping lists
  sharedLists(SubscriptionTier.cloudSync, 'Shared Lists', Icons.shopping_cart),

  /// Shared cookbooks
  sharedCookbooks(SubscriptionTier.cloudSync, 'Shared Cookbooks', Icons.menu_book),

  /// Shared meal planning
  sharedMealPlan(SubscriptionTier.cloudSync, 'Shared Meal Plan', Icons.calendar_month),

  /// Automatic backups
  backups(SubscriptionTier.cloudSync, 'Backups', Icons.backup),

  /// Community creator page
  creatorPage(SubscriptionTier.cloudSync, 'Creator Page', Icons.storefront),

  /// Custom domain for creator page
  customDomain(SubscriptionTier.creator, 'Custom Domain', Icons.language),
  ;

  final SubscriptionTier minimumTier;
  final String displayName;
  final IconData icon;

  const GatedFeature(this.minimumTier, this.displayName, this.icon);

  /// Check if a tier has access to this feature.
  bool isUnlockedFor(SubscriptionTier tier) =>
      tier.index >= minimumTier.index;
}

// ════════════════════════════════════════════════════════════════
//  PRO GATE WIDGET
// ════════════════════════════════════════════════════════════════

/// Wraps a child widget with tier-based access control.
///
/// If the user's tier is high enough → shows [child].
/// If not → shows [lockedPlaceholder] or a default upgrade prompt.
///
/// Usage:
/// ```dart
/// ProGate(
///   feature: GatedFeature.stepPhotos,
///   child: StepPhotoEditor(...),
/// )
/// ```
class ProGate extends ConsumerWidget {
  final GatedFeature feature;
  final Widget child;
  final Widget? lockedPlaceholder;

  const ProGate({
    super.key,
    required this.feature,
    required this.child,
    this.lockedPlaceholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionProvider).tier;

    if (feature.isUnlockedFor(tier)) {
      return child;
    }

    return lockedPlaceholder ?? _DefaultLockedWidget(feature: feature);
  }
}

/// Shows child only if user has the required tier (no placeholder).
/// Useful for hiding buttons/options entirely rather than showing a lock.
class ProGateVisibility extends ConsumerWidget {
  final GatedFeature feature;
  final Widget child;

  const ProGateVisibility({
    super.key,
    required this.feature,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionProvider).tier;

    if (feature.isUnlockedFor(tier)) {
      return child;
    }

    return const SizedBox.shrink();
  }
}

/// Default locked state — shows feature name + upgrade prompt.
class _DefaultLockedWidget extends StatelessWidget {
  final GatedFeature feature;

  const _DefaultLockedWidget({required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feature.icon,
            size: 36,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            feature.displayName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Requires ${feature.minimumTier.displayName} or higher',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => context.push('/upgrade'),
            icon: const Icon(Icons.star, size: 16),
            label: Text(l10n.upgrade),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  HELPER EXTENSIONS
// ════════════════════════════════════════════════════════════════

extension SubscriptionStatusX on SubscriptionStatus {
  /// Check if a specific feature is unlocked.
  bool hasFeature(GatedFeature feature) => feature.isUnlockedFor(tier);

  /// Check if user can add more photos within their storage limit.
  bool canAddPhotos(int currentUsageBytes) =>
      currentUsageBytes < tier.maxStorageBytes;

  /// Bytes remaining for photo storage.
  int storageRemaining(int usedBytes) =>
      (tier.maxStorageBytes - usedBytes).clamp(0, tier.maxStorageBytes);

  /// Human-readable storage used / total.
  String storageUsageLabel(int usedBytes) {
    final usedMB = (usedBytes / (1024 * 1024)).toStringAsFixed(1);
    return '$usedMB MB / ${tier.storageLabel}';
  }
}

// ════════════════════════════════════════════════════════════════
//  IMPERATIVE GATING HELPERS
// ════════════════════════════════════════════════════════════════

/// Show an upgrade prompt if the user doesn't have the required feature.
/// Returns true if the user HAS access, false if they were shown the prompt.
///
/// Usage:
/// ```dart
/// if (!await checkFeatureAccess(context, ref, GatedFeature.stepPhotos)) return;
/// // User has access — proceed
/// ```
bool checkFeatureAccess(
    BuildContext context,
    WidgetRef ref,
    GatedFeature feature,
    ) {
  final tier = ref.read(subscriptionProvider).tier;
  final l10n = AppLocalizations.of(context)!;
  if (feature.isUnlockedFor(tier)) return true;

  // Show upgrade prompt
  showModalBottomSheet(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(feature.icon, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Unlock ${feature.displayName}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature requires ${feature.minimumTier.displayName} or higher. '
                  'Upgrade to access ${feature.displayName.toLowerCase()} and more.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.noThanks),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/upgrade');
                    },
                    icon: const Icon(Icons.star, size: 18),
                    label: Text(l10n.upgrade),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );

  return false;
}

/// Check if the user can add a photo given current storage usage.
/// Shows a storage limit prompt if they can't.
/// Returns true if allowed, false if blocked.
bool checkStorageLimit(
    BuildContext context,
    WidgetRef ref, {
      required int currentUsageBytes,
      required int newPhotoBytes,
    }) {
  final tier = ref.read(subscriptionProvider).tier;
  final maxBytes = tier.maxStorageBytes;
  final l10n = AppLocalizations.of(context)!;

  if (currentUsageBytes + newPhotoBytes <= maxBytes) return true;

  // Storage limit reached
  showModalBottomSheet(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final usedMB = (currentUsageBytes / (1024 * 1024)).toStringAsFixed(1);
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.sd_storage, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Storage Limit Reached',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve used $usedMB MB of your ${tier.storageLabel} limit. '
                  'Delete some photos or upgrade for more storage.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.gotIt),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/upgrade');
                    },
                    icon: const Icon(Icons.star, size: 18),
                    label: Text(l10n.learnMore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );

  return false;
}
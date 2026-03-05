import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import 'app_snackbar.dart';

/// Account section for settings_screen.dart.
///
/// Shows sign-in buttons when signed out, or account info + sign out when signed in.
/// Handles account-switch detection regardless of current sign-in state.
///
/// Usage in settings_screen.dart:
/// ```dart
/// import '../../ui/widgets/account_section.dart';
///
/// // In the ListView children, at the top:
/// const AccountSection(),
/// ```
class AccountSection extends ConsumerStatefulWidget {
  const AccountSection({super.key});

  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<AccountSection> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // ── Account-switch detection (works whether signed in or out) ──
    final authNotifier = ref.read(authProvider.notifier);
    if (authNotifier.hasPendingAccountSwitch && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAccountSwitchSheet(
            context,
            ref,
            authNotifier.pendingAccountEmail ?? 'new account',
          );
        }
      });
    } else if (!authNotifier.hasPendingAccountSwitch) {
      _dialogShown = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.accountTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: authState.isSignedIn
              ? _SignedInContent(user: authState.user!)
              : _SignedOutContent(isLoading: authState.isLoading, error: authState.error),
        ),
      ],
    );
  }

  /// Modern bottom sheet for account-switch confirmation.
  void _showAccountSwitchSheet(BuildContext context, WidgetRef ref, String newEmail) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Switch Account?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'You\'re signing in as a different account ($newEmail). '
                'What would you like to do with your existing local recipes?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Option 1: Keep Recipes (primary)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(authProvider.notifier).confirmAccountSwitch(keepLocalData: true);
                  },
                  icon: const Icon(Icons.bookmark_added_outlined, size: 20),
                  label: const Text('Keep My Recipes'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Helper text for keep
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Your local recipes stay on this device and sync with the new account.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Option 2: Start Fresh
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(authProvider.notifier).confirmAccountSwitch(keepLocalData: false);
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 20),
                  label: const Text('Start Fresh'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Helper text for fresh
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Clear all local data and start with a clean slate.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Cancel link
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(authProvider.notifier).cancelAccountSwitch();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SIGNED OUT — Show sign-in buttons
// ════════════════════════════════════════════

class _SignedOutContent extends ConsumerWidget {
  final bool isLoading;
  final String? error;

  const _SignedOutContent({required this.isLoading, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.signInToSync,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.signInDescription,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),

          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(authProvider.notifier).clearError(),
                    child: Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Google Sign-In button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : () => ref.read(authProvider.notifier).signInWithGoogle(),
              icon: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const _GoogleIcon(),
              label: Text(l10n.continueWithGoogle),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Apple Sign-In (iOS/macOS only)
          if (isAppleSignInAvailable) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : () => ref.read(authProvider.notifier).signInWithApple(),
                icon: const Icon(Icons.apple, size: 20),
                label: Text(l10n.continueWithApple),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SIGNED IN — Show account info
// ════════════════════════════════════════════

class _SignedInContent extends ConsumerWidget {
  final AuthUser user;
  const _SignedInContent({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // User info row
        ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(user.initials, style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600))
                : null,
          ),
          title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(user.email, style: theme.textTheme.bodySmall),
        ),

        // Tier badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _TierBadge(tier: user.tier),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Sign out
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.outline),
          title: Text(l10n.signOut),
          onTap: () => _confirmSignOut(context, ref),
        ),

        // Delete account
        ListTile(
          leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
          title: Text(l10n.deleteAccount, style: TextStyle(color: theme.colorScheme.error)),
          onTap: () => _confirmDeleteAccount(context, ref),
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 32),
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(authProvider.notifier).deleteAccount();
              if (!success && context.mounted) {
                AppSnackbar.info(context, l10n.deleteAccountFailed);
              }
            },
            child: Text(l10n.deletePermanently),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  TIER BADGE
// ════════════════════════════════════════════

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final (label, color, icon) = switch (tier) {
      'creator' || 'admin' => ('Creator', Colors.amber.shade700, Icons.star),
      'cloudSyncFamily' => ('Cloud Sync Family', Colors.deepPurple, Icons.family_restroom),
      'cloudSync' => ('Cloud Sync', Colors.blue, Icons.cloud_sync),
      'premium' => ('Premium', Colors.green, Icons.check_circle_outline),
      _ => ('Free', theme.colorScheme.outline, Icons.person_outline),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(l10n.planLabel(label), style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
          const Spacer(),
          if (tier == 'free')
            Text(l10n.upgradeArrow, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  GOOGLE ICON (simple Material substitute)
// ════════════════════════════════════════════

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    // Using a simple "G" since we can't bundle the Google logo SVG
    // Replace with Image.asset('assets/google_logo.png') if you add the asset
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
      ),
    );
  }
}

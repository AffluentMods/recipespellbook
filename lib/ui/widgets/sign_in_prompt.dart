import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive_utils.dart';
import 'app_snackbar.dart';

/// Shows the Google / Apple sign-in sheet with [message] explaining why, runs
/// the chosen sign-in, and resolves to whether the user is signed in
/// afterwards — so the caller can carry on with what it was doing (e.g.
/// finish joining a shared list) instead of dropping the user's intent.
Future<bool> promptSignIn(
  BuildContext context,
  WidgetRef ref, {
  required String message,
  IconData icon = Icons.account_circle,
}) async {
  if (AuthService.instance.isSignedIn) return true;
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

  final choice = await Responsive.showAdaptiveSheet<String>(
    context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 24),
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.signInToContinue,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(ctx, 'google'),
                icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                label: Text(l10n.continueWithGoogle),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (isAppleSignInAvailable) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'apple'),
                  icon: const Icon(Icons.apple, size: 22),
                  label: Text(l10n.continueWithApple),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  if (choice == null) return AuthService.instance.isSignedIn;

  final notifier = ref.read(authProvider.notifier);
  if (choice == 'apple') {
    await notifier.signInWithApple();
  } else {
    await notifier.signInWithGoogle();
  }
  final error = ref.read(authProvider).error;
  if (!AuthService.instance.isSignedIn && error != null && context.mounted) {
    AppSnackbar.error(context, error);
  }
  return AuthService.instance.isSignedIn;
}

/// Wait for the saved session to finish restoring at startup. A link opened on
/// a cold start can reach its screen before auth has loaded, which would make
/// a signed-in user look signed out for a moment.
Future<void> waitForAuthReady(WidgetRef ref) async {
  if (!ref.read(authProvider).isLoading) return;
  try {
    await ref
        .read(authProvider.notifier)
        .stream
        .firstWhere((s) => !s.isLoading)
        .timeout(const Duration(seconds: 15));
  } catch (_) {
    // Timed out — carry on with whatever state we have.
  }
}

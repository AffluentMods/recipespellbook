import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/grocery_service.dart';

/// Handles the Kroger OAuth callback deep link:
///   recipespellbook://kroger-callback?code=XXXX
///
/// Automatically exchanges the auth code for tokens,
/// shows success/failure, then navigates to shopping.
class KrogerCallbackScreen extends StatefulWidget {
  final String? authCode;
  final String? error;

  const KrogerCallbackScreen({super.key, this.authCode, this.error});

  @override
  State<KrogerCallbackScreen> createState() => _KrogerCallbackScreenState();
}

class _KrogerCallbackScreenState extends State<KrogerCallbackScreen> {
  bool _loading = true;
  bool _success = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  Future<void> _processCallback() async {
    if (widget.error != null) {
      setState(() {
        _loading = false;
        _success = false;
        _message = 'krogerLoginDenied'; // resolved in build
      });
      return;
    }

    if (widget.authCode == null || widget.authCode!.isEmpty) {
      setState(() {
        _loading = false;
        _success = false;
        _message = 'krogerNoAuthCode'; // resolved in build
      });
      return;
    }

    debugPrint('[KrogerCallback] Exchanging auth code...');

    final ok = await GroceryService.krogerExchangeAuthCode(widget.authCode!);

    if (mounted) {
      setState(() {
        _loading = false;
        _success = ok;
        _message = ok ? 'krogerConnected' : 'krogerConnectFailed'; // resolved in build
      });

      // Auto-navigate after short delay on success
      if (ok) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/shopping');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Resolve message key to localized string
    String resolvedMessage;
    switch (_message) {
      case 'krogerLoginDenied':
        resolvedMessage = l10n.krogerLoginDenied(widget.error ?? '');
      case 'krogerNoAuthCode':
        resolvedMessage = l10n.krogerNoAuthCode;
      case 'krogerConnected':
        resolvedMessage = l10n.krogerConnected;
      case 'krogerConnectFailed':
        resolvedMessage = l10n.krogerConnectFailed;
      default:
        resolvedMessage = _message;
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading) ...[
                const SizedBox(
                  width: 56, height: 56,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 24),
                Text(l10n.krogerConnecting,
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.krogerExchanging,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline)),
              ] else ...[
                Icon(
                  _success ? Icons.check_circle : Icons.error_outline,
                  size: 64,
                  color: _success
                      ? const Color(0xFF43B02A)
                      : theme.colorScheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  _success ? l10n.krogerConnectedTitle : l10n.krogerConnectionFailed,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  resolvedMessage,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_success)
                  FilledButton.icon(
                    onPressed: () => context.go('/shopping'),
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: Text(l10n.goToShoppingList),
                  )
                else ...[
                  FilledButton(
                    onPressed: () async {
                      setState(() { _loading = true; });
                      await GroceryService.krogerStartOAuthLogin();
                      // If they come back, they'll hit this screen again
                      if (mounted) setState(() { _loading = false; });
                    },
                    child: Text(l10n.tryAgain),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/shopping'),
                    child: Text(l10n.skipForNow),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
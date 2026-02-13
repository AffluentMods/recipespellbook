import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        _message = 'Kroger login was denied: ${widget.error}';
      });
      return;
    }

    if (widget.authCode == null || widget.authCode!.isEmpty) {
      setState(() {
        _loading = false;
        _success = false;
        _message = 'No authorization code received from Kroger.';
      });
      return;
    }

    debugPrint('[KrogerCallback] Exchanging code: ${widget.authCode!.substring(0, 8)}...');

    final ok = await GroceryService.krogerExchangeAuthCode(widget.authCode!);

    if (mounted) {
      setState(() {
        _loading = false;
        _success = ok;
        _message = ok
            ? 'Kroger connected! You can now send items directly to your cart.'
            : 'Failed to connect Kroger. Please try again.';
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
                Text('Connecting to Kroger\u2026',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Exchanging authorization...',
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
                  _success ? 'Connected!' : 'Connection Failed',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _message,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_success)
                  FilledButton.icon(
                    onPressed: () => context.go('/shopping'),
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('Go to Shopping List'),
                  )
                else ...[
                  FilledButton(
                    onPressed: () async {
                      setState(() { _loading = true; });
                      await GroceryService.krogerStartOAuthLogin();
                      // If they come back, they'll hit this screen again
                      if (mounted) setState(() { _loading = false; });
                    },
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/shopping'),
                    child: const Text('Skip for now'),
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
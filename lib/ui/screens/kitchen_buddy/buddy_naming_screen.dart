// lib/ui/screens/kitchen_buddy/buddy_naming_screen.dart
// Simple companion naming screen for Kitchen Buddy

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/kitchen_buddy_provider.dart';
import '../../widgets/kitchen_buddy/kitchen_buddy_widget.dart';

class BuddyNamingScreen extends ConsumerStatefulWidget {
  const BuddyNamingScreen({super.key});

  @override
  ConsumerState<BuddyNamingScreen> createState() => _BuddyNamingScreenState();
}

class _BuddyNamingScreenState extends ConsumerState<BuddyNamingScreen> {
  final _nameController = TextEditingController(text: 'Buddy');
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _createBuddy() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref.read(kitchenBuddyProvider.notifier).createCompanion(name);

    if (context.mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kitchenBuddyNamingTitle),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Companion preview
                const KitchenBuddyWidget(
                  size: 200,
                  showBackground: true,
                  interactive: true,
                ),
                const SizedBox(height: 24),

                Text(
                  l10n.kitchenBuddyIntroTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.kitchenBuddyIntroDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name input
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _nameController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 20,
                    decoration: InputDecoration(
                      labelText: l10n.kitchenBuddyNameLabel,
                      hintText: l10n.kitchenBuddyNameHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _createBuddy(),
                  ),
                ),
                const SizedBox(height: 24),

                // Create button
                FilledButton.icon(
                  onPressed: _createBuddy,
                  icon: const Icon(Icons.restaurant),
                  label: Text(l10n.kitchenBuddyCreate),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

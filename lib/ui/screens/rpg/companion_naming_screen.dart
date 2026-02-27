// lib/ui/screens/rpg/companion_naming_screen.dart
// Screen for naming your cooking companion on first RPG activation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/companion_provider.dart';
import '../../widgets/rpg/companion_widget.dart';

// ============ COMPANION NAMING SCREEN ============

class CompanionNamingScreen extends ConsumerStatefulWidget {
  const CompanionNamingScreen({super.key});

  @override
  ConsumerState<CompanionNamingScreen> createState() =>
      _CompanionNamingScreenState();
}

class _CompanionNamingScreenState
    extends ConsumerState<CompanionNamingScreen> {
  final _nameController = TextEditingController(text: 'Ember');
  final _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _confirmName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);

    await ref.read(companionProvider.notifier).createCompanion(name);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Name Your Companion'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight -
                  48, // padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Companion preview (larger size for naming screen)
                const CompanionWidget(
                  size: 120,
                  showMessage: false,
                  interactive: false,
                ),

                const SizedBox(height: 24),

                // Title text
                Text(
                  'A small flame flickers to life...',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This ember spirit will be your cooking companion.\nGive it a name!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Name input
                TextField(
                  controller: _nameController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  maxLength: 20,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter a name...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    counterText: '',
                  ),
                  onSubmitted: (_) => _confirmName(),
                ),

                const SizedBox(height: 48),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_nameController.text.trim().isNotEmpty) {
                              _confirmName();
                            }
                          },
                    icon: const Icon(Icons.local_fire_department),
                    label: Text(
                      _isSubmitting ? 'Summoning...' : 'Summon Companion',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

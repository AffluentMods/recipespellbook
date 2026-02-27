import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/community_service.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════
//  PUBLISH SCREEN — Select cookbook to publish
// ════════════════════════════════════════════

class CommunityPublishScreen extends ConsumerStatefulWidget {
  const CommunityPublishScreen({super.key});

  @override
  ConsumerState<CommunityPublishScreen> createState() => _CommunityPublishScreenState();
}

class _CommunityPublishScreenState extends ConsumerState<CommunityPublishScreen> {
  final _community = CommunityService.instance;
  bool _publishing = false;
  String? _publishingId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final cookbooksAsync = ref.watch(cookbooksProvider);

    if (!auth.isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.communityPublishCookbook)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login, size: 48, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text(l10n.communitySignInToPublish, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.communitySignInToPublishMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.outline)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/settings'),
                  child: Text(l10n.communityGoToSettings),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityPublishCookbook)),
      body: cookbooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cookbooks) {
          if (cookbooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(l10n.communityNoCookbooksToPublish, style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      l10n.communityPublishInfo,
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                    )),
                  ],
                ),
              ),

              Text(l10n.communitySelectCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ...cookbooks.map((cb) => _CookbookPublishTile(
                cookbook: cb,
                isPublishing: _publishingId == cb.id,
                onPublish: () => _publish(cb),
              )),
            ],
          );
        },
      ),
    );
  }

  Future<void> _publish(Cookbook cookbook) async {
    if (_publishing) return;

    final l10n = AppLocalizations.of(context)!;

    // Check recipe count locally first
    final recipeCount = await ref.read(recipeDaoProvider).getRecipeCountForCookbook(cookbook.id);
    if (recipeCount < 10) {
      if (mounted) {
        AppSnackbar.error(context, l10n.communityNeedMinRecipes(recipeCount));
      }
      return;
    }

    // Confirm
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: const Icon(Icons.publish),
          title: Text(dl10n.communityPublishConfirmTitle),
          content: Text(
            dl10n.communityPublishConfirmMessage(cookbook.name, recipeCount),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(dl10n.actionCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(dl10n.communityPublish)),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() { _publishing = true; _publishingId = cookbook.id; });

    final result = await _community.publish(cookbook.id);

    if (mounted) {
      setState(() { _publishing = false; _publishingId = null; });
      if (result.success) {
        AppSnackbar.success(context, l10n.communityPublishSuccess(cookbook.name));
        context.pop();
      } else {
        AppSnackbar.error(context, result.error ?? l10n.communityPublishFailed);
      }
    }
  }
}

// ════════════════════════════════════════════
//  COOKBOOK TILE
// ════════════════════════════════════════════

class _CookbookPublishTile extends ConsumerWidget {
  final Cookbook cookbook;
  final bool isPublishing;
  final VoidCallback onPublish;

  const _CookbookPublishTile({
    required this.cookbook,
    required this.isPublishing,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<int>(
      future: ref.read(recipeDaoProvider).getRecipeCountForCookbook(cookbook.id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final canPublish = count >= 10;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.menu_book,
              color: canPublish ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            title: Text(cookbook.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              canPublish ? l10n.communityRecipeCount(count) : l10n.communityRecipeCountNeedMore(count),
              style: TextStyle(
                fontSize: 12,
                color: canPublish ? theme.colorScheme.outline : theme.colorScheme.error,
              ),
            ),
            trailing: isPublishing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : FilledButton.tonal(
              onPressed: canPublish ? onPublish : null,
              child: Text(l10n.communityPublish, style: const TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}
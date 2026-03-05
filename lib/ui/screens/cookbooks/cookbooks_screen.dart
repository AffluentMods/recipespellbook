import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/rpg/rpg_text.dart';
import '../../../database/database.dart';
import '../../../database/daos/tags_dao.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../services/family_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../shell/app_shell.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/family_share_sheet.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/recipe_image.dart';
import '../../../utils/responsive_utils.dart';

class CookbooksScreen extends ConsumerStatefulWidget {
  const CookbooksScreen({super.key});

  @override
  ConsumerState<CookbooksScreen> createState() => _CookbooksScreenState();
}

class _CookbooksScreenState extends ConsumerState<CookbooksScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cookbooksAsync = ref.watch(cookbooksProvider);
    final selectedId = ref.watch(selectedCookbookIdProvider);
    final nerdMode = ref.watch(settingsProvider).nerdMode;
    final rpg = RpgText.of(l10n, nerdMode);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(rpg.cookbooksTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchCookbooks,
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (_showSearch) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).requestFocus(_searchFocus);
                });
              } else {
                _searchController.clear();
                _query = '';
              }
            },
          ),
        ],
      ),
      body: cookbooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.errorGeneric}: $e')),
        data: (cookbooks) {
          final filtered = _query.isEmpty
              ? cookbooks
              : cookbooks.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

          return Column(
            children: [
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: l10n.searchCookbooks,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _query = '';
                        }),
                      )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              Expanded(
                child: _CookbookGrid(
                  cookbooks: filtered,
                  selectedId: selectedId,
                  onCookbookSelected: (id) {
                    ref.read(selectedCookbookIdProvider.notifier).state = id;
                    ref.read(currentNavIndexProvider.notifier).state = 0;
                    context.go('/');
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _ModernFAB(
        onPressed: () => _showNewCookbookDialog(context, ref),
        label: l10n.cookbookAdd,
      ),
    );
  }

  void _showNewCookbookDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cookbookAdd),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.recipeFieldTitle,
            hintText: l10n.cookbookNameHint,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(cookbookDaoProvider);
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                dao.insertCookbook(CookbooksCompanion.insert(
                  id: id,
                  name: controller.text.trim(),
                ));
                Navigator.pop(context);
              }
            },
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }
}

class _CookbookGrid extends ConsumerWidget {
  final List<Cookbook> cookbooks;
  final String? selectedId;
  final ValueChanged<String> onCookbookSelected;

  const _CookbookGrid({
    required this.cookbooks,
    required this.selectedId,
    required this.onCookbookSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Hint text at top - FIXED: Using Expanded + overflow handling
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.cookbookHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),

        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.cookbookColumns(context),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: cookbooks.length,
            itemBuilder: (context, index) {
              final cookbook = cookbooks[index];
              final isSelected = cookbook.id == selectedId;

              return _CookbookCard(
                cookbook: cookbook,
                isSelected: isSelected,
                onTap: () => onCookbookSelected(cookbook.id),
                onLongPress: () => _showEditSheet(context, ref, cookbook),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, Cookbook cookbook) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.actionEdit),
              subtitle: Text(l10n.cookbookEditSubtitle),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/cookbook/${cookbook.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.shareCookbook),
              subtitle: Text(l10n.shareCookbookSubtitle),
              onTap: () {
                Navigator.pop(ctx);
                _showShareSheet(context, ref, cookbook);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.actionDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(context, ref, cookbook);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, WidgetRef ref, Cookbook cookbook) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.shareNamedCookbook(cookbook.name),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),

            // ── One-Time Link ──
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.oneTimeLink),
              subtitle: Text(l10n.oneTimeLinkDescription),
              onTap: () {
                Navigator.pop(ctx);
                _createOneTimeLink(context, ref, cookbook);
              },
            ),

            // ── Family Share ──
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: Text(l10n.familyShare),
              subtitle: Text(l10n.familyShareDescription),
              trailing: _isFamilyTierUnlocked(ref)
                  ? null
                  : Icon(Icons.star, size: 16, color: Colors.amber.shade600),
              onTap: () {
                Navigator.pop(ctx);
                if (!_isFamilyTierUnlocked(ref)) {
                  _showUpgradePrompt(context, l10n.familyShare,
                      l10n.familyShareUpgradeMessage);
                  return;
                }
                showResourceShareSheet(
                  context,
                  resourceType: 'cookbook',
                  resourceId: cookbook.id,
                  resourceName: cookbook.name,
                  familyOnly: true,
                );
              },
            ),

            // ── Post to Community ──
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(l10n.postToCommunity),
              subtitle: Text(l10n.postToCommunityDescription),
              onTap: () {
                Navigator.pop(ctx);
                _publishToCommunity(context, ref, cookbook);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _createOneTimeLink(BuildContext context, WidgetRef ref, Cookbook cookbook) async {
    final auth = AuthService.instance;
    if (!auth.isSignedIn) {
      AppSnackbar.info(context, AppLocalizations.of(context)!.signInToShare);
      return;
    }

    AppSnackbar.loading(context, AppLocalizations.of(context)!.generatingLink);

    try {
      final link = await FamilyService.instance.createShareLink(
        'cookbook', cookbook.id,
      );
      if (!context.mounted) return;
      AppSnackbar.dismiss(context);

      if (link != null) {
        _showLinkResult(context, link);
      } else {
        AppSnackbar.error(context, AppLocalizations.of(context)!.failedToCreateLink);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.dismiss(context);
        AppSnackbar.error(context, 'Error: $e');
      }
    }
  }

  void _showLinkResult(BuildContext context, ShareLinkInfo link) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              Text(l10n.linkCreated, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(l10n.expiresIn24Hours, style: TextStyle(color: theme.colorScheme.outline, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Expanded(child: Text(link.url, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                      maxLines: 2, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link.url));
                      AppSnackbar.success(context, l10n.linkCopied);
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.actionDone),
                )),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: () {
                    Share.share(link.url, subject: 'Shared from Recipe Spellbook');
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: Text(l10n.actionShare),
                )),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFamilyTierUnlocked(WidgetRef ref) {
    final tier = ref.read(subscriptionProvider).tier;
    return tier.index >= SubscriptionTier.cloudSync.index;
  }

  void _showUpgradePrompt(BuildContext context, String featureName, String message) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(height: 24),
              const Icon(Icons.star, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              Text(l10n.unlockFeature(featureName),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.notNow),
                )),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: () { Navigator.pop(ctx); context.push('/upgrade'); },
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(l10n.upgradeButton),
                )),
              ]),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publishToCommunity(BuildContext context, WidgetRef ref, Cookbook cookbook) async {
    // Check recipe count locally first
    final recipeCount = await ref.read(recipeDaoProvider).getRecipeCountForCookbook(cookbook.id);
    if (recipeCount < 10) {
      if (context.mounted) {
        AppSnackbar.error(context, AppLocalizations.of(context)!.publishMinRecipes(recipeCount));
      }
      return;
    }

    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.public),
        title: Text(l10n.publishConfirmTitle),
        content: Text(l10n.publishConfirmMessage(cookbook.name, recipeCount)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.publishButton)),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Build inline recipe data from local DB
    final recipeDao = ref.read(recipeDaoProvider);
    final tagsDao = TagsDao(ref.read(databaseProvider));
    final recipes = await recipeDao.getRecipesForCookbook(cookbook.id);

    final recipeMaps = <Map<String, dynamic>>[];
    for (final r in recipes) {
      final ingredients = await recipeDao.getIngredientsForRecipe(r.id);
      final steps = await recipeDao.getStepsForRecipe(r.id);
      final tags = await tagsDao.getTagsForRecipe(r.id);

      recipeMaps.add({
        'title': r.title,
        'description': r.description,
        'servings': r.servings,
        'prepTimeMinutes': r.prepTimeMinutes,
        'cookTimeMinutes': r.cookTimeMinutes,
        'sourceUrl': r.sourceUrl,
        'imagePath': r.imagePath,
        'rating': r.rating,
        'notes': r.notes,
        'nutritionJson': r.nutritionJson,
        'ingredients': ingredients.map((i) => {
          'sortOrder': i.sortOrder,
          'amount': i.amount,
          'unit': i.unit,
          'name': i.name,
          'notes': i.notes,
        }).toList(),
        'steps': steps.map((s) => {
          'sortOrder': s.sortOrder,
          'instruction': s.instruction,
          'durationMinutes': s.durationMinutes,
        }).toList(),
        'tags': tags.map((t) => t.name).toList(),
      });
    }

    if (!context.mounted) return;

    final result = await CommunityService.instance.publish(
      title: cookbook.name,
      description: cookbook.description,
      imagePath: cookbook.imagePath,
      recipes: recipeMaps,
    );
    if (context.mounted) {
      if (result.success) {
        AppSnackbar.success(context, '"${cookbook.name}" published to the community!');
      } else {
        AppSnackbar.error(context, result.error ?? 'Publish failed');
      }
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Cookbook cookbook) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: cookbook.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameCookbook),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.recipeFieldTitle),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // Use proper Drift companion for update
                ref.read(cookbookDaoProvider).updateCookbookName(
                  cookbook.id,
                  controller.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Cookbook cookbook) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cookbookDelete),
        content: Text(l10n.cookbookDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              ref.read(cookbookDaoProvider).deleteCookbook(cookbook.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

class _CookbookCard extends StatelessWidget {
  final Cookbook cookbook;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CookbookCard({
    required this.cookbook,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 3)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            // Cover image or placeholder
            Positioned.fill(
              child: cookbook.imagePath != null &&
                  cookbook.imagePath!.isNotEmpty &&
                  FileExistsCache.exists(cookbook.imagePath!)
                  ? Image.file(File(cookbook.imagePath!), fit: BoxFit.cover,
                      cacheWidth: 400, cacheHeight: 400)
                  : const CookbookPlaceholderImage(height: double.infinity),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Name and count
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cookbook.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Selected indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            // Edit button (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => context.push('/cookbook/${cookbook.id}/edit'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════
// MODERN FAB
// ═══════════════════════════════════════════════════════════════════

class _ModernFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final IconData icon;
  const _ModernFAB({required this.onPressed, this.label, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final fg = theme.colorScheme.onPrimary;

    if (label != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(icon, size: 22),
          label: Text(label!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, size: 26),
      ),
    );
  }
}
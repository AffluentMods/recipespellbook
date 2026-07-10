import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../data/course_category_data.dart';
import '../../../data/nutrition_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/collab_service.dart';
import '../../../services/family_service.dart';
import '../../../services/image_service.dart';
import '../../../services/sync_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/macro_ring.dart';

const _shareApiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');

/// Displays shared content from a `/s/:code` link.
/// Fetches the data from the backend and renders it like a real recipe page,
/// with a one-tap save into a chosen cookbook.
class ShareViewerScreen extends ConsumerStatefulWidget {
  final String code;
  const ShareViewerScreen({super.key, required this.code});

  @override
  ConsumerState<ShareViewerScreen> createState() => _ShareViewerScreenState();
}

class _ShareViewerScreenState extends ConsumerState<ShareViewerScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  String _shareImageUrl(String serverPath) =>
      '$_shareApiUrl/v1/web/images/share/${widget.code}/$serverPath';

  @override
  void initState() {
    super.initState();
    _fetchShareData();
  }

  Future<void> _fetchShareData() async {
    try {
      final uri = Uri.parse('$_shareApiUrl/v1/share/${widget.code}');
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _loading = false;
        });
      } else if (response.statusCode == 404 || response.statusCode == 410) {
        setState(() {
          _error = 'expired';
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'failed';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'no_connection';
          _loading = false;
        });
      }
    }
  }

  /// Normalize both share shapes (single `recipe`, cookbook `recipes[]`) to a list.
  List<Map<String, dynamic>> get _recipes {
    if (_data?['recipe'] != null) return [Map<String, dynamic>.from(_data!['recipe'])];
    final list = (_data?['recipes'] as List?) ?? const [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final recipes = _recipes;
    final isCookbookCollab = !_loading && _error == null &&
        _data?['type'] == 'cookbook' && _data?['kind'] == 'collab';
    final showSaveBar = !_loading && _error == null && recipes.length == 1 && !isCookbookCollab;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareViewerSharedRecipe),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Responsive.constrainWidth(context, child: _buildBody(theme, recipes)),
      bottomNavigationBar: isCookbookCollab
          ? _joinCookbookBar()
          : (showSaveBar ? _saveBar(recipes.first) : null),
    );
  }

  Widget _joinCookbookBar() {
    final cb = (_data?['cookbook'] as Map?) ?? const {};
    final name = (cb['name'] as String?) ?? 'this cookbook';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _joinCollabCookbook,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.group_add_rounded),
            label: Text('Join "$name"'),
          ),
        ),
      ),
    );
  }

  Future<void> _joinCollabCookbook() async {
    if (!AuthService.instance.isSignedIn) {
      AppSnackbar.info(context, 'Sign in to collaborate on this cookbook');
      return;
    }
    setState(() => _saving = true);
    final res = await FamilyService.instance.joinShareLink(widget.code);
    if (!mounted) return;
    if (res == null) {
      setState(() => _saving = false);
      AppSnackbar.error(context, "Couldn't join — the invite may be invalid, expired, or need a subscription.");
      return;
    }
    final owner = _data?['sharedBy'] as Map?;
    await CollabService.instance.markCollabCookbook(
      res.resourceId, res.permission,
      ownerId: owner?['id'] as String?,
      ownerName: owner?['name'] as String?,
      ownerAvatarUrl: owner?['avatarUrl'] as String?,
    );
    // Hydrate the full cookbook + recipes now (bypasses the sync `since` cursor
    // so a cookbook older than our last sync still shows up).
    await SyncService.instance.pullSharedNow();
    if (!mounted) return;
    setState(() => _saving = false);
    ref.read(selectedCookbookIdProvider.notifier).state = res.resourceId;
    AppSnackbar.success(context, "Joined! It's in your cookbooks.");
    context.go('/');
  }

  Widget _saveBar(Map<String, dynamic> recipe) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : () => _promptSave(recipe),
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.bookmark_add_outlined),
            label: Text(l10n.communitySaveRecipe),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<Map<String, dynamic>> recipes) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      String errorText;
      switch (_error) {
        case 'expired': errorText = l10n.shareViewerExpired; break;
        case 'no_connection': errorText = l10n.shareViewerNoConnection; break;
        default: errorText = l10n.shareViewerFailed;
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(errorText, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: Text(l10n.shareViewerGoHome),
              ),
            ],
          ),
        ),
      );
    }

    final sharedBy = _data?['sharedBy']?['name'] ?? 'Someone';
    final avatarUrl = _data?['sharedBy']?['avatarUrl'] as String?;
    final expiresAt = _data?['expiresAt'] != null ? DateTime.tryParse(_data!['expiresAt']) : null;

    // Shopping-list shares (collab invite or a one-time copy).
    if (_data?['type'] == 'shopping_list') {
      return _buildShoppingList(theme, sharedBy, avatarUrl);
    }

    final single = recipes.length == 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _sharedByBanner(theme, sharedBy, avatarUrl, expiresAt),
        const SizedBox(height: 16),
        if (single)
          _FullRecipeView(recipe: recipes.first, imageUrlFn: _shareImageUrl)
        else ...[
          Text(
            l10n.shareViewerRecipeCount(recipes.length),
            style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          ...recipes.map((r) => _MultiRecipeTile(
                recipe: r,
                imageUrlFn: _shareImageUrl,
                saving: _saving,
                onSave: () => _promptSave(r),
              )),
        ],
      ],
    );
  }

  Widget _buildShoppingList(ThemeData theme, String sharedBy, String? avatarUrl) {
    final sl = (_data?['shoppingList'] as Map?) ?? const {};
    final items = (_data?['items'] as List?) ?? const [];
    final isCollab = _data?['kind'] == 'collab';
    final name = (sl['name'] as String?) ?? 'Shopping list';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _sharedByBanner(theme, sharedBy, avatarUrl, null),
              const SizedBox(height: 16),
              Row(children: [
                Icon(Icons.shopping_cart_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 4),
              Text(
                '${items.length} item${items.length == 1 ? '' : 's'}'
                '${isCollab ? ' · live collaboration' : ''}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 16),
              for (final raw in items)
                Builder(builder: (_) {
                  final it = raw as Map;
                  final qty = [it['quantity'], it['unit']]
                      .where((e) => e != null && '$e'.isNotEmpty)
                      .join(' ');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(children: [
                      Icon(it['isChecked'] == true ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 18, color: theme.colorScheme.outline),
                      const SizedBox(width: 10),
                      Expanded(child: Text((it['name'] as String?) ?? '', style: theme.textTheme.bodyLarge)),
                      if (qty.isNotEmpty)
                        Text(qty, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                    ]),
                  );
                }),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : (isCollab ? _joinCollabList : _importSnapshotList),
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(isCollab ? Icons.group_add_rounded : Icons.playlist_add_rounded),
                label: Text(isCollab ? 'Join this list' : 'Add to my lists'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _joinCollabList() async {
    if (!AuthService.instance.isSignedIn) {
      AppSnackbar.info(context, 'Sign in to join this list');
      return;
    }
    setState(() => _saving = true);
    final res = await FamilyService.instance.joinShareLink(widget.code);
    if (!mounted) return;
    setState(() => _saving = false);
    if (res == null) {
      AppSnackbar.error(context, "Couldn't join — the invite may be invalid, expired, or need a subscription.");
      return;
    }
    await CollabService.instance.markCollab(res.resourceId, res.permission);
    await CollabService.instance.syncNow();
    if (!mounted) return;
    AppSnackbar.success(context, "Joined! It's in your Shopping tab.");
    context.go('/shopping');
  }

  Future<void> _importSnapshotList() async {
    final db = ref.read(databaseProvider);
    setState(() => _saving = true);
    try {
      final sl = (_data?['shoppingList'] as Map?) ?? const {};
      final items = (_data?['items'] as List?) ?? const [];
      final base = DateTime.now().microsecondsSinceEpoch;
      final newListId = 'list_shr_$base';
      await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(
        id: newListId,
        name: (sl['name'] as String?) ?? 'Shared list',
        color: drift.Value(sl['color'] as String?),
      ));
      var i = 0;
      for (final raw in items) {
        final it = raw as Map;
        await db.into(db.shoppingListItems).insert(ShoppingListItemsCompanion.insert(
          id: 'item_shr_${base}_${i++}',
          listId: newListId,
          name: (it['name'] as String?) ?? '',
          quantity: drift.Value(it['quantity'] as String?),
          unit: drift.Value(it['unit'] as String?),
          isChecked: drift.Value(it['isChecked'] as bool? ?? false),
          note: drift.Value(it['note'] as String?),
          sortOrder: drift.Value((it['sortOrder'] as num?)?.toInt() ?? 0),
        ));
      }
      if (mounted) {
        AppSnackbar.success(context, 'Added to your lists');
        context.go('/shopping');
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Import failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _sharedByBanner(ThemeData theme, String sharedBy, String? avatarUrl, DateTime? expiresAt) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? Icon(Icons.person, size: 18, color: theme.colorScheme.onPrimaryContainer)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.shareViewerSharedBy(sharedBy),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (expiresAt != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              l10n.shareViewerExpires(_formatExpiry(expiresAt, l10n)),
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onTertiaryContainer),
            ),
          ),
      ],
    );
  }

  String _formatExpiry(DateTime expiry, AppLocalizations l10n) {
    final diff = expiry.difference(DateTime.now());
    if (diff.inHours > 0) return l10n.shareViewerHoursRemaining(diff.inHours);
    if (diff.inMinutes > 0) return l10n.shareViewerMinutesRemaining(diff.inMinutes);
    return l10n.shareViewerExpiredLabel;
  }

  /// Let the user choose which cookbook to save the shared recipe into.
  Future<void> _promptSave(Map<String, dynamic> recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? const [];
    if (cookbooks.length <= 1) {
      await _saveRecipe(recipe, cookbooks.isNotEmpty ? cookbooks.first.id : 'starter');
      return;
    }
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.communitySaveRecipeTo((recipe['title'] as String?) ?? ''),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: cookbooks
                    .map((c) => ListTile(
                          leading: const Icon(Icons.menu_book_rounded),
                          title: Text(c.name),
                          onTap: () => Navigator.pop(ctx, c.id),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) await _saveRecipe(recipe, chosen);
  }

  /// Import a shared recipe into [cookbookId], downloading its photos from the
  /// share so the saved copy keeps them.
  Future<void> _saveRecipe(Map<String, dynamic> recipe, String cookbookId) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final images = ImageService.instance;
    setState(() => _saving = true);
    try {
      final mainId = await _insertSnapshot(db, images, recipe, cookbookId, 'main');

      // Linked sub-recipes travel with the share — recreate them + wire links.
      // Keyed on each sub's stable snapshot id (not its title, which isn't unique).
      final linked = (recipe['linkedRecipes'] as List?) ?? const [];
      final snapIdToNewId = <String, String>{};
      for (var s = 0; s < linked.length; s++) {
        final m = Map<String, dynamic>.from(linked[s] as Map);
        final newSubId = await _insertSnapshot(db, images, m, cookbookId, 's$s');
        final origId = (m['id'] as String?) ?? '';
        if (origId.isNotEmpty) snapIdToNewId[origId] = newSubId;
      }

      final links = (recipe['links'] as List?) ?? const [];
      if (links.isNotEmpty && snapIdToNewId.isNotEmpty) {
        final mainIngs =
            await (db.select(db.ingredients)..where((t) => t.recipeId.equals(mainId))).get();
        await db.transaction(() async {
          for (final raw in links) {
            final l = raw as Map;
            final ingName = (l['ingredientName'] as String?)?.toLowerCase().trim();
            final newSubId = snapIdToNewId[(l['subId'] as String?) ?? ''];
            if (ingName == null || ingName.isEmpty || newSubId == null) continue;
            final matches = mainIngs.where((i) => i.name.toLowerCase().trim() == ingName);
            if (matches.isEmpty) continue;
            await db.into(db.recipeLinks).insertOnConflictUpdate(RecipeLinksCompanion.insert(
              sourceRecipeId: mainId,
              ingredientId: matches.first.id,
              linkedRecipeId: newSubId,
            ));
          }
        });
      }

      if (mounted) {
        AppSnackbar.success(context, l10n.communityRecipeSaved((recipe['title'] as String?) ?? ''));
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, l10n.communityFailedToSave(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Insert one snapshot recipe (downloading its photos) and return its new id.
  Future<String> _insertSnapshot(
    AppDatabase db,
    ImageService images,
    Map<String, dynamic> recipe,
    String cookbookId,
    String idSuffix,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final id = 'shr_${DateTime.now().millisecondsSinceEpoch}_$idSuffix';

    String? coverLocal;
    final coverServer = recipe['imagePath'] as String?;
    if (coverServer != null && coverServer.isNotEmpty) {
      coverLocal = await images.downloadAndSaveImage(_shareImageUrl(coverServer), '${id}_cover.jpg');
    }
    final steps = (recipe['steps'] as List?) ?? [];
    final stepLocal = <int, String?>{};
    for (var i = 0; i < steps.length; i++) {
      final sp = steps[i]['imagePath'] as String?;
      if (sp != null && sp.isNotEmpty) {
        stepLocal[i] = await images.downloadAndSaveImage(_shareImageUrl(sp), '${id}_step_$i.jpg');
      }
    }
    final ings = (recipe['ingredients'] as List?) ?? [];

    await db.transaction(() async {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
        id: id,
        cookbookId: cookbookId,
        title: (recipe['title'] as String?) ?? l10n.shareViewerUntitled,
        description: drift.Value(recipe['description'] as String?),
        servings: drift.Value(recipe['servings'] as String?),
        prepTimeMinutes: drift.Value((recipe['prepTimeMinutes'] as num?)?.toInt()),
        cookTimeMinutes: drift.Value((recipe['cookTimeMinutes'] as num?)?.toInt()),
        sourceUrl: drift.Value(recipe['sourceUrl'] as String?),
        courseId: drift.Value(recipe['courseId'] as String?),
        categoryId: drift.Value(recipe['categoryId'] as String?),
        rating: drift.Value((recipe['rating'] as num?)?.toInt()),
        notes: drift.Value(recipe['notes'] as String?),
        nutritionJson: drift.Value(recipe['nutritionJson'] as String?),
        imagePath: drift.Value(coverLocal),
        lastViewedAt: drift.Value(DateTime.now()),
      ));
      for (var i = 0; i < ings.length; i++) {
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: '${id}_ing_$i',
          recipeId: id,
          sortOrder: (ings[i]['sortOrder'] as num?)?.toInt() ?? i,
          name: (ings[i]['name'] as String?) ?? '',
          amount: drift.Value(ings[i]['amount'] as String?),
          unit: drift.Value(ings[i]['unit'] as String?),
          notes: drift.Value(ings[i]['notes'] as String?),
        ));
      }
      for (var i = 0; i < steps.length; i++) {
        await db.into(db.steps).insert(StepsCompanion.insert(
          id: '${id}_step_$i',
          recipeId: id,
          sortOrder: (steps[i]['sortOrder'] as num?)?.toInt() ?? i,
          instruction: (steps[i]['instruction'] as String?) ?? '',
          durationMinutes: drift.Value((steps[i]['durationMinutes'] as num?)?.toInt()),
          notes: drift.Value(steps[i]['notes'] as String?),
          imagePath: drift.Value(stepLocal[i]),
        ));
      }
    });
    return id;
  }
}

/// One shared recipe, rendered full (no collapse) like the app's recipe page.
class _FullRecipeView extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String Function(String) imageUrlFn;

  const _FullRecipeView({required this.recipe, required this.imageUrlFn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = (recipe['title'] as String?) ?? l10n.shareViewerUntitled;
    final description = recipe['description'] as String?;
    final coverPath = recipe['imagePath'] as String?;
    final ingredients = (recipe['ingredients'] as List?) ?? const [];
    final steps = (recipe['steps'] as List?) ?? const [];
    final notes = recipe['notes'] as String?;
    final nutrition = _parseNutrition(recipe['nutritionJson']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coverPath != null && coverPath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrlFn(coverPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

        Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),

        // Course / category emoji chips
        _taxonomyChips(context),

        // Meta chips (prep/cook/total/servings/rating)
        _metaChips(context),

        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],

        if (nutrition != null && _hasMacros(nutrition)) ...[
          const SizedBox(height: 20),
          _sectionTitle(context, l10n.nutritionTitle),
          const SizedBox(height: 12),
          _nutritionBlock(context, nutrition),
        ],

        if (ingredients.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle(context, l10n.ingredientsTitle),
          const SizedBox(height: 8),
          ...ingredients.map((ing) => _ingredientRow(context, ing as Map)),
        ],

        if (steps.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle(context, l10n.instructionsTitle),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => _stepRow(context, e.key + 1, e.value as Map)),
        ],

        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle(context, l10n.notesTitle),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 3)),
            ),
            child: Text(notes, style: theme.textTheme.bodyMedium),
          ),
        ],

        if (((recipe['linkedRecipes'] as List?) ?? const []).isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle(context, 'Included recipes'),
          const SizedBox(height: 8),
          ...(recipe['linkedRecipes'] as List).map((sub) => _LinkedRecipeTile(
                recipe: Map<String, dynamic>.from(sub as Map),
                imageUrlFn: imageUrlFn,
              )),
        ],
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _taxonomyChips(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[];
    final course = CourseData.getById((recipe['courseId'] as String?) ?? '');
    final category = CategoryData.getById((recipe['categoryId'] as String?) ?? '');
    for (final t in [
      if (course != null) (course.emoji, course.name),
      if (category != null) (category.emoji, category.name),
    ]) {
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.$1, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(t.$2, style: theme.textTheme.labelMedium),
          ],
        ),
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _metaChips(BuildContext context) {
    final prep = (recipe['prepTimeMinutes'] as num?)?.toInt();
    final cook = (recipe['cookTimeMinutes'] as num?)?.toInt();
    final total = (prep ?? 0) + (cook ?? 0);
    final servings = (recipe['servings'] as String?)?.trim();
    final rating = (recipe['rating'] as num?)?.toInt();

    final chips = <Widget>[
      if (prep != null && prep > 0) _metaChip(context, Icons.schedule, _fmtTime(prep)),
      if (cook != null && cook > 0) _metaChip(context, Icons.local_fire_department, _fmtTime(cook)),
      if (total > 0) _metaChip(context, Icons.timer_outlined, _fmtTime(total)),
      if (servings != null && servings.isNotEmpty) _metaChip(context, Icons.people_outline, servings),
      if (rating != null && rating > 0) _metaChip(context, Icons.star_rounded, '$rating'),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _nutritionBlock(BuildContext context, NutritionData n) {
    final l10n = AppLocalizations.of(context)!;
    final div = (n.calculatedServings != null && n.calculatedServings! > 0) ? n.calculatedServings! : 1;
    double? per(double? v) => v == null ? null : v / div;

    final secondary = <(String, double, String)>[
      if (n.fiber != null) ('Fiber', per(n.fiber)!, 'g'),
      if (n.sugar != null) ('Sugar', per(n.sugar)!, 'g'),
      if (n.saturatedFat != null) ('Sat. Fat', per(n.saturatedFat)!, 'g'),
      if (n.sodium != null) ('Sodium', per(n.sodium)!, 'mg'),
      if (n.cholesterol != null) ('Cholesterol', per(n.cholesterol)!, 'mg'),
      if (n.potassium != null) ('Potassium', per(n.potassium)!, 'mg'),
    ];

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MacroRing(
          calories: per(n.calories) ?? 0,
          protein: per(n.protein) ?? 0,
          carbs: per(n.carbohydrates) ?? 0,
          fat: per(n.fat) ?? 0,
          caption: div > 1 ? l10n.perServing : null,
        ),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: secondary
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: '${s.$1}  ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                        TextSpan(
                          text: '${_fmtNum(s.$2)} ${s.$3}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ])),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _ingredientRow(BuildContext context, Map ing) {
    final theme = Theme.of(context);
    final name = (ing['name'] as String?) ?? '';
    final notes = ing['notes'] as String?;

    // Section header row (display-only divider stored with notes == '__header__').
    if (notes == '__header__') {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    final amount = (ing['amount'] as String?)?.trim() ?? '';
    final unit = (ing['unit'] as String?)?.trim() ?? '';
    final measure = [amount, unit].where((s) => s.isNotEmpty).join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (measure.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 64),
              child: Text(
                measure,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            )
          else
            const SizedBox(width: 64),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: name, style: theme.textTheme.bodyMedium),
              if (notes != null && notes.isNotEmpty)
                TextSpan(
                  text: '  ($notes)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.outline,
                  ),
                ),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(BuildContext context, int number, Map step) {
    final theme = Theme.of(context);
    final instruction = (step['instruction'] as String?) ?? '';
    final duration = (step['durationMinutes'] as num?)?.toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(instruction, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
                if (duration != null && duration > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.timer_outlined, size: 14, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 4),
                      Text(_fmtTime(duration),
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.tertiary)),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact expandable card for cookbook (multi-recipe) shares.
class _MultiRecipeTile extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String Function(String) imageUrlFn;
  final VoidCallback onSave;
  final bool saving;

  const _MultiRecipeTile({
    required this.recipe,
    required this.imageUrlFn,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = (recipe['title'] as String?) ?? l10n.shareViewerUntitled;
    final course = CourseData.getById((recipe['courseId'] as String?) ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Text(course?.emoji ?? '🍽️', style: const TextStyle(fontSize: 22)),
          title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _FullRecipeView(recipe: recipe, imageUrlFn: imageUrlFn),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.bookmark_add_outlined),
                label: Text(l10n.communitySaveRecipe),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- helpers ----

bool _hasMacros(NutritionData n) =>
    (n.calories ?? 0) > 0 || (n.protein ?? 0) > 0 || (n.carbohydrates ?? 0) > 0 || (n.fat ?? 0) > 0;

NutritionData? _parseNutrition(dynamic raw) {
  if (raw == null) return null;
  try {
    final decoded = raw is String ? jsonDecode(raw) : raw;
    if (decoded is Map) return NutritionData.fromJson(Map<String, dynamic>.from(decoded));
  } catch (_) {}
  return null;
}

String _fmtTime(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

String _fmtNum(double v) {
  if (v >= 100) return v.round().toString();
  final s = v >= 10 ? v.toStringAsFixed(1) : v.toStringAsFixed(2);
  return s.contains('.') ? s.replaceAll(RegExp(r'\.?0+$'), '') : s;
}

/// A collapsible card for a sub-recipe bundled inside a shared recipe.
class _LinkedRecipeTile extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String Function(String) imageUrlFn;
  const _LinkedRecipeTile({required this.recipe, required this.imageUrlFn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (recipe['title'] as String?) ?? 'Recipe';
    final course = CourseData.getById((recipe['courseId'] as String?) ?? '');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Text(course?.emoji ?? '🍽️', style: const TextStyle(fontSize: 20)),
          title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [_FullRecipeView(recipe: recipe, imageUrlFn: imageUrlFn)],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/imported_recipe.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/clip_importer.dart';
import '../../../utils/clip_request.dart';
import '../../widgets/new_recipe_dialog.dart' show friendlyImportError;
import '../book_scan/book_scan_entry.dart' show canAddRecipesTo;
import '../book_scan/book_scan_widgets.dart' show showScanCookbookPicker;
import 'import_preview_screen.dart';

/// The route the browser extension's clip links open (see [ClipRequest]),
/// on [parentNavigatorKey] when given.
GoRoute clipImportRoute({GlobalKey<NavigatorState>? parentNavigatorKey}) => GoRoute(
      path: ClipRequest.path,
      name: 'clip',
      parentNavigatorKey: parentNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        fullscreenDialog: true,
        child: ClipImportScreen(clip: ClipRequest.fromParameters(state.uri.queryParameters)),
      ),
    );

/// Imports a recipe page sent from the browser extension: reads the recipe,
/// asks which cookbook it goes to when there is a choice, then shows the
/// usual import preview.
class ClipImportScreen extends ConsumerStatefulWidget {
  /// Null when the link could not be read.
  final ClipRequest? clip;

  const ClipImportScreen({super.key, required this.clip});

  @override
  ConsumerState<ClipImportScreen> createState() => _ClipImportScreenState();
}

class _ClipImportScreenState extends ConsumerState<ClipImportScreen> {
  ImportedRecipe? _recipe;
  String? _cookbookId;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final clip = widget.clip;
    if (clip == null) {
      setState(() => _error = l10n.addRecipeLinkUnreadable);
      return;
    }

    final ImportedRecipe recipe;
    try {
      recipe = await ClipImporter.load(clip);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyImportError(e, l10n));
      return;
    }
    if (!mounted) return;
    if (!hasRecipeContent(recipe)) {
      setState(() => _error = l10n.importNoRecipeAtLink);
      return;
    }

    final String? cookbookId;
    try {
      cookbookId = await _chooseCookbook(l10n);
    } catch (e) {
      if (mounted) setState(() => _error = l10n.addRecipeLinkUnreadable);
      return;
    }
    if (!mounted || _error != null) return;
    if (cookbookId == null) {
      // Backed out of the choice.
      _close();
      return;
    }
    setState(() {
      _recipe = recipe;
      _cookbookId = cookbookId;
    });
  }

  /// The cookbook the recipe goes to: the only one recipes can be added to,
  /// or the one the user picks. Null when the user backs out.
  Future<String?> _chooseCookbook(AppLocalizations l10n) async {
    final cookbooks = [
      for (final cookbook in await ref.read(cookbookDaoProvider).getAllCookbooks())
        if (canAddRecipesTo(cookbook.id)) cookbook,
    ];
    if (!mounted) return null;
    if (cookbooks.isEmpty) {
      setState(() => _error = l10n.clipNoCookbook);
      return null;
    }
    if (cookbooks.length == 1) return cookbooks.single.id;

    // The cookbook open in the app comes first.
    String? current;
    try {
      current = ref.read(selectedCookbookIdProvider);
    } catch (_) {}
    final ordered = <Cookbook>[
      ...cookbooks.where((c) => c.id == current),
      ...cookbooks.where((c) => c.id != current),
    ];
    final chosen = await showScanCookbookPicker(
      context,
      cookbooks: ordered,
      title: l10n.clipChooseCookbookTitle,
      message: l10n.clipChooseCookbookMessage,
    );
    return chosen?.id;
  }

  void _close() {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    final cookbookId = _cookbookId;
    if (recipe != null && cookbookId != null) {
      return ImportPreviewScreen(
        recipes: [recipe],
        cookbookId: cookbookId,
        sourceUrl: widget.clip?.url,
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final error = _error;
    final title = widget.clip?.title;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.clipScreenTitle)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (error == null) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(l10n.importingRecipe, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                  ] else ...[
                    Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(error, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
                  ],
                  if (title != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 24),
                    FilledButton(onPressed: _close, child: Text(l10n.actionClose)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

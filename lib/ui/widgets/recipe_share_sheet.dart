import 'dart:convert';
import '../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../services/auth_service.dart';
import '../../services/family_service.dart';
import '../../services/image_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'app_snackbar.dart';
import '../../utils/responsive_utils.dart';

/// Strip emoji characters that even Unicode fonts struggle with in PDFs.
String _stripEmojiForPdf(String text) {
  return text.replaceAll(RegExp(
    r'[\u{1F000}-\u{1FFFF}]|[\u{FE00}-\u{FE0F}]|'
    r'[\u{200D}]|[\u{20E3}]|[\u{E0020}-\u{E007F}]',
    unicode: true,
  ), '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

/// Cached Unicode fonts for PDF rendering.
pw.Font? _pdfRegular;
pw.Font? _pdfBold;
pw.Font? _pdfItalic;
pw.Font? _pdfBoldItalic;

/// Load Noto Sans fonts for full Unicode support in PDFs.
Future<pw.ThemeData> _loadPdfTheme() async {
  try {
    _pdfRegular ??= await PdfGoogleFonts.notoSansRegular();
    _pdfBold ??= await PdfGoogleFonts.notoSansBold();
    _pdfItalic ??= await PdfGoogleFonts.notoSansItalic();
    _pdfBoldItalic ??= await PdfGoogleFonts.notoSansBoldItalic();

    return pw.ThemeData.withFont(
      base: _pdfRegular!,
      bold: _pdfBold!,
      italic: _pdfItalic!,
      boldItalic: _pdfBoldItalic!,
    );
  } catch (_) {
    return pw.ThemeData.base();
  }
}

/// Shows a share sheet for a recipe with multiple options
void showRecipeShareSheet(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
    ) {
  Responsive.showAdaptiveSheet(
    context,
    builder: (ctx) => _RecipeShareSheet(recipe: recipe, ref: ref),
  );
}

class _RecipeShareSheet extends StatelessWidget {
  final Recipe recipe;
  final WidgetRef ref;

  const _RecipeShareSheet({required this.recipe, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: context.appColors.textPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.shareRecipe,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              recipe.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Share options — scrollable to prevent overflow on narrow screens
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(
                    icon: Icons.link,
                    label: l10n.shareLink,
                    onTap: () => _shareLink(context),
                  ),
                  _ShareOption(
                    icon: Icons.text_fields,
                    label: l10n.shareAsText,
                    onTap: () => _shareAsText(context),
                  ),
                  _ShareOption(
                    icon: Icons.file_copy,
                    label: l10n.shareAsFile,
                    onTap: () => _exportRecipe(context),
                  ),
                  _ShareOption(
                    icon: Icons.picture_as_pdf,
                    label: l10n.shareDocument,
                    onTap: () => _shareAsDocument(context),
                  ),
                  _ShareOption(
                    icon: Icons.print,
                    label: l10n.sharePrint,
                    onTap: () => _printRecipe(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _shareLink(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // A share link needs an account (it hosts a 24h copy of the recipe). If the
    // user isn't signed in, prompt sign-in — not a useless title-only share.
    if (!AuthService.instance.isSignedIn) {
      _promptSignIn(context);
      return;
    }

    Navigator.pop(context);

    // Loading shows on the ROOT overlay and dismiss() is context-independent
    // (static), so we must NOT guard dismiss on context.mounted — the share
    // sheet's context unmounts once we pop it, which would otherwise leave the
    // spinner stuck for its full 30s timeout.
    AppSnackbar.loading(context, l10n.generatingLink);

    ShareLinkInfo? link;
    try {
      // Cap the whole thing so a slow/unresponsive server can never leave the
      // spinner stuck — fall back to a plain share instead.
      final snapshot = await _buildSnapshot().timeout(const Duration(seconds: 45));
      link = await FamilyService.instance
          .createShareLink('recipe', recipe.id, snapshot: snapshot)
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      debugPrint('[Share] link generation failed: $e');
    } finally {
      AppSnackbar.dismiss(context);
    }

    if (link != null) {
      // share_plus rejects uri + text together — send the link inside the text
      // so the title comes along with it.
      SharePlus.instance.share(ShareParams(
        text: '${recipe.title}\n${link.url}',
        subject: recipe.title,
      ));
      return;
    }

    // Signed in but link creation failed — degrade to the source URL if we have
    // one, otherwise a plain title share.
    final hasSourceUrl = recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty;
    SharePlus.instance.share(ShareParams(
      text: hasSourceUrl
          ? '${recipe.title}\n${recipe.sourceUrl!}'
          : '${recipe.title}\n\n${l10n.shareFromApp}',
      subject: recipe.title,
    ));
  }

  /// Prompt sign-in (Google / Apple) so the user can create a share link.
  void _promptSignIn(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 24),
            Icon(Icons.ios_share, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.signInToContinue, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.shareSignInRequired,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async { Navigator.pop(ctx); await authNotifier.signInWithGoogle(); },
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
                  onPressed: () async { Navigator.pop(ctx); await authNotifier.signInWithApple(); },
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build a self-contained snapshot of this recipe for a share link, uploading
  /// its local photos to the server (best-effort) so the shared copy shows
  /// images. A failed image upload just leaves that image null (text still works).
  Future<Map<String, dynamic>> _buildSnapshot() async {
    final dao = ref.read(recipeDaoProvider);
    final images = ImageService.instance;

    Future<String?> upload(String? path) async {
      if (path == null || path.isEmpty) return null;
      try {
        final r = await images
            .communityUploadLocalPath(path)
            .timeout(const Duration(seconds: 20));
        return r?.path;
      } catch (e) {
        debugPrint('[Share] image upload skipped: $e');
        return null; // best-effort: recipe still shares without this photo
      }
    }

    // Snapshot one recipe (ingredients, steps, uploaded images).
    Future<Map<String, dynamic>> snapOne(Recipe r) async {
      final ings = await dao.getIngredientsForRecipe(r.id);
      final steps = await dao.getStepsForRecipe(r.id);
      final coverPath = await upload(r.imagePath);
      final stepPaths = <String, String?>{};
      for (final s in steps) {
        stepPaths[s.id] = await upload(s.imagePath);
      }
      return {
        'id': r.id,
        'title': r.title,
        'description': r.description,
        'servings': r.servings,
        'prepTimeMinutes': r.prepTimeMinutes,
        'cookTimeMinutes': r.cookTimeMinutes,
        'sourceUrl': r.sourceUrl,
        'imagePath': coverPath,
        'courseId': r.courseId,
        'categoryId': r.categoryId,
        'rating': r.rating,
        'notes': r.notes,
        'nutritionJson': r.nutritionJson,
        'ingredients': ings
            .map((i) => {
                  'sortOrder': i.sortOrder,
                  'amount': i.amount,
                  'unit': i.unit,
                  'name': i.name,
                  'notes': i.notes,
                })
            .toList(),
        'steps': steps
            .map((s) => {
                  'sortOrder': s.sortOrder,
                  'instruction': s.instruction,
                  'durationMinutes': s.durationMinutes,
                  'notes': s.notes,
                  'imagePath': stepPaths[s.id],
                })
            .toList(),
      };
    }

    final snapshot = await snapOne(recipe);

    // Include up to 6 linked sub-recipes so the shared copy is self-contained.
    final ings = await dao.getIngredientsForRecipe(recipe.id);
    final ingIdToName = {for (final i in ings) i.id: i.name};
    final linkMap = await dao.getIngredientLinksMap(recipe.id);
    final subs = <String, Recipe>{};
    final links = <Map<String, dynamic>>[];
    for (final entry in linkMap.entries) {
      final ingName = ingIdToName[entry.key];
      for (final info in entry.value) {
        subs[info.recipe.id] = info.recipe;
        links.add({'ingredientName': ingName, 'title': info.recipe.title, 'subId': info.recipe.id});
      }
    }
    final capped = subs.values.take(6).toList();
    if (capped.isNotEmpty) {
      final linkedSnaps = <Map<String, dynamic>>[];
      for (final sub in capped) {
        linkedSnaps.add(await snapOne(sub));
      }
      final cappedIds = capped.map((r) => r.id).toSet();
      snapshot['linkedRecipes'] = linkedSnaps;
      snapshot['links'] = links.where((l) => cappedIds.contains(l['subId'])).toList();
    }

    return snapshot;
  }

  Future<void> _shareAsText(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    final dao = ref.read(recipeDaoProvider);
    final ingredients = await dao.getIngredientsForRecipe(recipe.id);
    final steps = await dao.getStepsForRecipe(recipe.id);
    final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

    final buffer = StringBuffer();
    buffer.writeln('\u{1F4D6} ${recipe.title}');
    buffer.writeln();

    if (recipe.description != null && recipe.description!.isNotEmpty) {
      buffer.writeln(recipe.description);
      buffer.writeln();
    }

    if (recipe.servings != null || recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null) {
      final meta = <String>[];
      if (recipe.servings != null) meta.add(l10n.shareServings(int.tryParse(recipe.servings!.toString()) ?? 0));
      if (recipe.prepTimeMinutes != null) meta.add(l10n.sharePrep(recipe.prepTimeMinutes!));
      if (recipe.cookTimeMinutes != null) meta.add(l10n.shareCook(recipe.cookTimeMinutes!));
      buffer.writeln(meta.join(' | '));
      buffer.writeln();
    }

    if (ingredients.isNotEmpty) {
      buffer.writeln('\u{1F955} ${l10n.ingredientsTitle}:');
      for (final ing in ingredients) {
        final parts = <String>[];
        if (ing.amount != null) parts.add(ing.amount!);
        if (ing.unit != null) parts.add(ing.unit!);
        parts.add(ing.name);
        buffer.writeln('\u2022 ${parts.join(' ')}');
      }
      buffer.writeln();
    }

    if (steps.isNotEmpty) {
      buffer.writeln('\u{1F4DD} ${l10n.instructionsTitle}:');
      for (var i = 0; i < steps.length; i++) {
        buffer.writeln('${i + 1}. ${steps[i].instruction}');
      }
      buffer.writeln();
    }

    if (recipe.notes != null && recipe.notes!.isNotEmpty) {
      buffer.writeln('\u{1F4A1} ${l10n.notesTitle}:');
      buffer.writeln(recipe.notes);
      buffer.writeln();
    }

    // Include linked recipes
    if (linkedRecipes.isNotEmpty) {
      buffer.writeln('─────────────────────');
      buffer.writeln('\u{1F517} Linked Recipes:');
      buffer.writeln();
      for (final linked in linkedRecipes) {
        buffer.writeln('\u{1F4D6} ${linked.title}');
        final linkedIngs = await dao.getIngredientsForRecipe(linked.id);
        final linkedSteps = await dao.getStepsForRecipe(linked.id);
        if (linkedIngs.isNotEmpty) {
          buffer.writeln('\u{1F955} ${l10n.ingredientsTitle}:');
          for (final ing in linkedIngs) {
            final parts = <String>[];
            if (ing.amount != null) parts.add(ing.amount!);
            if (ing.unit != null) parts.add(ing.unit!);
            parts.add(ing.name);
            buffer.writeln('\u2022 ${parts.join(' ')}');
          }
        }
        if (linkedSteps.isNotEmpty) {
          buffer.writeln('\u{1F4DD} ${l10n.instructionsTitle}:');
          for (var i = 0; i < linkedSteps.length; i++) {
            buffer.writeln('${i + 1}. ${linkedSteps[i].instruction}');
          }
        }
        buffer.writeln();
      }
    }

    buffer.writeln(l10n.shareFromApp);

    await SharePlus.instance.share(ShareParams(text: buffer.toString(), subject: recipe.title));
  }

  Future<void> _shareAsDocument(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    AppSnackbar.info(context, l10n.shareCreatingDocument);

    try {
      final dao = ref.read(recipeDaoProvider);
      final ingredients = await dao.getIngredientsForRecipe(recipe.id);
      final steps = await dao.getStepsForRecipe(recipe.id);
      final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

      // Load linked recipe data
      final linkedData = <_LinkedRecipeData>[];
      for (final linked in linkedRecipes) {
        final ings = await dao.getIngredientsForRecipe(linked.id);
        final sts = await dao.getStepsForRecipe(linked.id);
        linkedData.add(_LinkedRecipeData(recipe: linked, ingredients: ings, steps: sts));
      }

      final pdf = await _createRecipePdf(recipe, ingredients, steps, l10n, linkedRecipes: linkedData);

      final dir = await getTemporaryDirectory();
      final filename = recipe.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();
      final file = File('${dir.path}/$filename.pdf');
      await file.writeAsBytes(await pdf.save());

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: '${recipe.title} - Recipe',
      ));
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.info(context, '${l10n.errorGeneric}: $e');
      }
    }
  }

  Future<void> _printRecipe(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    try {
      final dao = ref.read(recipeDaoProvider);
      final ingredients = await dao.getIngredientsForRecipe(recipe.id);
      final steps = await dao.getStepsForRecipe(recipe.id);
      final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

      // Load linked recipe data
      final linkedData = <_LinkedRecipeData>[];
      for (final linked in linkedRecipes) {
        final ings = await dao.getIngredientsForRecipe(linked.id);
        final sts = await dao.getStepsForRecipe(linked.id);
        linkedData.add(_LinkedRecipeData(recipe: linked, ingredients: ings, steps: sts));
      }

      final pdf = await _createRecipePdf(recipe, ingredients, steps, l10n, linkedRecipes: linkedData);

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: recipe.title,
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.info(context, '${l10n.errorGeneric}: $e');
      }
    }
  }

  Future<void> _exportRecipe(BuildContext context) async {
    Navigator.pop(context);

    final dao = ref.read(recipeDaoProvider);
    final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

    // If there are linked recipes, ask the user what to export
    bool includeLinked = false;
    if (linkedRecipes.isNotEmpty && context.mounted) {
      final linkedNames = linkedRecipes.map((r) => r.title).join(', ');
      includeLinked = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            title: const Text('Export Linked Recipes?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This recipe has ${linkedRecipes.length} linked recipe(s):'),
                const SizedBox(height: 8),
                Text(
                  linkedNames,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ctx.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Would you like to include them in the export so the links are preserved when imported?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Only ${recipe.title}'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Export All'),
              ),
            ],
          );
        },
      ) ?? false;
    }

    if (!context.mounted) return;

    final ingredients = await dao.getIngredientsForRecipe(recipe.id);
    final steps = await dao.getStepsForRecipe(recipe.id);

    // Build ingredient link map: ingredient name -> linked recipe title
    final ingredientLinks = await dao.getIngredientLinksMap(recipe.id);
    final ingredientLinkNames = <String, List<String>>{};
    if (includeLinked) {
      for (final entry in ingredientLinks.entries) {
        final ingId = entry.key;
        final ing = ingredients.where((i) => i.id == ingId).firstOrNull;
        if (ing != null) {
          ingredientLinkNames[ing.name] = entry.value.map((li) => li.recipe.title).toList();
        }
      }
    }

    Map<String, dynamic> buildRecipeData(Recipe r, List<Ingredient> ings, List<Step> stps) {
      return {
        'title': r.title,
        'description': r.description,
        'servings': r.servings,
        'prepTimeMinutes': r.prepTimeMinutes,
        'cookTimeMinutes': r.cookTimeMinutes,
        'sourceUrl': r.sourceUrl,
        'courseId': r.courseId,
        'categoryId': r.categoryId,
        'rating': r.rating,
        'notes': r.notes,
        'nutritionJson': r.nutritionJson,
        'ingredients': ings.map((i) => {
          'amount': i.amount,
          'unit': i.unit,
          'name': i.name,
          'notes': i.notes,
        }).toList(),
        'instructions': stps.map((s) {
          String? imagePath;
          int? duration;
          try {
            imagePath = s.imagePath;
            duration = s.durationMinutes;
          } catch (e) {
            imagePath = null;
            duration = null;
          }
          return {
            'instruction': s.instruction,
            'imagePath': imagePath,
            'durationMinutes': duration,
            'notes': s.notes,
          };
        }).toList(),
      };
    }

    final mainData = buildRecipeData(recipe, ingredients, steps);

    // Add linking info — maps ingredient names to linked recipe titles
    if (includeLinked && ingredientLinkNames.isNotEmpty) {
      mainData['ingredientLinks'] = ingredientLinkNames;
    }

    // Build final export data
    dynamic exportData;
    if (includeLinked && linkedRecipes.isNotEmpty) {
      // Export as array: main recipe + all linked recipes
      final allRecipes = <Map<String, dynamic>>[mainData];
      for (final linked in linkedRecipes) {
        final linkedIngs = await dao.getIngredientsForRecipe(linked.id);
        final linkedSteps = await dao.getStepsForRecipe(linked.id);
        allRecipes.add(buildRecipeData(linked, linkedIngs, linkedSteps));
      }
      exportData = {
        'recipes': allRecipes,
        'links': ingredientLinkNames,
        'exportedFrom': 'Recipe Spellbook',
        'exportDate': DateTime.now().toIso8601String(),
        'version': '3.0',
      };
    } else {
      mainData['exportedFrom'] = 'Recipe Spellbook';
      mainData['exportDate'] = DateTime.now().toIso8601String();
      mainData['version'] = '2.0';
      exportData = mainData;
    }

    final json = const JsonEncoder.withIndent('  ').convert(exportData);

    final dir = await getTemporaryDirectory();
    final filename = recipe.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();
    final file = File('${dir.path}/$filename.json');
    await file.writeAsString(json);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      subject: '${recipe.title} - Recipe Export',
    ));
  }

  Future<pw.Document> _createRecipePdf(
      Recipe recipe,
      List<Ingredient> ingredients,
      List<Step> steps,
      AppLocalizations l10n, {
        List<_LinkedRecipeData> linkedRecipes = const [],
      }) async {
    final theme = await _loadPdfTheme();
    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                _stripEmojiForPdf(recipe.title),
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (recipe.description != null && recipe.description!.isNotEmpty)
              pw.Paragraph(
                text: _stripEmojiForPdf(recipe.description!),
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                if (recipe.servings != null)
                  _pdfMetaItem('${recipe.servings} servings'),
                if (recipe.prepTimeMinutes != null)
                  _pdfMetaItem('${recipe.prepTimeMinutes} min prep'),
                if (recipe.cookTimeMinutes != null)
                  _pdfMetaItem('${recipe.cookTimeMinutes} min cook'),
              ],
            ),
            pw.SizedBox(height: 24),
            if (ingredients.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(l10n.ingredientsTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: ingredients.map((ing) {
                  final parts = <String>[];
                  if (ing.amount != null) parts.add(ing.amount!);
                  if (ing.unit != null) parts.add(ing.unit!);
                  parts.add(_stripEmojiForPdf(ing.name));
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('\u2022 ', style: const pw.TextStyle(fontSize: 12)),
                        pw.Expanded(
                          child: pw.Text(parts.join(' '), style: const pw.TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 24),
            ],
            if (steps.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(l10n.instructionsTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: steps.asMap().entries.map((entry) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 24, height: 24,
                          decoration: const pw.BoxDecoration(
                            shape: pw.BoxShape.circle, color: PdfColors.purple,
                          ),
                          child: pw.Center(
                            child: pw.Text('${entry.key + 1}',
                                style: pw.TextStyle(color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Text(_stripEmojiForPdf(entry.value.instruction),
                              style: const pw.TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Header(
                level: 1,
                child: pw.Text(l10n.notesTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(_stripEmojiForPdf(recipe.notes!), style: const pw.TextStyle(fontSize: 11)),
              ),
            ],

            // ─── LINKED RECIPES ───
            if (linkedRecipes.isNotEmpty) ...[
              pw.SizedBox(height: 32),
              pw.Divider(color: PdfColors.grey400, thickness: 2),
              pw.SizedBox(height: 16),
              pw.Text(
                'Linked Recipes',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              ...linkedRecipes.expand((linked) => _buildLinkedRecipePdf(linked, l10n)),
            ],

            pw.SizedBox(height: 32),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(l10n.shareFromApp,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Build PDF widgets for a single linked recipe
  List<pw.Widget> _buildLinkedRecipePdf(_LinkedRecipeData data, AppLocalizations l10n) {
    return [
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        margin: const pw.EdgeInsets.only(bottom: 16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _stripEmojiForPdf(data.recipe.title),
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            if (data.recipe.description != null && data.recipe.description!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                _stripEmojiForPdf(data.recipe.description!),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
            if (data.ingredients.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(l10n.ingredientsTitle,
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...data.ingredients.map((ing) {
                final parts = <String>[];
                if (ing.amount != null) parts.add(ing.amount!);
                if (ing.unit != null) parts.add(ing.unit!);
                parts.add(_stripEmojiForPdf(ing.name));
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  child: pw.Text('\u2022 ${parts.join(' ')}',
                      style: const pw.TextStyle(fontSize: 10)),
                );
              }),
            ],
            if (data.steps.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(l10n.instructionsTitle,
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...data.steps.asMap().entries.map((entry) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(
                  '${entry.key + 1}. ${_stripEmojiForPdf(entry.value.instruction)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              )),
            ],
          ],
        ),
      ),
    ];
  }

  pw.Widget _pdfMetaItem(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 16),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}

/// Data class for linked recipe with its ingredients and steps
class _LinkedRecipeData {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Step> steps;

  const _LinkedRecipeData({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 24),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:drift/drift.dart' as drift;
import '../../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../../../utils/native_file_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/platform_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
// TODO: Kitchen Buddy hidden for now
// import '../../widgets/kitchen_buddy/kitchen_buddy_integration.dart';

class CookbookEditScreen extends ConsumerStatefulWidget {
  final String? cookbookId; // null for new cookbook

  const CookbookEditScreen({super.key, this.cookbookId});

  @override
  ConsumerState<CookbookEditScreen> createState() => _CookbookEditScreenState();
}

class _CookbookEditScreenState extends ConsumerState<CookbookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _imagePath;
  bool _isLoading = true;
  bool _isSaving = false;
  Cookbook? _cookbook;

  bool get _isEditing => widget.cookbookId != null && widget.cookbookId != 'new';

  @override
  void initState() {
    super.initState();
    _loadCookbook();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCookbook() async {
    if (_isEditing) {
      final dao = ref.read(cookbookDaoProvider);
      _cookbook = await dao.getCookbookById(widget.cookbookId!);

      if (_cookbook != null) {
        _nameController.text = _cookbook!.name;
        _descriptionController.text = _cookbook!.description ?? '';
        _imagePath = _cookbook!.imagePath;
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await Responsive.showAdaptiveSheet<ImageSource>(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (supportsCamera)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            if (_imagePath != null)
              ListTile(
                leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                title: Text(l10n.removeImage, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _imagePath = null);
                },
              ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200);
    if (image == null) return;

    // Copy to app directory
    final dir = await getApplicationDocumentsDirectory();
    final filename = 'cookbook_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = p.join(dir.path, 'images', filename);

    await Directory(p.dirname(newPath)).create(recursive: true);
    await File(image.path).copy(newPath);

    setState(() => _imagePath = newPath);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dao = ref.read(cookbookDaoProvider);

      if (_isEditing) {
        await dao.updateCookbook(
          widget.cookbookId!,
          _nameController.text.trim(),
          _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          _imagePath,
        );
      } else {
        final id = 'cookbook_${DateTime.now().millisecondsSinceEpoch}';
        await dao.insertCookbook(CookbooksCompanion.insert(
          id: id,
          name: _nameController.text.trim(),
          description: drift.Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
          imagePath: drift.Value(_imagePath),
        ));
        // TODO: Kitchen Buddy hidden for now
        // KitchenBuddyIntegration.onCookbookPublished(ref);
      }

      if (mounted) {
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.info(context, '${AppLocalizations.of(context)!.errorGeneric}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    if (!_isEditing) return;
    // Check if this is the only cookbook
    final dao = ref.read(cookbookDaoProvider);
    final cookbooks = await dao.getAllCookbooks();

    if (cookbooks.length <= 1) {
      AppSnackbar.warning(context, AppLocalizations.of(context)!.cookbookCannotDelete);
      return;
    }

    // Check if cookbook has recipes
    final recipeCount = await ref.read(recipeDaoProvider).getRecipeCountForCookbook(widget.cookbookId!);

    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
        title: Text(l10n.cookbookDelete),
        content: Text(
          recipeCount > 0
              ? l10n.cookbookDeleteWithRecipes(recipeCount, _cookbook?.name ?? '')
              : l10n.cookbookDeleteConfirmNamed(_cookbook?.name ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await dao.deleteCookbook(widget.cookbookId!);
      if (mounted) {
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditing ? l10n.editCookbook : l10n.newCookbook)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCookbook : l10n.newCookbook),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: _delete,
            ),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Text(l10n.actionSave),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cover image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imagePath != null
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      buildFileImage(
                        _imagePath!,
                        fit: BoxFit.cover,
                        errorWidget: _imagePlaceholder(theme, l10n),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  )
                      : _imagePlaceholder(theme, l10n),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.tapToAddCoverImage,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ),

            const SizedBox(height: 32),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.cookbookNameLabel,
                hintText: l10n.cookbookNameHint,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.cookbookNameRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.cookbookDescriptionLabel,
                hintText: l10n.cookbookDescriptionHint,
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),

            // Recipe count (if editing)
            if (_isEditing) ...[
              FutureBuilder<int>(
                future: ref.read(recipeDaoProvider).getRecipeCountForCookbook(widget.cookbookId!),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          l10n.recipeCount(count),
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(ThemeData theme, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.addCover,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
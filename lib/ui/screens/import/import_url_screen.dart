import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/recipe_scraper_service.dart';

class ImportUrlScreen extends ConsumerStatefulWidget {
  const ImportUrlScreen({super.key});

  @override
  ConsumerState<ImportUrlScreen> createState() => _ImportUrlScreenState();
}

class _ImportUrlScreenState extends ConsumerState<ImportUrlScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _error;
  ScrapedRecipe? _scrapedRecipe;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scrapeUrl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _scrapedRecipe = null;
    });

    try {
      final scraper = RecipeScraperService();
      final recipe = await scraper.scrapeRecipe(_urlController.text.trim());

      setState(() {
        _scrapedRecipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _editAndSave() {
    if (_scrapedRecipe == null) return;

    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';

    // Navigate to recipe edit screen with pre-filled data
    context.pop(); // Close import screen
    context.pushNamed(
      'new-recipe',
      pathParameters: {'cookbookId': cookbookId},
      extra: {
        'title': _scrapedRecipe!.title,
        'description': _scrapedRecipe!.description,
        'servings': _scrapedRecipe!.servings?.toString(),
        'prepTime': _scrapedRecipe!.prepTimeMinutes,
        'cookTime': _scrapedRecipe!.cookTimeMinutes,
        'sourceUrl': _scrapedRecipe!.sourceUrl ?? _urlController.text.trim(),
        'imageUrl': _scrapedRecipe!.imageUrl,
        'ingredients': _scrapedRecipe!.ingredients,
        'instructions': _scrapedRecipe!.instructions,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from URL'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL input
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Recipe URL',
                  hintText: 'https://example.com/recipe',
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _urlController.clear();
                      setState(() {
                        _scrapedRecipe = null;
                        _error = null;
                      });
                    },
                  )
                      : null,
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                onFieldSubmitted: (_) => _scrapeUrl(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a URL';
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasScheme) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // Fetch button
            FilledButton.icon(
              onPressed: _isLoading ? null : _scrapeUrl,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.download),
              label: Text(_isLoading ? 'Fetching...' : 'Fetch Recipe'),
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Preview
            if (_scrapedRecipe != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    'Preview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Recipe found!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recipe card preview
              _RecipePreview(recipe: _scrapedRecipe!),

              const SizedBox(height: 24),

              // Continue to edit button
              FilledButton.icon(
                onPressed: _editAndSave,
                icon: const Icon(Icons.edit),
                label: const Text('Review & Save'),
              ),
              const SizedBox(height: 8),
              Text(
                'You can edit the recipe before saving',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Supported sites info
            if (_scrapedRecipe == null && _error == null && !_isLoading) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Supported Sites',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Works with most recipe sites including:\n'
                          '• AllRecipes, Food Network, Tasty\n'
                          '• BBC Good Food, Epicurious\n'
                          '• Serious Eats, Bon Appétit\n'
                          '• And many more with structured data!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecipePreview extends StatelessWidget {
  final ScrapedRecipe recipe;

  const _RecipePreview({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (recipe.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Title
            Text(
              recipe.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // Description
            if (recipe.description != null) ...[
              const SizedBox(height: 4),
              Text(
                recipe.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Meta info
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (recipe.prepTimeMinutes != null)
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    label: 'Prep: ${recipe.prepTimeMinutes} min',
                  ),
                if (recipe.cookTimeMinutes != null)
                  _MetaChip(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Cook: ${recipe.cookTimeMinutes} min',
                  ),
                if (recipe.servings != null)
                  _MetaChip(
                    icon: Icons.people_outline,
                    label: '${recipe.servings} servings',
                  ),
              ],
            ),

            const Divider(height: 24),

            // Ingredients count
            Row(
              children: [
                Icon(Icons.checklist, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${recipe.ingredients.length} Ingredients',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.take(4).map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record,
                      size: 6, color: theme.colorScheme.outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      i,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
            if (recipe.ingredients.length > 4)
              Text(
                '... and ${recipe.ingredients.length - 4} more',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 16),

            // Steps count
            Row(
              children: [
                Icon(Icons.format_list_numbered, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${recipe.instructions.length} Steps',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
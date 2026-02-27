import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class RecipeLayoutSettingsScreen extends ConsumerWidget {
  const RecipeLayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final currentLayout = settings.recipeLayoutMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsRecipeLayout),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Description
          Text(
            l10n.settingsRecipeLayoutDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Layout Options
          _LayoutOptionCard(
            title: l10n.layoutStacked,
            description: l10n.layoutStackedDescription,
            isSelected: currentLayout == RecipeLayoutMode.stacked,
            onTap: () {
              ref.read(settingsProvider.notifier).setRecipeLayoutMode(RecipeLayoutMode.stacked);
            },
            preview: const _StackedPreview(),
          ),

          const SizedBox(height: 16),

          _LayoutOptionCard(
            title: l10n.layoutTabbed,
            description: l10n.layoutTabbedDescription,
            isSelected: currentLayout == RecipeLayoutMode.tabbed,
            onTap: () {
              ref.read(settingsProvider.notifier).setRecipeLayoutMode(RecipeLayoutMode.tabbed);
            },
            preview: const _TabbedPreview(),
          ),

          const SizedBox(height: 32),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.layoutInfoText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget preview;

  const _LayoutOptionCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with selection indicator
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 24,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preview
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: preview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive stacked layout preview showing Ingredients → Instructions → Nutrition vertically
class _StackedPreview extends StatelessWidget {
  const _StackedPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredients Section
          _PreviewSection(
            icon: Icons.checklist,
            title: AppLocalizations.of(context)!.ingredientsTitle,
            color: theme.colorScheme.primary,
            child: Column(
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.outline, width: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),
          const SizedBox(height: 12),

          // Instructions Section
          _PreviewSection(
            icon: Icons.format_list_numbered,
            title: AppLocalizations.of(context)!.instructionsTitle,
            color: theme.colorScheme.secondary,
            child: Column(
              children: List.generate(2, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(fontSize: 8, color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),
          const SizedBox(height: 12),

          // Nutrition Section
          _PreviewSection(
            icon: Icons.local_fire_department,
            title: AppLocalizations.of(context)!.nutritionTitle,
            color: Colors.orange,
            child: _NutritionPreviewContent(),
          ),
        ],
      ),
    );
  }
}

/// Interactive tabbed layout preview with swipeable tabs
class _TabbedPreview extends StatefulWidget {
  const _TabbedPreview();

  @override
  State<_TabbedPreview> createState() => _TabbedPreviewState();
}

class _TabbedPreviewState extends State<_TabbedPreview> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 1; // Start on Ingredients

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      _TabInfo(icon: Icons.local_fire_department, label: l10n.nutritionTitle, color: Colors.orange),
      _TabInfo(icon: Icons.checklist, label: l10n.tabIngredients, color: theme.colorScheme.primary),
      _TabInfo(icon: Icons.format_list_numbered, label: l10n.tabInstructions, color: theme.colorScheme.secondary),
    ];

    return Column(
      children: [
        // Tab bar
        Container(
          height: 36,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isSelected = index == _currentPage;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 12,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Swipe hint
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe, size: 10, color: theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text(
              l10n.swipeToSwitch,
              style: TextStyle(
                fontSize: 8,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Page content
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            children: [
              // Nutrition tab content
              _TabContent(
                child: _NutritionPreviewContent(),
              ),

              // Ingredients tab content
              _TabContent(
                child: _IngredientsPreviewContent(),
              ),

              // Instructions tab content
              _TabContent(
                child: _InstructionsPreviewContent(),
              ),
            ],
          ),
        ),

        // Page indicator dots
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: index == _currentPage ? 12 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  final Color color;

  _TabInfo({required this.icon, required this.label, required this.color});
}

class _TabContent extends StatelessWidget {
  final Widget child;

  const _TabContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _PreviewSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _NutritionPreviewContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calories header
        Row(
          children: [
            Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              '425',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'cal',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Macro row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MacroChipPreview(label: AppLocalizations.of(context)!.protein, value: '32g', color: Colors.blue),
            _MacroChipPreview(label: AppLocalizations.of(context)!.carbohydrates, value: '45g', color: Colors.green),
            _MacroChipPreview(label: AppLocalizations.of(context)!.fat, value: '18g', color: Colors.orange),
          ],
        ),
      ],
    );
  }
}

class _MacroChipPreview extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChipPreview({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 7,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsPreviewContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(4, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class _InstructionsPreviewContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(3, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 8,
                    width: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
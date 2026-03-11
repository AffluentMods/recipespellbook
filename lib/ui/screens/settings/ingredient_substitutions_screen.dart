import 'package:flutter/material.dart';
import '../../../data/ingredient_substitutions.dart';
import '../../../l10n/app_localizations.dart';

/// Standalone ingredient substitutions screen
/// Accessible from drawer menu and from long-pressing ingredients in recipes
class IngredientSubstitutionsScreen extends StatefulWidget {
  /// If provided, auto-searches this ingredient on open
  final String? initialSearch;

  const IngredientSubstitutionsScreen({super.key, this.initialSearch});

  @override
  State<IngredientSubstitutionsScreen> createState() => _IngredientSubstitutionsScreenState();
}

class _IngredientSubstitutionsScreenState extends State<IngredientSubstitutionsScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<IngredientSubEntry> _results = allSubstitutions;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchController.text = widget.initialSearch!;
      _results = searchSubstitutions(widget.initialSearch!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _selectedCategory = null;
      _results = searchSubstitutions(query);
    });
  }

  void _onCategoryTap(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      if (category == null) {
        _results = allSubstitutions;
      } else {
        _results = allSubstitutions.where((e) => e.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ingredientSubstitutionsTitle),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: l10n.ingredientSubstitutionsSearch,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Category chips (only when not searching)
          if (_searchController.text.isEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _CategoryChip(
                    label: l10n.substitutionsAll,
                    selected: _selectedCategory == null,
                    onTap: () => _onCategoryTap(null),
                  ),
                  ...subsCategories.map((cat) => _CategoryChip(
                    label: cat,
                    selected: _selectedCategory == cat,
                    onTap: () => _onCategoryTap(cat),
                  )),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _results.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ingredientSubstitutionsNoResults,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.ingredientSubstitutionsTryDifferent,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final entry = _results[index];
                return _SubstitutionCard(entry: entry);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORY CHIP
// ============================================================

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        ),
        selectedColor: theme.colorScheme.primary,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ============================================================
// SUBSTITUTION CARD
// ============================================================

class _SubstitutionCard extends StatelessWidget {
  final IngredientSubEntry entry;

  const _SubstitutionCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcon(entry.category),
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Text(
            entry.ingredient,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            l10n.substitutionsCount(entry.substitutes.length, entry.category),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          children: entry.substitutes.map((sub) => _SubstituteRow(sub: sub)).toList(),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Dairy & Eggs': return Icons.egg_outlined;
      case 'Fats & Oils': return Icons.water_drop_outlined;
      case 'Sweeteners': return Icons.cake_outlined;
      case 'Flour & Grains': return Icons.grass;
      case 'Leavening': return Icons.bubble_chart_outlined;
      case 'Proteins': return Icons.set_meal_outlined;
      case 'Vegetables': return Icons.eco_outlined;
      case 'Herbs & Spices': return Icons.spa_outlined;
      case 'Sauces & Condiments': return Icons.local_dining;
      case 'Liquids': return Icons.local_drink_outlined;
      case 'Nuts & Seeds': return Icons.forest_outlined;
      case 'Thickeners': return Icons.science_outlined;
      default: return Icons.restaurant_outlined;
    }
  }
}

// ============================================================
// SUBSTITUTE ROW
// ============================================================

class _SubstituteRow extends StatelessWidget {
  final IngredientSub sub;

  const _SubstituteRow({required this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swap icon
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.swap_horiz, size: 16, color: theme.colorScheme.onTertiaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + ratio
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sub.name,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sub.ratio,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Notes
                Text(
                  sub.notes,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INLINE BOTTOM SHEET for recipe ingredient long-press
// ============================================================

/// Shows substitution info as a bottom sheet when user long-presses an ingredient
void showIngredientSubsSheet(BuildContext context, String ingredientName) {
  final entry = findSubsFor(ingredientName);
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: entry != null ? 0.5 : 0.3,
      maxChildSize: 0.85,
      minChildSize: 0.2,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.ingredientSubstitutesFor(ingredientName),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: entry != null
                  ? ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: entry.substitutes.map((sub) => _SubstituteRow(sub: sub)).toList(),
              )
                  : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 40, color: theme.colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(
                      l10n.ingredientSubstitutionsNotFound(ingredientName),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => IngredientSubstitutionsScreen(initialSearch: ingredientName),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search, size: 18),
                      label: Text(l10n.ingredientSubstitutionsSearchAll),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
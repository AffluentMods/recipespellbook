import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_utils.dart';

/// Displays shared content from a `/s/:code` link.
/// Fetches the data from the backend and shows recipes with an import option.
class ShareViewerScreen extends StatefulWidget {
  final String code;
  const ShareViewerScreen({super.key, required this.code});

  @override
  State<ShareViewerScreen> createState() => _ShareViewerScreenState();
}

class _ShareViewerScreenState extends State<ShareViewerScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchShareData();
  }

  Future<void> _fetchShareData() async {
    try {
      const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');
      final uri = Uri.parse('$apiUrl/v1/share/${widget.code}');
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _loading = false;
        });
      } else if (response.statusCode == 404) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_data?['cookbook']?['name'] ?? l10n.shareViewerSharedRecipe),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Responsive.constrainWidth(context, child: _buildBody(theme)),
    );
  }

  Widget _buildBody(ThemeData theme) {
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

    final recipes = (_data?['recipes'] as List?) ?? [];
    final sharedBy = _data?['sharedBy']?['name'] ?? 'Someone';
    final expiresAt = _data?['expiresAt'] != null
        ? DateTime.tryParse(_data!['expiresAt'])
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.share, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.shareViewerSharedBy(sharedBy),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.shareViewerExpires(_formatExpiry(expiresAt, l10n)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.shareViewerRecipeCount(recipes.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recipe list
        ...recipes.map((r) => _RecipeCard(recipe: r, theme: theme)),
      ],
    );
  }

  String _formatExpiry(DateTime expiry, AppLocalizations l10n) {
    final diff = expiry.difference(DateTime.now());
    if (diff.inHours > 0) return l10n.shareViewerHoursRemaining(diff.inHours);
    if (diff.inMinutes > 0) return l10n.shareViewerMinutesRemaining(diff.inMinutes);
    return l10n.shareViewerExpiredLabel;
  }
}

class _RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final ThemeData theme;

  const _RecipeCard({required this.recipe, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = recipe['title'] ?? l10n.shareViewerUntitled;
    final description = recipe['description'] as String?;
    final ingredients = (recipe['ingredients'] as List?) ?? [];
    final steps = (recipe['steps'] as List?) ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(Icons.restaurant, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: description != null && description.isNotEmpty
            ? Text(description, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ingredients.isNotEmpty) ...[
                  Text(l10n.ingredientsTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...ingredients.map((ing) {
                    final amount = ing['amount']?.toString() ?? '';
                    final unit = ing['unit']?.toString() ?? '';
                    final name = ing['name']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $amount $unit $name'.trim()),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
                if (steps.isNotEmpty) ...[
                  Text(l10n.instructionsTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...steps.asMap().entries.map((entry) {
                    final instruction = entry.value['instruction']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${entry.key + 1}. $instruction'),
                    );
                  }),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

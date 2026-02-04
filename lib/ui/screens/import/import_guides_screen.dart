import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ImportGuidesScreen extends StatelessWidget {
  const ImportGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importGuides),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Setup Card - Share sheet preview
          _SetupCard(),

          const SizedBox(height: 24),

          // Platform guides header
          Text(
            'Import from',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Platform grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _PlatformCard(
                icon: Icons.camera_alt,
                name: 'Instagram',
                gradient: const LinearGradient(
                  colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showGuideSheet(context, 'instagram'),
              ),
              _PlatformCard(
                icon: Icons.music_note,
                name: 'TikTok',
                gradient: const LinearGradient(
                  colors: [Color(0xFF000000), Color(0xFF25F4EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showGuideSheet(context, 'tiktok'),
              ),
              _PlatformCard(
                icon: Icons.play_circle_fill,
                name: 'YouTube',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showGuideSheet(context, 'youtube'),
              ),
              _PlatformCard(
                icon: Icons.facebook,
                name: 'Facebook',
                gradient: const LinearGradient(
                  colors: [Color(0xFF1877F2), Color(0xFF0D5DC3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showGuideSheet(context, 'facebook'),
              ),
              _PlatformCard(
                icon: Icons.language,
                name: 'Websites',
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showGuideSheet(context, 'websites'),
              ),
              _PlatformCard(
                icon: Icons.computer,
                name: 'Desktop',
                gradient: LinearGradient(
                  colors: [Colors.grey.shade500, Colors.grey.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showGuideSheet(context, 'desktop'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Import from other apps
          Text(
            'Import from other apps',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _AppCard(
            emoji: '🌶️',
            name: 'Paprika',
            description: 'Import .paprikarecipes files',
            onTap: () => _showAppGuide(context, 'paprika'),
          ),
          const SizedBox(height: 8),
          _AppCard(
            emoji: '📖',
            name: 'RecipeKeeper',
            description: 'Import HTML exports',
            onTap: () => _showAppGuide(context, 'recipekeeper'),
          ),
          const SizedBox(height: 8),
          _AppCard(
            emoji: '🍎',
            name: 'Mela',
            description: 'Import .melarecipes files',
            onTap: () => _showAppGuide(context, 'mela'),
          ),
          const SizedBox(height: 8),
          _AppCard(
            emoji: '📝',
            name: 'Markdown / Obsidian',
            description: 'Import .md recipe files',
            onTap: () => _showAppGuide(context, 'markdown'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showGuideSheet(BuildContext context, String platform) {
    final guides = _getPlatformGuide(platform);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(guides['icon'] as IconData, size: 32, color: guides['color'] as Color),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guides['title'] as String,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            guides['subtitle'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: (guides['steps'] as List).length,
                    itemBuilder: (context, index) {
                      final step = (guides['steps'] as List)[index];
                      return _StepItem(
                        number: index + 1,
                        title: step['title'] as String,
                        description: step['description'] as String,
                        isLast: index == (guides['steps'] as List).length - 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppGuide(BuildContext context, String app) {
    final guides = _getAppGuide(app);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(guides['emoji'] as String, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import from ${guides['name']}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: (guides['steps'] as List).length,
                itemBuilder: (context, index) {
                  final step = (guides['steps'] as List)[index];
                  return _StepItem(
                    number: index + 1,
                    title: step['title'] as String,
                    description: step['description'] as String,
                    isLast: index == (guides['steps'] as List).length - 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getPlatformGuide(String platform) {
    switch (platform) {
      case 'instagram':
        return {
          'icon': Icons.camera_alt,
          'color': const Color(0xFFDD2A7B),
          'title': 'Instagram',
          'subtitle': 'Import from posts and reels',
          'steps': [
            {'title': 'Find a recipe', 'description': 'Open the Instagram post or reel with the recipe you want to save.'},
            {'title': 'Tap Share', 'description': 'Tap the paper airplane icon below the post.'},
            {'title': 'Select Recipe Spellbook', 'description': 'Scroll through the apps and tap Recipe Spellbook. If you don\'t see it, tap "More".'},
            {'title': 'Save your recipe', 'description': 'The recipe will be automatically extracted from the caption. Review and save!'},
          ],
        };
      case 'tiktok':
        return {
          'icon': Icons.music_note,
          'color': Colors.black,
          'title': 'TikTok',
          'subtitle': 'Import from videos',
          'steps': [
            {'title': 'Find a recipe video', 'description': 'Open the TikTok video with the recipe you want to save.'},
            {'title': 'Tap Share', 'description': 'Tap the arrow icon on the right side of the screen.'},
            {'title': 'Copy link or share', 'description': 'Either copy the link and paste it in Recipe Spellbook, or tap "More" to share directly.'},
            {'title': 'Select Recipe Spellbook', 'description': 'The app will extract the recipe from the video caption.'},
            {'title': 'Review and save', 'description': 'Check the extracted recipe and make any edits before saving.'},
          ],
        };
      case 'youtube':
        return {
          'icon': Icons.play_circle_fill,
          'color': Colors.red,
          'title': 'YouTube',
          'subtitle': 'Import from video descriptions',
          'steps': [
            {'title': 'Find a recipe video', 'description': 'Open the YouTube video with the recipe.'},
            {'title': 'Tap Share', 'description': 'Tap the Share button below the video.'},
            {'title': 'Copy link', 'description': 'Copy the video link to your clipboard.'},
            {'title': 'Open Recipe Spellbook', 'description': 'Go to Import → URL and paste the link.'},
            {'title': 'Extract recipe', 'description': 'The app will find recipe information in the video description.'},
          ],
        };
      case 'facebook':
        return {
          'icon': Icons.facebook,
          'color': const Color(0xFF1877F2),
          'title': 'Facebook',
          'subtitle': 'Import from posts',
          'steps': [
            {'title': 'Find a recipe post', 'description': 'Open the Facebook post with the recipe.'},
            {'title': 'Tap Share', 'description': 'Tap the Share button below the post.'},
            {'title': 'Share to...', 'description': 'Select "Share to..." from the options.'},
            {'title': 'Select Recipe Spellbook', 'description': 'Find and tap Recipe Spellbook in the share sheet.'},
            {'title': 'Save your recipe', 'description': 'Review the extracted recipe and save it to your collection.'},
          ],
        };
      case 'websites':
        return {
          'icon': Icons.language,
          'color': Colors.blue,
          'title': 'Websites',
          'subtitle': 'Import from any recipe site',
          'steps': [
            {'title': 'Find a recipe', 'description': 'Open any recipe website in your browser (Safari, Chrome, etc.).'},
            {'title': 'Copy the URL', 'description': 'Copy the page URL from the address bar.'},
            {'title': 'Open Recipe Spellbook', 'description': 'Go to any cookbook and tap the + button.'},
            {'title': 'Paste URL', 'description': 'Select "Import from URL" and paste the link.'},
            {'title': 'Auto-extract', 'description': 'The app will automatically extract the recipe, ingredients, and instructions.'},
          ],
        };
      case 'desktop':
        return {
          'icon': Icons.computer,
          'color': Colors.grey,
          'title': 'Desktop',
          'subtitle': 'Sync with your computer',
          'steps': [
            {'title': 'Create an account', 'description': 'Sign up for Recipe Spellbook to enable sync (coming soon!).'},
            {'title': 'Sign in on desktop', 'description': 'Visit recipespellbook.com and sign in with your account.'},
            {'title': 'Import recipes', 'description': 'Use the web interface to import recipes from URLs or files.'},
            {'title': 'Auto-sync', 'description': 'Your recipes will automatically sync to your mobile app.'},
            {'title': 'Access anywhere', 'description': 'View and edit your recipes on any device.'},
          ],
        };
      default:
        return {
          'icon': Icons.help,
          'color': Colors.grey,
          'title': 'Help',
          'subtitle': 'Import guide',
          'steps': [],
        };
    }
  }

  Map<String, dynamic> _getAppGuide(String app) {
    switch (app) {
      case 'paprika':
        return {
          'emoji': '🌶️',
          'name': 'Paprika',
          'steps': [
            {'title': 'Export from Paprika', 'description': 'In Paprika, go to Settings → Export Recipes → Export All.'},
            {'title': 'Save the file', 'description': 'Save the .paprikarecipes file to your device or cloud storage.'},
            {'title': 'Import to Recipe Spellbook', 'description': 'Open Recipe Spellbook, tap + and select "Import File".'},
            {'title': 'Select the file', 'description': 'Choose your .paprikarecipes file from your files.'},
            {'title': 'Done!', 'description': 'All your recipes will be imported with images, ingredients, and instructions.'},
          ],
        };
      case 'recipekeeper':
        return {
          'emoji': '📖',
          'name': 'RecipeKeeper',
          'steps': [
            {'title': 'Export from RecipeKeeper', 'description': 'In RecipeKeeper, go to Settings → Backup → Export to HTML.'},
            {'title': 'Save the file', 'description': 'Save the HTML file to your device.'},
            {'title': 'Import to Recipe Spellbook', 'description': 'Open Recipe Spellbook, tap + and select "Import File".'},
            {'title': 'Select the HTML file', 'description': 'Choose your RecipeKeeper export file.'},
            {'title': 'Review imports', 'description': 'Check your imported recipes and make any needed adjustments.'},
          ],
        };
      case 'mela':
        return {
          'emoji': '🍎',
          'name': 'Mela',
          'steps': [
            {'title': 'Export from Mela', 'description': 'In Mela, select recipes and tap Share → Export as .melarecipes.'},
            {'title': 'Save the file', 'description': 'Save the export file to your device.'},
            {'title': 'Import to Recipe Spellbook', 'description': 'Open Recipe Spellbook and tap + → Import File.'},
            {'title': 'Select the file', 'description': 'Choose your .melarecipes export.'},
            {'title': 'Complete!', 'description': 'Your Mela recipes are now in Recipe Spellbook.'},
          ],
        };
      case 'markdown':
        return {
          'emoji': '📝',
          'name': 'Markdown',
          'steps': [
            {'title': 'Prepare your files', 'description': 'Make sure your recipes are in .md format with clear sections for ingredients and instructions.'},
            {'title': 'Open Recipe Spellbook', 'description': 'Tap + and select "Import File" or "Import Text".'},
            {'title': 'Select or paste', 'description': 'Choose your .md file or paste the markdown content directly.'},
            {'title': 'Auto-parse', 'description': 'The app will automatically parse headers, ingredients lists, and numbered steps.'},
            {'title': 'Review and save', 'description': 'Check the parsed recipe and save it to your collection.'},
          ],
        };
      default:
        return {
          'emoji': '📄',
          'name': 'File',
          'steps': [],
        };
    }
  }
}

// ============ SETUP CARD ============

class _SetupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Mock share sheet
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareSheetIcon(
                  icon: Icons.message,
                  label: 'Messages',
                  color: Colors.green,
                ),
                _ShareSheetIcon(
                  icon: Icons.auto_fix_high,
                  label: 'Spellbook',
                  color: const Color(0xFFE8A860),
                  isHighlighted: true,
                ),
                _ShareSheetIcon(
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap the share button on any recipe, then select Recipe Spellbook',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ShareSheetIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isHighlighted;

  const _ShareSheetIcon({
    required this.icon,
    required this.label,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: isHighlighted
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isHighlighted ? color : Colors.grey,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ============ PLATFORM CARD ============

class _PlatformCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final Gradient gradient;
  final VoidCallback onTap;

  const _PlatformCard({
    required this.icon,
    required this.name,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 80,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    const Spacer(),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ APP CARD ============

class _AppCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final VoidCallback onTap;

  const _AppCard({
    required this.emoji,
    required this.name,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ STEP ITEM ============

class _StepItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final bool isLast;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number and line
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
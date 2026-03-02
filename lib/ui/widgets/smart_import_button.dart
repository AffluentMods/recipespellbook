import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../services/smart_import_service.dart';

/// A widget that shows the "Fix with Smart Import" button on the import preview.
///
/// Displays:
///  - The button (with remaining count badge)
///  - Loading state while AI processes
///  - Error/success feedback
///  - Usage limit warnings
///
/// Usage in import_preview_screen.dart:
/// ```dart
/// SmartImportButton(
///   sourceText: _rawScrapedText,     // whatever the user originally provided
///   sourceUrl: _importedUrl,          // if from URL
///   sourceImage: _capturedImageFile,  // if from photo
///   existingParse: _currentRecipeMap, // the bad parse currently showing
///   onResult: (recipe) {
///     setState(() {
///       // Update the preview with AI-parsed recipe
///       _title = recipe['title'] ?? _title;
///       _description = recipe['description'];
///       _servings = recipe['servings'];
///       // ... update all fields from recipe map
///     });
///   },
/// )
/// ```
class SmartImportButton extends ConsumerStatefulWidget {
  final String? sourceText;
  final String? sourceUrl;
  final File? sourceImage;
  final Map<String, dynamic>? existingParse;
  final ValueChanged<Map<String, dynamic>> onResult;

  const SmartImportButton({
    super.key,
    this.sourceText,
    this.sourceUrl,
    this.sourceImage,
    this.existingParse,
    required this.onResult,
  });

  @override
  ConsumerState<SmartImportButton> createState() => _SmartImportButtonState();
}

class _SmartImportButtonState extends ConsumerState<SmartImportButton> {
  bool _loading = false;
  bool _done = false;
  SmartImportUsage? _usage;

  @override
  void initState() {
    super.initState();
    _checkUsage();
  }

  Future<void> _checkUsage() async {
    if (!SmartImportService.instance.isAuthenticated) return;
    final usage = await SmartImportService.instance.getUsage();
    if (mounted) setState(() => _usage = usage);
  }

  Future<void> _runSmartImport() async {
    setState(() => _loading = true);

    final service = SmartImportService.instance;
    SmartImportResult result;

    // Choose the best input to send based on what's available
    if (widget.sourceImage != null) {
      result = await service.parseFromImage(
        imageFile: widget.sourceImage!,
        additionalText: widget.sourceText,
        existingParse: widget.existingParse,
      );
    } else if (widget.sourceUrl != null && widget.sourceUrl!.isNotEmpty) {
      result = await service.parseFromUrl(
        url: widget.sourceUrl!,
        existingParse: widget.existingParse,
      );
    } else if (widget.sourceText != null && widget.sourceText!.isNotEmpty) {
      result = await service.parseFromText(
        text: widget.sourceText!,
        existingParse: widget.existingParse,
      );
    } else {
      setState(() => _loading = false);
      _showError('No source material to send.');
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success && result.recipe != null) {
      setState(() => _done = true);
      widget.onResult(result.recipe!);
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.remaining > 0
                      ? l10n.smartImportSuccessWithRemaining(result.remaining)
                      : l10n.smartImportSuccess,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh usage
      _checkUsage();
    } else {
      _showError(result.errorMessage ?? 'Smart import failed');

      if (result.isLimitReached) {
        _showUpgradeDialog();
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showUpgradeDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.auto_awesome, size: 40, color: Color(0xFFE8A860)),
        title: Text(l10n.smartImportLimitTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.smartImportLimitMessage(_usage?.limit ?? 0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (_usage?.tier == 'cloudSync')
              Text(
                l10n.smartImportUpgradeHint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionOk),
          ),
          if (_usage?.tier == 'cloudSync')
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/upgrade');
              },
              child: Text(l10n.upgrade),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAvailable = SmartImportService.instance.isAuthenticated;
    final hasSource = widget.sourceText != null ||
        widget.sourceUrl != null ||
        widget.sourceImage != null;

    // Don't show at all if user isn't subscribed
    if (!isAvailable) {
      return _SubscribeHint(theme: theme);
    }

    if (_done) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.smartImportReparsed,
                style: const TextStyle(color: Colors.green, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _done = false);
                _runSmartImport();
              },
              child: Text(l10n.retry, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: (_loading || !hasSource) ? null : _runSmartImport,
              icon: _loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                _loading
                    ? l10n.smartImportParsing
                    : l10n.smartImportFix,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(
                  color: const Color(0xFFE8A860).withValues(alpha: 0.6),
                ),
                foregroundColor: const Color(0xFFE8A860),
              ),
            ),
          ),

          // Usage counter
          if (_usage != null && _usage!.available)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.smartImportRemaining(_usage!.remaining, _usage!.limit),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown to free users who don't have smart import access.
class _SubscribeHint extends StatelessWidget {
  final ThemeData theme;
  const _SubscribeHint({required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome,
              size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.smartImportHintTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.smartImportHintSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/upgrade'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: Text(l10n.learnMore, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
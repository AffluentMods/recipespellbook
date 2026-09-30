import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import '../../utils/platform_utils.dart';
import '../../utils/responsive_utils.dart';

/// "New cookbook" entry point: start an empty cookbook, or add a printed one
/// from its ISBN barcode (scanned on phones, typed anywhere).
Future<void> showNewCookbookChooser(BuildContext context) {
  return Responsive.showAdaptiveSheet(
    context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      final theme = Theme.of(ctx);
      Widget option(IconData icon, String title, String subtitle, String route) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Icon(icon),
            ),
            title: Text(title),
            subtitle: Text(subtitle),
            onTap: () {
              Navigator.pop(ctx);
              context.push(route);
            },
          );
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(l10n.cookbookAdd, style: theme.textTheme.titleLarge),
              ),
              option(Icons.create_new_folder_outlined, l10n.isbnCreateBlank,
                  l10n.isbnCreateBlankSubtitle, '/cookbook/new/edit'),
              option(supportsBarcodeScanner ? Icons.qr_code_scanner_rounded : Icons.menu_book_rounded,
                  l10n.isbnAddFromBarcode, l10n.isbnAddFromBarcodeSubtitle, '/cookbooks/add-book'),
            ],
          ),
        ),
      );
    },
  );
}

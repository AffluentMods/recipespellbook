import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/collab_service.dart';
import '../../../utils/platform_utils.dart';
import '../../widgets/app_snackbar.dart';
import 'book_scan_screen.dart';

/// Whether this device can scan cookbook pages: it needs a camera and
/// on-device text recognition, which means a phone or tablet.
bool get supportsBookScan => supportsCamera && supportsOcr;

/// Whether recipes may be added to [cookbookId]: always for the user's own
/// cookbooks, and for a shared one only with permission to add.
bool canAddRecipesTo(String cookbookId) {
  final collab = CollabService.instance;
  return !collab.isCollabCookbook(cookbookId) || collab.canEditCookbook(cookbookId);
}

/// Opens Scan this book for [cookbookId], full screen over the tab bar.
///
/// Returns how many recipes were added (0 if the user backed out).
Future<int> startBookScan(BuildContext context, {required String cookbookId}) async {
  final l10n = AppLocalizations.of(context)!;
  if (!supportsBookScan) return 0;
  if (!canAddRecipesTo(cookbookId)) {
    AppSnackbar.error(context, l10n.bookScanReadOnly);
    return 0;
  }

  final container = ProviderScope.containerOf(context, listen: false);
  String? name;
  try {
    name = (await container.read(cookbookDaoProvider).getCookbookById(cookbookId))?.name;
  } catch (_) {
    // The source line falls back to the app name.
  }
  if (!context.mounted) return 0;

  final added = await Navigator.of(context, rootNavigator: true).push<int>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => BookScanScreen(
        cookbookId: cookbookId,
        bookTitle: (name == null || name.trim().isEmpty) ? l10n.appTitle : name.trim(),
      ),
    ),
  );
  return added ?? 0;
}

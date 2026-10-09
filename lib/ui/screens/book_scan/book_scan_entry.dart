import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/collab_service.dart';
import '../../../utils/platform_utils.dart';
import '../../widgets/app_snackbar.dart';
import 'book_scan_screen.dart';
import 'book_scan_widgets.dart';

/// Whether this device can scan cookbook pages: it needs a camera and
/// on-device text recognition, which means a phone or tablet.
bool get supportsBookScan => supportsCamera && supportsOcr;

/// Whether recipes may be added to [cookbookId]: always for the user's own
/// cookbooks, and for a shared one only with permission to add.
bool canAddRecipesTo(String cookbookId) {
  final collab = CollabService.instance;
  return !collab.isCollabCookbook(cookbookId) || collab.canEditCookbook(cookbookId);
}

/// A scan is being started: its cookbook is still being looked up, or the
/// user is being asked for one. A second tap in that time would open a second
/// scan over the first.
bool _starting = false;

/// Opens Scan this book for [cookbookId], full screen over the tab bar.
///
/// When there is no such cookbook (it was deleted, or the screen the user
/// came from had none selected) the user is asked which one to scan into.
///
/// Returns how many recipes were added (0 if the user backed out).
Future<int> startBookScan(BuildContext context, {required String cookbookId}) async {
  final l10n = AppLocalizations.of(context)!;
  if (!supportsBookScan || _starting) return 0;
  if (!canAddRecipesTo(cookbookId)) {
    AppSnackbar.error(context, l10n.bookScanReadOnly);
    return 0;
  }

  final cookbooks = ProviderScope.containerOf(context, listen: false).read(cookbookDaoProvider);
  var id = cookbookId;
  String? name;
  _starting = true;
  try {
    var cookbook = await cookbooks.getCookbookById(cookbookId);
    if (cookbook == null) {
      // Recipes filed under an id that has no cookbook would be in none.
      final others = [
        for (final other in await cookbooks.getAllCookbooks())
          if (canAddRecipesTo(other.id)) other,
      ];
      if (!context.mounted) return 0;
      if (others.isEmpty) {
        AppSnackbar.error(context, l10n.bookScanNoCookbook);
        return 0;
      }
      cookbook = others.length == 1
          ? others.single
          : await showScanCookbookPicker(
              context,
              cookbooks: others,
              title: l10n.bookScanChooseCookbookTitle,
              message: l10n.bookScanChooseCookbook,
            );
      if (cookbook == null) return 0;
    }
    id = cookbook.id;
    name = cookbook.name;
  } catch (_) {
    // The source line falls back to the app name. The scan looks the cookbook
    // up again before it adds anything to it.
  } finally {
    _starting = false;
  }
  if (!context.mounted) return 0;

  final added = await Navigator.of(context, rootNavigator: true).push<int>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => BookScanScreen(
        cookbookId: id,
        bookTitle: (name == null || name.trim().isEmpty) ? l10n.appTitle : name.trim(),
      ),
    ),
  );
  return added ?? 0;
}

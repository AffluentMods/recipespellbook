import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/cookbook_provider.dart';
import '../../services/export_import_service.dart';
import 'app_snackbar.dart';

// Restoring a backup, as Settings > Import data and the File option of the
// Add a recipe sheet both do it: one progress message and one result
// message, wherever the backup was picked.

/// Runs [restore] under the progress message: "Importing..." until the
/// restore counts its recipes, then "Importing... 3/10". The message goes
/// away when the restore is through, also when [context] went away meanwhile.
Future<ImportResult> restoreBackupWithProgress(
  BuildContext context,
  Future<ImportResult> Function(ImportProgressCallback onProgress) restore,
) async {
  final importing = AppLocalizations.of(context)!.importing;
  // The word comes with its dots in every language.
  AppSnackbar.loading(context, importing);
  try {
    return await restore((current, total, label) {
      if (context.mounted) AppSnackbar.loading(context, '$importing $current/$total');
    });
  } finally {
    AppSnackbar.dismiss(context);
  }
}

/// Says how a restore went. A restore that brought a cookbook in opens it:
/// it becomes the selected cookbook and the app goes to its home page.
void showBackupRestoreResult(BuildContext context, ImportResult result) {
  if (!result.success) {
    AppSnackbar.error(context, result.message);
    return;
  }
  final cookbookId = result.importedCookbookId;
  if (cookbookId == null) {
    AppSnackbar.success(context, result.message);
    return;
  }
  final switched = AppLocalizations.of(context)!.settingsSwitchedToImported;
  ProviderScope.containerOf(context, listen: false).read(selectedCookbookIdProvider.notifier).state = cookbookId;
  GoRouter.maybeOf(context)?.go('/');
  AppSnackbar.success(context, '${result.message}\n$switched');
}

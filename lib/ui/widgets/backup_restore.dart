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
  final l10n = AppLocalizations.of(context)!;
  final message = backupRestoreMessage(result, l10n);
  if (!result.success) {
    AppSnackbar.error(context, message);
    return;
  }
  final cookbookId = result.importedCookbookId;
  if (cookbookId == null) {
    AppSnackbar.success(context, message);
    return;
  }
  final switched = l10n.settingsSwitchedToImported;
  ProviderScope.containerOf(context, listen: false).read(selectedCookbookIdProvider.notifier).state = cookbookId;
  GoRouter.maybeOf(context)?.go('/');
  AppSnackbar.success(context, '$message\n$switched');
}

/// What a restore came to, in the user's language: what was imported, or
/// why nothing was. [ImportResult.message] says it in English for the log.
String backupRestoreMessage(ImportResult result, AppLocalizations l10n) {
  final failure = result.failure;
  if (failure != null) return backupRestoreFailureMessage(failure, l10n);
  if (!result.success) return result.message;
  final parts = [
    if (result.cookbooksImported > 0) ...[
      l10n.backupRestoreCookbooks(result.cookbooksImported),
      l10n.backupRestoreRecipes(result.recipesImported),
    ],
    if (result.shoppingListsImported > 0) l10n.backupRestoreShoppingLists(result.shoppingListsImported),
    if (result.mealPlansImported > 0) l10n.backupRestoreMealPlans(result.mealPlansImported),
    if (result.tagsImported > 0) l10n.backupRestoreTags(result.tagsImported),
  ];
  // A success that came without counts says it in its own words.
  if (parts.isEmpty) return result.message;
  final language = l10n.localeName.split('_').first;
  final items = parts.join(language == 'ja' || language == 'zh' ? '、' : ', ');
  final skipped = result.recipesSkipped > 0 ? ' ${l10n.backupRestoreSkipped(result.recipesSkipped)}' : '';
  return l10n.backupRestoreImported('$items$skipped');
}

/// Why a restore did not go through, in the user's language.
String backupRestoreFailureMessage(ImportFailure failure, AppLocalizations l10n) => switch (failure) {
      ImportFailure.noPicker => l10n.importErrorNoPicker,
      ImportFailure.unreadable => l10n.importErrorUnreadable,
      ImportFailure.notABackup => l10n.importErrorNotABackup,
      ImportFailure.missingData => l10n.importErrorMissingData,
      ImportFailure.restoreFailed => l10n.importErrorRestoreFailed,
      ImportFailure.noFile => l10n.backupRestoreNoFile,
      ImportFailure.tooLarge => l10n.backupRestoreTooLarge,
      ImportFailure.nothingToImport => l10n.backupRestoreNothing,
    };

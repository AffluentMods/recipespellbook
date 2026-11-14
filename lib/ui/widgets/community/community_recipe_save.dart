import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/community_recipe_saver.dart';
import '../app_snackbar.dart';

/// Saves recipe [recipeId] (or the one titled [title]) of publication
/// [publicationId] into [cookbookId], whole: the publication is fetched and
/// the recipe written as a download writes it, photos and sub-recipes
/// included. Shows a spinner while it runs and the outcome after. True when
/// it was saved.
Future<bool> saveCommunityRecipeWithFeedback(
  BuildContext context,
  WidgetRef ref, {
  required String publicationId,
  String? recipeId,
  required String title,
  required String cookbookId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  AppSnackbar.loading(context, l10n.communitySavingRecipe);
  CommunityRecipeSaveResult? result;
  try {
    result = await CommunityRecipeSaver(ref.read(databaseProvider)).save(
      publicationId: publicationId,
      recipeId: recipeId,
      title: title,
      cookbookId: cookbookId,
    );
  } catch (e) {
    debugPrint('[Community] save recipe: $e');
  }
  // The spinner sits on the root overlay and dismiss() does not use the
  // context: it must go even when this page has closed meanwhile.
  // ignore: use_build_context_synchronously
  AppSnackbar.dismiss(context);
  if (!context.mounted) return result?.saved ?? false;

  if (result == null || !result.saved) {
    AppSnackbar.error(
      context,
      result?.notFound == true ? l10n.communityRecipeNoLongerAvailable : l10n.communitySaveRecipeFailed,
    );
    return false;
  }
  final message = l10n.communityRecipeSaved(title);
  if (result.failedPhotos > 0) {
    AppSnackbar.warning(context, '$message\n${l10n.communityPhotosNotDownloaded(result.failedPhotos)}');
  } else {
    AppSnackbar.success(context, message);
  }
  return true;
}

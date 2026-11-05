import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/video_recipe_import.dart';
import 'ai_import_screen.dart';

// The pieces of the video import that the import sheet and a link shared
// into the app both use.

/// What to tell the person when a video could not be read.
String videoImportErrorMessage(AppLocalizations l10n, VideoImportException error) {
  final site = error.platform.displayName;
  switch (error.failure) {
    case VideoImportFailure.noRecipe:
      return l10n.videoImportNoRecipe;
    case VideoImportFailure.unavailable:
      return l10n.videoImportUnavailable;
    case VideoImportFailure.rateLimited:
      return l10n.videoImportRateLimited(site);
    case VideoImportFailure.offline:
      return l10n.videoImportOffline(site);
    case VideoImportFailure.timedOut:
      return l10n.videoImportTimedOut(site);
    case VideoImportFailure.blocked:
      // Instagram keeps captions from most visitors, so it gets the way
      // round that spelled out.
      return error.platform == VideoPlatform.instagram
          ? l10n.videoImportInstagramBlocked
          : l10n.videoImportBlocked(site);
    case VideoImportFailure.unreadable:
    case VideoImportFailure.notAVideo:
      return l10n.videoImportUnreadable;
  }
}

/// Asks whether the AI import should read a video whose text holds no
/// recipe the text importer can find. True when the person wants it.
Future<bool> askForVideoAiImport(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final useAi = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.auto_awesome_rounded),
      title: Text(l10n.videoImportNoRecipeTitle),
      content: Text(l10n.videoImportNoRecipeBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.videoImportUseAi),
        ),
      ],
    ),
  );
  return useAi == true;
}

/// The AI import, opened with the text of the video in [result], so the
/// prompt the person copies carries it along. The recipe keeps the video as
/// its source and its thumbnail as its picture.
Route<void> videoAiImportRoute(VideoImportResult result, String cookbookId) {
  return MaterialPageRoute(
    builder: (_) => AiImportScreen(
      cookbookId: cookbookId,
      sourceText: result.textForAi,
      sourceUrl: result.video.link.url,
      photoUrl: result.video.thumbnailUrl,
    ),
  );
}

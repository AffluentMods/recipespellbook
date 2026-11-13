import '../../../l10n/app_localizations.dart';
import '../../../services/web_import_error.dart';

// What the import sheet, the browser clipper, a link shared into the app and
// the shopping list's link import say when a web page gives no recipe.

/// Why no recipe could be read from a link, in the user's language.
String webImportErrorMessage(AppLocalizations l10n, WebImportException error) => switch (error.problem) {
      WebImportProblem.blocked => l10n.webImportBlocked,
      WebImportProblem.notFound => l10n.addRecipeLinkNotFound,
      WebImportProblem.rateLimited => l10n.webImportRateLimited,
      WebImportProblem.siteError => l10n.webImportSiteError(error.statusCode ?? 500),
      WebImportProblem.httpError => error.statusCode == null
          ? l10n.addRecipeLinkUnreadable
          : l10n.webImportHttpError(error.statusCode!),
      WebImportProblem.notAWebPage => l10n.webImportNotAWebPage(switch (error.fileKind) {
          WebImportFileKind.pdf => 'pdf',
          WebImportFileKind.image => 'image',
          WebImportFileKind.video => 'video',
          WebImportFileKind.audio => 'audio',
          WebImportFileKind.zip => 'zip',
          WebImportFileKind.file || null => 'other',
        }),
      WebImportProblem.tooLarge => l10n.webImportPageTooLarge,
      WebImportProblem.unreadableEncoding => l10n.webImportUnreadableEncoding(error.charset ?? '?'),
      WebImportProblem.needsLogin => l10n.addRecipeLinkNeedsLogin,
      WebImportProblem.noRecipeInVideo => l10n.webImportNoRecipeInVideo,
      WebImportProblem.noRecipe => l10n.importNoRecipeAtLink,
      WebImportProblem.timedOut => l10n.webImportTimedOut,
    };

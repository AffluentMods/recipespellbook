/// Why a recipe could not be read from a web address. The import engine says
/// it with one of these, and the screen says it in the user's language.
enum WebImportProblem {
  /// The site refused the request (HTTP 401, 403, 451, 455).
  blocked,

  /// No page at that address (HTTP 404, 410).
  notFound,

  /// The site answered 429: too many requests.
  rateLimited,

  /// The site answered with a server error (HTTP 5xx).
  siteError,

  /// Any other status but 200. [WebImportException.statusCode] says which.
  httpError,

  /// The link is a file, not a web page. [WebImportException.fileKind]
  /// says what kind.
  notAWebPage,

  /// The page is larger than the app reads.
  tooLarge,

  /// The page is in a character set the app has no table for.
  /// [WebImportException.charset] names it.
  unreadableEncoding,

  /// A login form stands where the recipe should be.
  needsLogin,

  /// A YouTube page whose description holds no recipe.
  noRecipeInVideo,

  /// The page was read and holds no recipe.
  noRecipe,

  /// The site did not answer in time.
  timedOut,
}

/// What a link that is not a web page turned out to be.
enum WebImportFileKind { pdf, image, video, audio, zip, file }

/// A recipe that could not be read from a web address. [message] says why in
/// English, for logs; the screen says [problem] in the user's language.
class WebImportException implements Exception {
  const WebImportException(this.problem, this.message, {this.statusCode, this.fileKind, this.charset});

  final WebImportProblem problem;

  /// The reason in English.
  final String message;

  /// For [WebImportProblem.siteError] and [WebImportProblem.httpError].
  final int? statusCode;

  /// For [WebImportProblem.notAWebPage].
  final WebImportFileKind? fileKind;

  /// For [WebImportProblem.unreadableEncoding].
  final String? charset;

  /// The way `Exception(message)` says it, as these were thrown before.
  @override
  String toString() => 'Exception: $message';
}

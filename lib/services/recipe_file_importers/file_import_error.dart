/// Why a file could not be imported. The importers say it with one of these,
/// and the screen says it in the user's language.
enum FileImportProblem {
  /// The file could not be read from where it is.
  unreadable,

  /// The file holds nothing.
  empty,

  /// The app reads no file of this kind.
  unsupported,

  /// The file is damaged, or is something other than text.
  notText,

  /// A rich text (RTF) document.
  richText,

  /// XML that is none of the recipe exports the app reads.
  unknownXml,

  /// A ZIP file that does not open.
  damagedZip,

  /// A backup of this app, which is restored rather than imported.
  ownBackup,

  /// An export of [FileImportException.app] that is damaged or cut short.
  damaged,

  /// An export of [FileImportException.app] with no recipes in it.
  noRecipes,

  /// An archive that unpacks to more than the app reads at once.
  tooLarge,
}

/// A file the importers could not read. It is still a [FormatException],
/// with the reason in English as its [message] for logs; the screen shows
/// [problem] in the user's language.
class FileImportException extends FormatException {
  const FileImportException(this.problem, String message, {this.app}) : super(message);

  final FileImportProblem problem;

  /// The app whose export it is, for [FileImportProblem.damaged] and
  /// [FileImportProblem.noRecipes]: "Paprika", "Mela", "MasterCook"...
  final String? app;

  /// An export of [app] that is damaged or incomplete.
  const FileImportException.damaged(String app)
      : this(FileImportProblem.damaged, 'This $app file is damaged or incomplete. Export it again and retry.', app: app);

  /// An export of [app] that holds none of its recipes. [message] says it in
  /// English.
  const FileImportException.noRecipes(String app, String message)
      : this(FileImportProblem.noRecipes, message, app: app);
}

/// An archive that unpacks to more than the app reads at once: a few
/// megabytes that unpack to gigabytes (a zip bomb), or an entry far larger
/// than any recipe file. The import stops instead of running out of memory.
class ZipTooLargeException extends FileImportException {
  const ZipTooLargeException()
      : super(FileImportProblem.tooLarge, 'This file unpacks to more than the app can read at once.');
}

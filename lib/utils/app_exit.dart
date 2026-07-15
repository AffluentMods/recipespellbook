/// Cross-platform app-quit helper. On native platforms this calls
/// `dart:io`'s `exit`; on web it is a no-op (there is no process to exit).
/// Conditional import keeps `dart:io` out of the web compilation graph.
export 'app_exit_stub.dart' if (dart.library.io) 'app_exit_io.dart';

import 'dart:io' as io;

/// Native: terminate the process (used only as an iOS fallback after
/// `SystemNavigator.pop()`).
void quitApp() => io.exit(0);

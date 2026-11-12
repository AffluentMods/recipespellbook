// Runs before every test file. Tests have no network (every HTTP request
// answers 400), so google_fonts must not try to download fonts: with runtime
// fetching off it falls back to the default font and only logs.
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}

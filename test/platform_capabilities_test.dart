// Features that only work on some platforms are switched off where they
// cannot work, rather than failing when used.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/utils/platform_utils.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  bool on(TargetPlatform platform, bool Function() flag) {
    debugDefaultTargetPlatformOverride = platform;
    return flag();
  }

  test('Sign in with Apple only on iOS (the Mac app lacks the entitlement)', () {
    expect(on(TargetPlatform.iOS, () => supportsAppleSignIn), isTrue);
    expect(on(TargetPlatform.macOS, () => supportsAppleSignIn), isFalse);
    expect(on(TargetPlatform.android, () => supportsAppleSignIn), isFalse);
  });

  test('cooking-mode voice is off on Linux, which speech_to_text lacks', () {
    expect(on(TargetPlatform.linux, () => supportsSpeechRecognition), isFalse);
    for (final p in [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS, TargetPlatform.windows]) {
      expect(on(p, () => supportsSpeechRecognition), isTrue, reason: '$p');
    }
  });

  test('files go through Save as on Linux, where the share sheet takes no files', () {
    expect(on(TargetPlatform.linux, () => supportsFileSharing), isFalse);
    for (final p in [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS, TargetPlatform.windows]) {
      expect(on(p, () => supportsFileSharing), isTrue, reason: '$p');
    }
  });

  test('push notification settings only where push exists', () {
    expect(on(TargetPlatform.android, () => supportsFirebaseMessaging), isTrue);
    expect(on(TargetPlatform.iOS, () => supportsFirebaseMessaging), isTrue);
    for (final p in [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux]) {
      expect(on(p, () => supportsFirebaseMessaging), isFalse, reason: '$p');
    }
  });
}

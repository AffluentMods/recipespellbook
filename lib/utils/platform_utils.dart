import 'package:flutter/foundation.dart';

/// Cross-platform detection — works on mobile, desktop, AND web.
/// Replaces all `dart:io` Platform usage (which breaks on web).
bool get isWeb => kIsWeb;

bool get isMobile =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

bool get isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

bool get isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get isWindows =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

/// Platform name string for analytics/feedback reporting.
String get platformName {
  if (kIsWeb) return 'web';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'android';
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.windows:
      return 'windows';
    case TargetPlatform.macOS:
      return 'macos';
    case TargetPlatform.linux:
      return 'linux';
    case TargetPlatform.fuchsia:
      return 'fuchsia';
  }
}

// ── Capability flags ──

/// Firebase Cloud Messaging — mobile only.
bool get supportsFirebaseMessaging => isMobile;

/// Google ML Kit OCR — mobile only.
bool get supportsOcr => isMobile;

/// Camera capture — mobile only (desktop/web lack reliable camera).
bool get supportsCamera => isMobile;

/// image_picker — mobile only. Desktop uses file_picker, web uses file upload.
bool get supportsImagePicker => isMobile;

/// mobile_scanner (barcode/QR) — mobile only.
bool get supportsBarcodeScanner => isMobile;

/// share_handler (receive share intents) — mobile only.
bool get supportsShareHandler => isMobile;

/// RevenueCat purchases_flutter SDK — mobile only.
/// Desktop/web use backend-based subscription validation.
bool get supportsRevenueCatSdk => isMobile;

/// Apple Sign-In — iOS and macOS only.
bool get supportsAppleSignIn => isIOS || isMacOS;

/// Native splash screen — mobile and desktop, not web.
bool get supportsNativeSplash => !kIsWeb;

/// Local file system for image storage — mobile and desktop, not web.
bool get supportsLocalFileSystem => !kIsWeb;

# Recipe Spellbook — Windows Desktop Change Specification

**Generated:** 2026-03-06
**App Version:** 1.2.1+9
**Target:** Windows 10/11 desktop (x64), Microsoft Store via MSIX

---

## Table of Contents

1. [Windows Runner Changes (DONE)](#1-windows-runner-changes-done)
2. [MSIX Packaging Setup](#2-msix-packaging-setup)
3. [App Icon](#3-app-icon)
4. [Critical: Platform Guard for Unsupported Plugins](#4-critical-platform-guard-for-unsupported-plugins)
5. [Firebase & Notifications](#5-firebase--notifications)
6. [Image Picking & Camera](#6-image-picking--camera)
7. [OCR / ML Kit](#7-ocr--ml-kit)
8. [Barcode Scanner](#8-barcode-scanner)
9. [Share Handler (Receive Intents)](#9-share-handler-receive-intents)
10. [Subscriptions / RevenueCat](#10-subscriptions--revenuecat)
11. [Auth Service — Secure Storage & Apple Sign-In](#11-auth-service--secure-storage--apple-sign-in)
12. [Feedback Service — Platform Detection](#12-feedback-service--platform-detection)
13. [Notification Service — Platform Detection](#13-notification-service--platform-detection)
14. [Image Service — Path Handling](#14-image-service--path-handling)
15. [Desktop UX — Navigation & Layout](#15-desktop-ux--navigation--layout)
16. [Desktop UX — Bottom Sheets to Dialogs](#16-desktop-ux--bottom-sheets-to-dialogs)
17. [Desktop UX — Keyboard Shortcuts](#17-desktop-ux--keyboard-shortcuts)
18. [Implementation Priority Order](#18-implementation-priority-order)

---

## 1. Windows Runner Changes (DONE)

These changes have already been applied in `windows/`:

### `windows/runner/main.cpp`
- Window title changed from `"recipespellbook"` to `"Recipe Spellbook"`
- Initial window size changed from `1280x720` to `1280x800` (more suitable for recipe content)

### `windows/runner/Runner.rc`
- CompanyName: `"com.example"` → `"Affluent Labs"`
- FileDescription: `"recipespellbook"` → `"Recipe Spellbook"`
- LegalCopyright: `"Copyright (C) 2026 com.example"` → `"Copyright (C) 2026 Affluent Labs"`
- ProductName: `"recipespellbook"` → `"Recipe Spellbook"`

### `windows/runner/win32_window.cpp`
- Added `WM_GETMINMAXINFO` handler to enforce minimum window size of 400x600 pixels, preventing the UI from becoming unusably small.

---

## 2. MSIX Packaging Setup

### What to do
Add the `msix` package to `pubspec.yaml` dev_dependencies and configure it for Microsoft Store distribution.

### File: `pubspec.yaml`
**Add to `dev_dependencies:`:**
```yaml
dev_dependencies:
  # ... existing deps ...
  msix: ^3.16.8
```

**Add new section at the end of pubspec.yaml:**
```yaml
msix_config:
  display_name: Recipe Spellbook
  publisher_display_name: Affluent Labs
  identity_name: AffluentLabs.RecipeSpellbook
  # Replace with your actual publisher ID from Microsoft Partner Center:
  publisher: CN=YOUR_PUBLISHER_ID
  msix_version: 1.2.1.0
  logo_path: assets/images/icon.png
  capabilities: internetClient, internetClientServer
  languages: en-us, sv, es, fr, de, it, pt, ja, ko, zh-hans
  store: true
```

### Build command
```bash
flutter pub run msix:create --store
```

---

## 3. App Icon

### What to do
The current `windows/runner/resources/app_icon.ico` is the default Flutter icon. It must be replaced with the Recipe Spellbook icon.

**Option A (recommended):** Use `flutter_launcher_icons` to auto-generate:
```yaml
# In pubspec.yaml, update flutter_launcher_icons config:
flutter_launcher_icons:
  android: true
  ios: true
  windows:
    generate: true
    icon_size: 48
    image_path: "assets/images/icon.png"
  image_path: "assets/images/icon.png"
```

Then run:
```bash
dart run flutter_launcher_icons
```

**Option B (manual):** Convert `assets/images/icon.png` to `.ico` format (256x256, 128x128, 64x64, 48x48, 32x32, 16x16 sizes) and replace `windows/runner/resources/app_icon.ico`.

---

## 4. Critical: Platform Guard for Unsupported Plugins

Several plugins will crash on Windows because they have no Windows implementation. The safest approach is a platform utility that gates functionality.

### New File: `lib/utils/platform_utils.dart`
```dart
import 'dart:io';

/// Platform capability flags for conditional feature availability.
class PlatformUtils {
  PlatformUtils._();

  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Firebase Cloud Messaging is only available on mobile.
  static bool get supportsFirebaseMessaging => isMobile;

  /// Google ML Kit OCR is only available on mobile.
  static bool get supportsOcr => isMobile;

  /// Camera capture via image_picker is only reliable on mobile.
  static bool get supportsCamera => isMobile;

  /// image_picker gallery works on mobile; on desktop, use file_picker instead.
  static bool get supportsImagePicker => isMobile;

  /// mobile_scanner (barcode/QR) is only available on mobile.
  static bool get supportsBarcodeScanner => isMobile;

  /// share_handler (receive share intents) is only available on mobile.
  static bool get supportsShareHandler => isMobile;

  /// RevenueCat purchases_flutter SDK works on mobile only.
  /// Desktop uses backend-based subscription validation.
  static bool get supportsRevenueCatSdk => isMobile;

  /// Apple Sign-In is available on iOS and macOS only.
  static bool get supportsAppleSignIn => Platform.isIOS || Platform.isMacOS;
}
```

**Priority:** P0 — Must be created before any other changes.

---

## 5. Firebase & Notifications

### Problem
`firebase_core` and `firebase_messaging` do not support Windows. The app will crash at startup in `main()` when calling `Firebase.initializeApp()`.

### File: `lib/main.dart` (lines 37-42)

**Before:**
```dart
try {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
} catch (e) {
  debugPrint('[Firebase] Initialization failed: $e');
}
```

**After:**
```dart
import 'utils/platform_utils.dart';

// ...

try {
  if (PlatformUtils.supportsFirebaseMessaging) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
} catch (e) {
  debugPrint('[Firebase] Initialization failed: $e');
}
```

### File: `lib/main.dart` (lines 166-173) — `_initBackground`

**Before:**
```dart
Future<void> _initBackground() async {
  try {
    await Future.wait([
      ref.read(subscriptionProvider.notifier).initialize(),
      NotificationService.instance.initialize(),
    ]);
  } catch (e) {
    debugPrint('[Init] Background init error: $e');
  }
}
```

**After:**
```dart
Future<void> _initBackground() async {
  try {
    final futures = <Future>[
      ref.read(subscriptionProvider.notifier).initialize(),
    ];
    if (PlatformUtils.supportsFirebaseMessaging) {
      futures.add(NotificationService.instance.initialize());
    }
    await Future.wait(futures);
  } catch (e) {
    debugPrint('[Init] Background init error: $e');
  }
}
```

### File: `lib/main.dart` (lines 177-188) — `_initShareHandler`

**Before:**
```dart
void _initShareHandler() {
  final handler = ShareHandlerPlatform.instance;
  // ...
}
```

**After:**
```dart
void _initShareHandler() {
  if (!PlatformUtils.supportsShareHandler) return;
  final handler = ShareHandlerPlatform.instance;
  // ...
}
```

### File: `lib/providers/auth_provider.dart` (lines 165-171) — `_syncAuthToServices`

**Before:**
```dart
if (jwt != null) {
  SmartImportService.instance.setAuthToken(jwt);
  NotificationService.instance.registerOnLogin(jwt);
}
```

**After:**
```dart
if (jwt != null) {
  SmartImportService.instance.setAuthToken(jwt);
  if (PlatformUtils.supportsFirebaseMessaging) {
    NotificationService.instance.registerOnLogin(jwt);
  }
}
```

**Priority:** P0 — App will crash at startup without this.

---

## 6. Image Picking & Camera

### Problem
`image_picker` does not support Windows. Camera is unavailable on most desktops. Gallery picking should fall back to `file_picker`.

### File: `lib/services/image_service.dart` (lines 52, 69-80, 288-301)

**Before:**
```dart
final _picker = ImagePicker();

Future<ImageUploadResult?> pickAndUploadFromGallery() async {
  final file = await _pickImage(ImageSource.gallery);
  if (file == null) return null;
  return uploadFile(file);
}

Future<ImageUploadResult?> pickAndUploadFromCamera() async {
  final file = await _pickImage(ImageSource.camera);
  if (file == null) return null;
  return uploadFile(file);
}

// ...

Future<File?> _pickImage(ImageSource source) async {
  try {
    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: maxDimension.toDouble(),
      maxHeight: maxDimension.toDouble(),
      imageQuality: jpegQuality,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  } catch (e) {
    debugPrint('[ImageService] Pick image error: $e');
    return null;
  }
}
```

**After:**
```dart
import 'package:file_picker/file_picker.dart';
import '../utils/platform_utils.dart';

// ...

final _picker = PlatformUtils.supportsImagePicker ? ImagePicker() : null;

Future<ImageUploadResult?> pickAndUploadFromGallery() async {
  final file = await _pickImage(ImageSource.gallery);
  if (file == null) return null;
  return uploadFile(file);
}

Future<ImageUploadResult?> pickAndUploadFromCamera() async {
  if (!PlatformUtils.supportsCamera) return null;
  final file = await _pickImage(ImageSource.camera);
  if (file == null) return null;
  return uploadFile(file);
}

/// Whether camera capture is available on this platform.
bool get isCameraAvailable => PlatformUtils.supportsCamera;

// ...

Future<File?> _pickImage(ImageSource source) async {
  try {
    if (PlatformUtils.supportsImagePicker) {
      final xFile = await _picker!.pickImage(
        source: source,
        maxWidth: maxDimension.toDouble(),
        maxHeight: maxDimension.toDouble(),
        imageQuality: jpegQuality,
      );
      if (xFile == null) return null;
      return File(xFile.path);
    }

    // Desktop fallback: use file_picker for gallery selection
    if (source == ImageSource.gallery) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return null;
      final path = result.files.single.path;
      if (path == null) return null;
      return File(path);
    }

    return null; // Camera not available on desktop
  } catch (e) {
    debugPrint('[ImageService] Pick image error: $e');
    return null;
  }
}
```

### UI Changes Required
Any screen that shows a "Take Photo" button needs to conditionally hide it on desktop:
- `lib/ui/widgets/new_recipe_dialog.dart`
- `lib/ui/widgets/recipe_edit_instructions.dart`
- `lib/ui/screens/shopping/shopping_screen.dart` (OCR camera button)

Example pattern:
```dart
if (PlatformUtils.supportsCamera)
  ListTile(
    leading: const Icon(Icons.camera_alt),
    title: Text('Take Photo'),
    onTap: () { /* camera logic */ },
  ),
```

**Priority:** P1 — Core feature (image picking for recipes).

---

## 7. OCR / ML Kit

### Problem
`google_mlkit_text_recognition` does not support Windows. OCR features must be disabled or replaced.

### File: `lib/services/ocr_service.dart`

**Approach:** Guard all methods with platform checks. The Smart Import feature (which sends images to a server-side API) already works as a fallback for text extraction.

**Before (line 65):**
```dart
Future<OcrResult> processMultipleImages(List<String> imagePaths, {
  void Function(int current, int total)? onProgress,
}) async {
  final textRecognizer = TextRecognizer();
  // ...
}
```

**After:**
```dart
import '../utils/platform_utils.dart';

// ...

Future<OcrResult> processMultipleImages(List<String> imagePaths, {
  void Function(int current, int total)? onProgress,
}) async {
  if (!PlatformUtils.supportsOcr) {
    return const OcrResult(
      text: '',
      confidence: 0.0,
      pageCount: 0,
    );
  }
  final textRecognizer = TextRecognizer();
  // ... rest unchanged
}

Future<OcrResult> processPdf(String pdfPath, {
  void Function(int current, int total)? onProgress,
}) async {
  if (!PlatformUtils.supportsOcr) {
    return const OcrResult(text: '', confidence: 0.0, pageCount: 0);
  }
  // ... rest unchanged
}
```

Also guard `pickFromCamera`, `pickFromGallery`, `pickMultipleFromGallery` (lines 30-54) with the same ImagePicker/file_picker fallback pattern from Section 6.

**Priority:** P1 — Prevents crash. URL import and text paste still work on desktop.

---

## 8. Barcode Scanner

### Problem
`mobile_scanner` does not support Windows. The QR code transfer feature will crash.

### File: `lib/ui/screens/import/transfer_screen.dart`

The transfer screen already has platform detection (line 33-41):
```dart
if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
  // Desktop mode
}
```

This screen appears to handle desktop already by showing a code-entry field instead of the camera scanner. Verify the mobile_scanner widget is not instantiated on desktop. If it is, wrap it:

```dart
if (PlatformUtils.supportsBarcodeScanner)
  MobileScanner(/* ... */)
else
  _DesktopCodeEntryWidget(),
```

**Priority:** P2 — Transfer screen already has desktop handling.

---

## 9. Share Handler (Receive Intents)

### Problem
`share_handler` does not support Windows. Receiving shared content from other apps is a mobile concept.

### Resolution
Already handled in Section 5 — the `_initShareHandler()` method returns early on non-mobile platforms.

On desktop, the equivalent is drag-and-drop or clipboard paste, which could be added later as a desktop enhancement.

**Priority:** P2 — Already handled by the guard in `_initShareHandler`.

---

## 10. Subscriptions / RevenueCat

### Problem
`purchases_flutter` does not support Windows. The SDK calls will crash.

### Strategy
RevenueCat unifies subscriptions across platforms using `app_user_id`. For Windows:

1. **Purchase flow:** Open a RevenueCat Web Purchase Link or Stripe Checkout in the system browser.
2. **Entitlement validation:** Your backend calls `GET /v1/subscribers/{app_user_id}` (RevenueCat REST API) and returns the subscription status to the app. **You already have this** — the app's `AuthUser.tier` field comes from the backend, and `RevenueCatService.setTierFromBackend()` uses it.

### File: `lib/services/revenuecat_service.dart`

**Before (lines 220-250):**
```dart
Future<void> initialize({String? userId}) async {
  if (_initialized) return;
  try {
    late PurchasesConfiguration config;
    if (defaultTargetPlatform == TargetPlatform.android) {
      config = PurchasesConfiguration(RCConfig.googleApiKey);
    } else {
      config = PurchasesConfiguration(RCConfig.appleApiKey);
    }
    // ...
    await Purchases.configure(config);
    // ...
  }
}
```

**After:**
```dart
import '../utils/platform_utils.dart';

// ...

Future<void> initialize({String? userId}) async {
  if (_initialized) return;

  if (!PlatformUtils.supportsRevenueCatSdk) {
    // Desktop: skip SDK initialization.
    // Subscription status comes from backend via setTierFromBackend().
    _initialized = true;
    debugPrint('[RevenueCat] Desktop mode — using backend-only tier validation');
    return;
  }

  try {
    late PurchasesConfiguration config;
    if (defaultTargetPlatform == TargetPlatform.android) {
      config = PurchasesConfiguration(RCConfig.googleApiKey);
    } else {
      config = PurchasesConfiguration(RCConfig.appleApiKey);
    }
    // ... rest unchanged
  }
}
```

Also guard all methods that call `Purchases.*`:

```dart
Future<void> refreshStatus() async {
  if (!PlatformUtils.supportsRevenueCatSdk) return;
  // ... existing code
}

Future<void> login(String userId) async {
  if (!_initialized || !PlatformUtils.supportsRevenueCatSdk) return;
  // ... existing code
}

Future<void> logout() async {
  if (!_initialized || !PlatformUtils.supportsRevenueCatSdk) return;
  // ... existing code
}

Future<Offerings?> getOfferings() async {
  if (!_initialized || !PlatformUtils.supportsRevenueCatSdk) return null;
  // ... existing code
}

Future<List<RCPackageInfo>> getPackages() async {
  if (!PlatformUtils.supportsRevenueCatSdk) return [];
  // ... existing code
}

Future<SubscriptionTier?> purchasePackage(Package package) async {
  if (!PlatformUtils.supportsRevenueCatSdk) return null;
  // ... existing code
}

Future<PaywallResult> presentPaywall({Offering? offering}) async {
  if (!PlatformUtils.supportsRevenueCatSdk) {
    return PaywallResult.cancelled;
  }
  // ... existing code
}

Future<void> presentCustomerCenter() async {
  if (!PlatformUtils.supportsRevenueCatSdk) return;
  // ... existing code
}

Future<SubscriptionTier> restorePurchases() async {
  if (!PlatformUtils.supportsRevenueCatSdk) return _currentTier;
  // ... existing code
}
```

### File: `lib/ui/screens/premium/paywall_screen.dart`

The paywall screen needs a desktop variant that:
- Shows subscription tiers and pricing (from your website data)
- Has a "Subscribe" button that opens `https://recipespellbook.app/pricing` (or a RevenueCat Web Purchase Link) via `url_launcher`
- Shows "Restore Purchases" that refreshes the tier from the backend

This is a bigger UI change — for the initial release, you could simply:
```dart
if (PlatformUtils.isDesktop) {
  // Show a simplified card with a "Subscribe on Web" button
  // that opens url_launcher to your pricing page
}
```

### Backend Changes (outside Flutter)
Your backend at `api.recipespellbook.app` already stores the user's tier. To support Windows:
1. Add a Stripe integration (you already have Stripe on the website)
2. When Stripe webhook confirms a subscription, update the user's `tier` field
3. Optionally, call RevenueCat's `POST /v1/receipts` with the Stripe subscription ID to keep RC in sync
4. The Flutter app's `GET /v1/auth/me` endpoint already returns `tier` — no app changes needed for validation

**Priority:** P0 — App will crash without the guards. Paywall UI changes are P2.

---

## 11. Auth Service — Secure Storage & Apple Sign-In

### File: `lib/services/auth_service.dart` (lines 112-115)

The `FlutterSecureStorage` configuration lacks Windows-specific options. While the package does support Windows (using Windows Credential Manager), it's good to be explicit.

**Before:**
```dart
final _storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);
```

**After:**
```dart
final _storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  // Windows uses Windows Credential Manager by default — no config needed.
  // Linux uses libsecret by default.
);
```

No code change needed here actually — just confirming it works. The `flutter_secure_storage` package supports Windows out of the box.

### Apple Sign-In

**File: `lib/providers/auth_provider.dart` (lines 196-201)**

Already correct — `isAppleSignInAvailable` returns `false` on Windows:
```dart
bool get isAppleSignInAvailable {
  try {
    return Platform.isIOS || Platform.isMacOS;
  } catch (_) {
    return false;
  }
}
```

**Priority:** P3 — No change needed, already compatible.

---

## 12. Feedback Service — Platform Detection

### File: `lib/services/feedback_service.dart` (lines 58-65, 92-103)

**Before:**
```dart
String platform;
if (Platform.isIOS) {
  platform = 'ios';
} else if (Platform.isAndroid) {
  platform = 'android';
} else {
  platform = 'web';
}
```

**After:**
```dart
String platform;
if (Platform.isIOS) {
  platform = 'ios';
} else if (Platform.isAndroid) {
  platform = 'android';
} else if (Platform.isWindows) {
  platform = 'windows';
} else if (Platform.isMacOS) {
  platform = 'macos';
} else if (Platform.isLinux) {
  platform = 'linux';
} else {
  platform = 'web';
}
```

**Before (lines 92-103):**
```dart
static Future<String> _getDeviceInfo() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return '${info.brand} ${info.model} · Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return '${info.name} · iOS ${info.systemVersion}';
    }
  } catch (_) {}
  return Platform.operatingSystem;
}
```

**After:**
```dart
static Future<String> _getDeviceInfo() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return '${info.brand} ${info.model} · Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return '${info.name} · iOS ${info.systemVersion}';
    } else if (Platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      return '${info.computerName} · Windows ${info.majorVersion}.${info.minorVersion} (Build ${info.buildNumber})';
    } else if (Platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      return '${info.computerName} · macOS ${info.osRelease}';
    }
  } catch (_) {}
  return Platform.operatingSystem;
}
```

**Priority:** P2 — Non-critical but improves bug reports from Windows users.

---

## 13. Notification Service — Platform Detection

### File: `lib/services/notification_service.dart` (line 172)

**Before:**
```dart
body: jsonEncode({
  'token': _fcmToken,
  'platform': Platform.isIOS ? 'ios' : 'android',
}),
```

**After:**
```dart
body: jsonEncode({
  'token': _fcmToken,
  'platform': Platform.isIOS ? 'ios' : 'android',
  // Note: this code path is only reached on mobile (guarded by PlatformUtils),
  // so 'android' is the correct fallback for non-iOS mobile.
}),
```

Actually no change needed here because the entire `NotificationService.initialize()` is guarded at the call site (Section 5). This code path will never execute on Windows.

**Priority:** P3 — Already handled by initialization guard.

---

## 14. Image Service — Path Handling

### File: `lib/services/image_service.dart` (lines 267-273)

The code uses `/` as path separator which actually works on Windows in Dart (unlike native C). However, it's better practice to use the `path` package.

**Before:**
```dart
final appDir = await getApplicationDocumentsDirectory();
final communityDir = Directory('${appDir.path}/images/community');
if (!await communityDir.exists()) {
  await communityDir.create(recursive: true);
}
final localFile = File('${communityDir.path}/$filename');
```

**After:**
```dart
import 'package:path/path.dart' as p;

// ...

final appDir = await getApplicationDocumentsDirectory();
final communityDir = Directory(p.join(appDir.path, 'images', 'community'));
if (!await communityDir.exists()) {
  await communityDir.create(recursive: true);
}
final localFile = File(p.join(communityDir.path, filename));
```

Note: The `path` package is already a dependency. The `p.join()` pattern is already used elsewhere in the file (line 6, 306).

**Priority:** P3 — Low risk since Dart handles `/` on Windows, but good hygiene.

---

## 15. Desktop UX — Navigation & Layout

### Current State
- Bottom navigation bar with 5 items (NotchNavBar) — mobile-optimized
- End drawer for hamburger menu
- `responsive_utils.dart` already defines breakpoints: compact (<600), medium (600-900), expanded (900-1200), large (>1200)
- 16 files already use responsive utilities

### Recommended Approach for V1

**Don't redesign the navigation yet.** The bottom nav + drawer works acceptably on desktop for an initial release. Focus on:

1. **Max content width constraint** — Many screens will look stretched at 1920px+ widths. The existing `Responsive.constrainWidth()` and `Responsive.maxContentWidth()` utilities handle this. Ensure all major screens use them.

2. **Grid columns** — The existing `Responsive.recipeGridColumns()` already scales from 2 (phone) to 4+ (desktop). Verify it's used consistently.

### Screens Needing Responsive Review (by priority)

| Screen | File | Lines | Issue |
|--------|------|-------|-------|
| Home | `home_screen.dart` | 1,433 | Verify grid scales well |
| Recipe List | `recipe_list_screen.dart` | 1,405 | Already uses responsive utils |
| Recipe Detail | `recipe_screen.dart` | 1,894 | Long single-column — add max-width |
| Recipe Edit | `recipe_edit_screen.dart` | 2,762 | Form too wide on desktop |
| Shopping | `shopping_screen.dart` | 3,619 | List items stretch too wide |
| Settings | `settings_screen.dart` | 1,437 | Settings list needs max-width |
| Planner | `planner_screen.dart` | 1,135 | Calendar could use wider layout |

### Quick Win Pattern
For any screen that doesn't use `constrainWidth()`, wrap the body:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: _buildContent(),
      ),
    ),
  );
}
```

**Priority:** P2 — Cosmetic but important for a good first impression.

---

## 16. Desktop UX — Bottom Sheets to Dialogs

### Problem
21 files use `showModalBottomSheet`. On desktop, these slide up from the bottom and look out of place — they work but feel mobile.

### Recommended V1 Approach
Create a helper that shows a dialog on desktop and a bottom sheet on mobile:

### New File: `lib/utils/adaptive_sheet.dart`
```dart
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// Shows a bottom sheet on mobile, a dialog on desktop.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  double maxDialogWidth = 480,
  double maxDialogHeight = 600,
}) {
  if (PlatformUtils.isDesktop) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxDialogWidth,
            maxHeight: maxDialogHeight,
          ),
          child: builder(ctx),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    builder: builder,
  );
}
```

Then migrate `showModalBottomSheet` calls to `showAdaptiveSheet` gradually.

**Priority:** P3 — Bottom sheets work on desktop, just look a bit off. Migrate gradually.

---

## 17. Desktop UX — Keyboard Shortcuts

### Recommended Shortcuts for V1

These can be added incrementally. Use Flutter's `Shortcuts` + `Actions` widget pattern.

| Shortcut | Action |
|----------|--------|
| Ctrl+N | New recipe |
| Ctrl+F | Search |
| Ctrl+S | Save (in edit mode) |
| Ctrl+, | Open settings |
| Escape | Close dialog / go back |
| Ctrl+1-5 | Switch between nav tabs |
| Ctrl+I | Import recipe |
| F5 | Sync |

### Implementation
Wrap the app shell with a `Shortcuts`/`Actions` widget:

```dart
// In app_shell.dart
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
        const _NewRecipeIntent(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
        const _SearchIntent(),
    // ...
  },
  child: Actions(
    actions: {
      _NewRecipeIntent: CallbackAction<_NewRecipeIntent>(
        onInvoke: (_) => _showNewRecipeDialog(),
      ),
      _SearchIntent: CallbackAction<_SearchIntent>(
        onInvoke: (_) => context.push('/search'),
      ),
    },
    child: Focus(
      autofocus: true,
      child: existingShellWidget,
    ),
  ),
)
```

**Priority:** P3 — Enhancement, not required for initial release.

---

## 18. Implementation Priority Order

### P0 — Must Fix (App Won't Launch Without These)

| # | Change | File(s) | Est. Effort |
|---|--------|---------|-------------|
| 1 | Create `platform_utils.dart` | New file | 5 min |
| 2 | Guard Firebase init in main.dart | `lib/main.dart` | 10 min |
| 3 | Guard NotificationService init | `lib/main.dart` | 5 min |
| 4 | Guard ShareHandler init | `lib/main.dart` | 2 min |
| 5 | Guard RevenueCat SDK calls | `lib/services/revenuecat_service.dart` | 15 min |
| 6 | Guard NotificationService in auth_provider | `lib/providers/auth_provider.dart` | 2 min |

### P1 — Core Features (Broken Without These)

| # | Change | File(s) | Est. Effort |
|---|--------|---------|-------------|
| 7 | Image picking desktop fallback | `lib/services/image_service.dart` | 20 min |
| 8 | OCR service platform guard | `lib/services/ocr_service.dart` | 10 min |
| 9 | Hide camera buttons on desktop | Multiple UI files | 15 min |
| 10 | MSIX packaging config | `pubspec.yaml` | 10 min |
| 11 | App icon generation | `pubspec.yaml` + run command | 5 min |

### P2 — Important Polish

| # | Change | File(s) | Est. Effort |
|---|--------|---------|-------------|
| 12 | Feedback service platform detection | `lib/services/feedback_service.dart` | 10 min |
| 13 | Paywall screen desktop variant | `lib/ui/screens/premium/paywall_screen.dart` | 30 min |
| 14 | Responsive max-width on major screens | Multiple screen files | 1-2 hours |
| 15 | Backend Stripe integration | Backend (not Flutter) | 2-4 hours |

### P3 — Nice to Have (Post-Launch)

| # | Change | File(s) | Est. Effort |
|---|--------|---------|-------------|
| 16 | Adaptive bottom sheets → dialogs | Create utility + migrate 21 files | 2-3 hours |
| 17 | Keyboard shortcuts | `lib/ui/shell/app_shell.dart` | 1-2 hours |
| 18 | Image path hygiene (p.join) | `lib/services/image_service.dart` | 5 min |
| 19 | Right-click context menus | Various screens | 2-3 hours |
| 20 | Hover states on interactive elements | Theme-level change | 1-2 hours |
| 21 | Desktop navigation sidebar (V2) | `lib/ui/shell/app_shell.dart` | 4-8 hours |

---

## Plugin Compatibility Summary

| Plugin | Windows Support | Action Needed |
|--------|----------------|---------------|
| `drift` / `sqlite3_flutter_libs` | Yes | None |
| `path_provider` | Yes | None |
| `google_sign_in` | Yes | None |
| `sign_in_with_apple` | No (iOS/macOS only) | Already guarded |
| `flutter_riverpod` | Yes | None |
| `flutter_secure_storage` | Yes | None |
| `go_router` | Yes | None |
| `firebase_core` | No | Guard init |
| `firebase_messaging` | No | Guard init |
| `flutter_local_notifications` | No | Guard init |
| `image_picker` | No | Fallback to file_picker |
| `file_picker` | Yes | None |
| `share_plus` | Yes | None |
| `share_handler` | No | Guard init |
| `google_mlkit_text_recognition` | No | Guard/disable |
| `mobile_scanner` | No | Already has desktop fallback |
| `purchases_flutter` | No | Guard + backend validation |
| `purchases_ui_flutter` | No | Guard |
| `url_launcher` | Yes | None |
| `google_fonts` | Yes | None |
| `cached_network_image` | Yes | None |
| `video_player` | Yes | None |
| `pdfx` | Yes | None |
| `printing` | Yes | None |
| `shared_preferences` | Yes | None |
| `package_info_plus` | Yes | None |
| `device_info_plus` | Yes | None |
| `photo_view` | Yes | None |
| `qr_flutter` | Yes | None |
| `app_links` | Yes | None |
| `http` | Yes | None |

---

## Build & Test Commands

```bash
# Development build
flutter run -d windows --dart-define-from-file=.env

# Release build
flutter build windows --dart-define-from-file=.env --release

# MSIX package for Store
flutter pub run msix:create --store

# Test specific Windows build
flutter build windows --dart-define-from-file=.env --debug
```

---

## Notes

- The app already has good responsive foundations (`responsive_utils.dart` with breakpoints and grid helpers).
- The auth flow (Google Sign-In) works on Windows without changes.
- Cloud sync, database, and all HTTP-based features work out of the box.
- The RPG boss screen's swipe gesture (`onHorizontalDragEnd`) should get a keyboard alternative (e.g., arrow keys) but is non-critical.
- `flutter_native_splash` works on Windows — no changes needed.

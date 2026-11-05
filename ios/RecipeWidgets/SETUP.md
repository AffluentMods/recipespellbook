# Home screen widgets on iOS

This folder holds the WidgetKit extension for the two home screen widgets,
"Today's meals" and "Shopping list". The extension target
**RecipeWidgetsExtension** is in `ios/Runner.xcodeproj` and is embedded in
the app, so `flutter build ios` and the IPA build script build it together
with Runner. Nothing has to be added in Xcode any more; what is left is
listed under "What is left" below.

## What is here

| File | What it is |
| --- | --- |
| `RecipeWidgetsBundle.swift` | The extension's entry point (`@main`), lists both widgets |
| `TodaysMealsWidget.swift` | Today's meals: timeline (turns the page at midnight), views |
| `ShoppingListWidget.swift` | Shopping list: timeline, views |
| `WidgetSnapshot.swift` | Reads the JSON the app writes into the App Group |
| `WidgetTheme.swift` | Cream and terracotta colours (light and dark), shared views |
| `*.lproj/Localizable.strings` | Widget names, descriptions and empty states in the app's 12 languages |
| `Info.plist` | Extension Info.plist (WidgetKit extension point, app version) |
| `RecipeWidgets.entitlements` | App Group `group.com.affluentlabs.recipespellbook` |
| `RecipeWidgets.xcconfig` | Pulls in Flutter's version numbers for the extension |

How the data gets there: the app (`lib/services/home_widget_service.dart`)
writes a JSON snapshot through the `home_widget` plugin into the
UserDefaults of the App Group `group.com.affluentlabs.recipespellbook` and
asks WidgetKit to reload the kinds `TodaysMealsWidget` and
`ShoppingListWidget`. Taps open `recipespellbook://recipe/<id>`,
`recipespellbook://planner` or `recipespellbook://shopping`, which the app
already handles.

The App Group id appears in four places and must be identical:
`HomeWidgetService.iosAppGroupId` (Dart), `WidgetSnapshot.appGroup` (Swift),
`Runner/Runner.entitlements` and `RecipeWidgets/RecipeWidgets.entitlements`.

## How the target is set up

- **Target** `RecipeWidgetsExtension`: app extension
  (`com.apple.product-type.app-extension`), product
  `RecipeWidgetsExtension.appex`, bundle id
  `com.affluentlabs.recipespellbook.RecipeWidgets`, iOS 16.0, Swift 5,
  automatic signing with team D52P6T66KW. Links WidgetKit and SwiftUI.
- **Group** `RecipeWidgets` (this folder): the five Swift files are in the
  extension's Sources phase and `Localizable.strings` (a localized file with
  all 12 languages) in its Resources phase. `Info.plist`,
  `RecipeWidgets.entitlements`, `RecipeWidgets.xcconfig` and this file are
  in the group only, in no build phase.
- **Build settings** (Debug, Release and Profile): Info.plist File
  `RecipeWidgets/Info.plist` (no generated Info.plist), Code Signing
  Entitlements `RecipeWidgets/RecipeWidgets.entitlements`, Marketing Version
  `$(FLUTTER_BUILD_NAME)`, Current Project Version `$(FLUTTER_BUILD_NUMBER)`,
  `APPLICATION_EXTENSION_API_ONLY = YES`, `SKIP_INSTALL = YES`, devices
  iPhone and iPad. The configuration file of all three is
  `RecipeWidgets/RecipeWidgets.xcconfig`, which includes Flutter's
  `Generated.xcconfig`, so the widget always has the app's version (the App
  Store refuses an extension whose version differs from its app's).
- **Embedding**: target Runner has an **Embed Foundation Extensions** phase
  (destination PlugIns) with `RecipeWidgetsExtension.appex`, directly after
  Copy Bundle Resources and before Flutter's Thin Binary and
  [CP] Embed Pods Frameworks phases, and a target dependency on
  RecipeWidgetsExtension, so the extension is built first.
- **App Group**: both entitlements files list
  `group.com.affluentlabs.recipespellbook`.
- **CocoaPods**: the Podfile only has the Runner target, so the extension
  gets no pods. That is intended: it only uses system frameworks. Its
  `post_install` only touches the Pods project, so `pod install` works
  unchanged.

The target was added from the command line with the `xcodeproj` Ruby gem
(the same library CocoaPods uses), not with Xcode's template. To change it
later, use Xcode as usual: open `ios/Runner.xcworkspace`, project Runner,
target RecipeWidgetsExtension.

## What is left

### 1. Apple Developer portal (only if signing complains)

The IPA build script archives with automatic signing and
`-allowProvisioningUpdates`, which normally registers the new App ID and
the App Group by itself. If the archive fails with a provisioning or App
Group error, check developer.apple.com > Certificates, Identifiers &
Profiles > Identifiers and add what is missing:

1. **App Groups**: `group.com.affluentlabs.recipespellbook`
   (description, for example, "Recipe Spellbook widgets").
2. **App IDs** > `com.affluentlabs.recipespellbook`: App Groups capability
   ticked, Configure > select the group above. Save.
3. **App IDs** > `com.affluentlabs.recipespellbook.RecipeWidgets` (register it
   if it is not there): App Groups ticked and configured with the same group.

Changing an App ID's capabilities invalidates its provisioning profiles.
Automatic signing makes new ones on the next build; any manually made
profiles for these IDs have to be regenerated. Then run the build again.

### 2. Signed build

On the Mac mini, as usual: unlock the keychain, then run the IPA build
script (`security unlock-keychain ... && zsh ~/build_rs_ipa.sh`).

### 3. Try it on a phone

1. Open the app once (it writes the first snapshot).
2. Long-press the home screen > **+** > Recipe Spellbook. Both widgets are
   listed, in small, medium and large.
3. Plan a meal for today: Today's meals updates. Tap the meal (medium or
   large): the recipe opens. Tap the Shopping list widget: Shopping opens.

## Checking a build without signing

```sh
flutter pub get
flutter build ios --debug --no-codesign
```

`build/ios/iphoneos/Runner.app/PlugIns/RecipeWidgetsExtension.appex` must
exist, with the `RecipeWidgetsExtension` binary, the 12 `.lproj` folders and
an Info.plist whose `CFBundleShortVersionString` and `CFBundleVersion` match
the app's.

## If something goes wrong

- **Build error "Cycle inside Runner; building could produce unreliable
  results"**: target Runner > Build Phases, **Embed Foundation Extensions**
  must sit directly after **Copy Bundle Resources**, above the Flutter
  **Thin Binary** and **[CP] Embed Pods Frameworks** phases.
- **The widget says "Nothing planned today" or "Your list is empty" although
  there is data**: the App Group is missing on one of the targets (or in the
  developer portal), or the ids differ. Check the four places listed at the
  top.
- **The widget is not in the gallery**: the extension's iOS Deployment Target
  is newer than the phone's iOS (it must stay 16.0), or the extension is not
  embedded in Runner (target Runner > Build Phases > Embed Foundation
  Extensions should list `RecipeWidgetsExtension.appex`).
- **App Store upload rejects the version**: the extension's version must
  match the app's. Check the configuration file (`RecipeWidgets.xcconfig`)
  and the two version settings above.

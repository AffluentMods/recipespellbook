# Home screen widgets on iOS: Xcode setup

This folder holds the WidgetKit extension for the two home screen widgets,
"Today's meals" and "Shopping list". The code is finished, but the extension
target is not in `ios/Runner.xcodeproj` yet: adding a target by editing
`project.pbxproj` by hand is too risky, so it is done once in Xcode with the
steps below. It takes about 15 minutes on the Mac mini.

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

The App Group id appears in three places and must be identical:
`HomeWidgetService.iosAppGroupId` (Dart), `WidgetSnapshot.appGroup` (Swift)
and the App Groups capability of both targets.

## 1. Move these sources aside

Xcode's Widget Extension template writes its own `RecipeWidgetsBundle.swift`
and `Info.plist` into `ios/RecipeWidgets/`, which would overwrite these. So
move the folder out of the way first:

```sh
cd ios
mv RecipeWidgets RecipeWidgets.src
```

## 2. Add the Widget Extension target

1. Open `ios/Runner.xcworkspace` in Xcode (the workspace, not the project).
2. File > New > Target... > iOS > **Widget Extension** > Next.
3. Fill in:
   - Product Name: **RecipeWidgets**
   - Team: Affluent Labs (D52P6T66KW)
   - Bundle Identifier: Xcode shows `com.affluentlabs.recipespellbook.RecipeWidgets`. Keep it.
   - Untick **Include Live Activity**, **Include Control** and **Include Configuration App Intent** (whichever your Xcode shows).
   - Project: Runner. Embed in Application: **Runner**.
4. Finish. When Xcode asks whether to activate the `RecipeWidgetsExtension`
   scheme, choose **Don't Activate** so `Runner` stays the active scheme.

Xcode names the target **RecipeWidgetsExtension** and the folder and group
**RecipeWidgets**.

## 3. Put these sources in place of the generated ones

1. In the Project navigator, open the new **RecipeWidgets** group. Select
   every file Xcode made in it **except `Assets.xcassets`**:
   `RecipeWidgets.swift`, `RecipeWidgetsBundle.swift`, `Info.plist`, and if
   present `RecipeWidgetsLiveActivity.swift`, `RecipeWidgetsControl.swift`,
   `AppIntent.swift`. Press Delete and choose **Move to Trash**.
2. In Terminal, move the sources back in:

   ```sh
   cd ios
   mv RecipeWidgets.src/* RecipeWidgets/
   rmdir RecipeWidgets.src
   ```

3. In Xcode, right-click the **RecipeWidgets** group > **Add Files to "Runner"...**,
   go to `ios/RecipeWidgets/` and select:
   - the five `.swift` files
   - the twelve `.lproj` folders (Xcode shows them as one localized `Localizable.strings`)

   Options: **Create groups**, and under Add to targets tick
   **RecipeWidgetsExtension only** (untick Runner). Click Add.
4. Optional, for visibility only: add `Info.plist`, `RecipeWidgets.entitlements`,
   `RecipeWidgets.xcconfig` and `SETUP.md` the same way but with **no target
   ticked**. They must not be in the extension's Copy Bundle Resources.

## 4. Build settings of RecipeWidgetsExtension

Select the Runner project, then the **RecipeWidgetsExtension** target, then
Build Settings (All, Combined). Set, for all configurations:

| Setting | Value |
| --- | --- |
| iOS Deployment Target | **16.0** (same as Runner; the template picks the newest iOS, which would hide the widget on older phones) |
| Info.plist File | `RecipeWidgets/Info.plist` (usually already set) |
| Code Signing Entitlements | `RecipeWidgets/RecipeWidgets.entitlements` |
| Marketing Version | `$(FLUTTER_BUILD_NAME)` |
| Current Project Version | `$(FLUTTER_BUILD_NUMBER)` |

Then select the **Runner project** (not a target) > Info > Configurations.
Expand Debug, Release and Profile and set the configuration file of
**RecipeWidgetsExtension** to **RecipeWidgets/RecipeWidgets.xcconfig** in each.
This gives the extension the app's version, which the App Store requires.
Leave Runner's own entries as they are.

## 5. App Group on both targets

1. Target **Runner** > Signing & Capabilities > **+ Capability** > **App Groups**.
   Click **+** under App Groups and enter `group.com.affluentlabs.recipespellbook`,
   then make sure it is ticked. Xcode adds it to `Runner/Runner.entitlements`.
2. Target **RecipeWidgetsExtension** > Signing & Capabilities: Automatically
   manage signing on, Team D52P6T66KW. **+ Capability** > **App Groups** and tick
   `group.com.affluentlabs.recipespellbook`. (It writes into
   `RecipeWidgets/RecipeWidgets.entitlements`, which already lists it.)

## 6. Apple Developer portal

With automatic signing, Xcode normally registers all of this during step 5.
Check it at developer.apple.com > Certificates, Identifiers & Profiles >
Identifiers, and add what is missing:

1. **App Groups**: `group.com.affluentlabs.recipespellbook`
   (description, for example, "Recipe Spellbook widgets").
2. **App IDs** > `com.affluentlabs.recipespellbook`: App Groups capability
   ticked, Configure > select the group above. Save.
3. **App IDs** > `com.affluentlabs.recipespellbook.RecipeWidgets` (register it
   if Xcode did not): App Groups ticked and configured with the same group.

Changing an App ID's capabilities invalidates its provisioning profiles.
Automatic signing makes new ones on the next build; any manually made
profiles for these IDs have to be regenerated.

## 7. Build and try it

```sh
flutter pub get
cd ios && pod install && cd ..
flutter build ios --debug
```

Or run the Runner scheme from Xcode on a phone. Then:

1. Open the app once (it writes the first snapshot).
2. Long-press the home screen > **+** > Recipe Spellbook. Both widgets are
   listed, in small, medium and large.
3. Plan a meal for today: Today's meals updates. Tap the meal (medium or
   large): the recipe opens. Tap the Shopping list widget: Shopping opens.

## If something goes wrong

- **Build error "Cycle inside Runner; building could produce unreliable
  results"**: target Runner > Build Phases, drag **Embed Foundation
  Extensions** (or Embed App Extensions) up so it sits directly after
  **Copy Bundle Resources**, above the Flutter **Thin Binary** and
  **[CP] Embed Pods Frameworks** phases.
- **The widget says "Nothing planned today" or "Your list is empty" although
  there is data**: the App Group is missing on one of the targets, or the ids
  differ. Check step 5 and the three places listed at the top.
- **The widget is not in the gallery**: the extension's iOS Deployment Target
  is newer than the phone's iOS (step 4), or the extension is not embedded
  in Runner (target Runner > Build Phases > Embed Foundation Extensions
  should list `RecipeWidgetsExtension.appex`).
- **App Store upload rejects the version**: the extension's version must
  match the app's. Check step 4 (xcconfig and the two version settings).

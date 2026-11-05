import SwiftUI
import WidgetKit

/// Recipe Spellbook's home screen widgets. See SETUP.md in this folder for
/// adding the extension to the Xcode project.
@main
struct RecipeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodaysMealsWidget()
        ShoppingListWidget()
    }
}

import SwiftUI
import WidgetKit

/// Recipe Spellbook's home screen widgets. See SETUP.md in this folder for how
/// the extension target is set up in the Xcode project.
@main
struct RecipeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodaysMealsWidget()
        ShoppingListWidget()
    }
}

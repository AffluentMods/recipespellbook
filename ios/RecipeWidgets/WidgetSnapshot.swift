import Foundation

/// The snapshot the app writes for the home screen widgets
/// (lib/services/home_widget_snapshot.dart). home_widget saves it as a JSON
/// string in the App Group's UserDefaults; the widgets only read it.
///
/// Words in it (titles, empty states, meal types) are in the app's language.
/// Until the app has written one, the widgets use Localizable.strings.
struct WidgetSnapshot: Decodable {
    /// Must match HomeWidgetService.iosAppGroupId in the app and the App
    /// Groups capability of both the Runner and this extension.
    static let appGroup = "group.com.affluentlabs.recipespellbook"
    /// Must match homeWidgetSnapshotKey in home_widget_snapshot.dart.
    static let key = "rsb_widget_snapshot"

    static let defaultShoppingURL = URL(string: "recipespellbook://shopping")!
    static let defaultPlannerURL = URL(string: "recipespellbook://planner")!

    struct Labels: Decodable {
        let mealsTitle: String?
        let mealsEmpty: String?
        let shoppingTitle: String?
        let shoppingEmpty: String?
    }

    struct Meal: Decodable {
        let title: String
        let type: String?
        let typeLabel: String?
        /// "HH:mm", or nil when the meal has no clock time.
        let time: String?
        let recipeId: String?
        let link: String?

        var url: URL { link.flatMap { URL(string: $0) } ?? WidgetSnapshot.defaultPlannerURL }
    }

    struct Day: Decodable {
        let total: Int?
        let items: [Meal]?
    }

    struct Meals: Decodable {
        let link: String?
        /// Today and the coming days, keyed "yyyy-MM-dd". A missing day has
        /// nothing planned.
        let days: [String: Day]?
    }

    struct ShoppingItem: Decodable {
        let name: String
        let detail: String?
    }

    struct Shopping: Decodable {
        let link: String?
        let listId: String?
        let name: String?
        let unchecked: Int?
        let items: [ShoppingItem]?
    }

    let v: Int?
    let today: String?
    let labels: Labels?
    let meals: Meals?
    let shopping: Shopping?

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let raw = defaults.string(forKey: key),
              let data = raw.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    /// The meals planned on [date] (at most 8) and how many there are in all.
    func mealsPlanned(on date: Date) -> (items: [Meal], total: Int) {
        let day = meals?.days?[Self.dayKey(date)]
        let items = day?.items ?? []
        return (items, max(day?.total ?? items.count, items.count))
    }

    var mealsURL: URL { meals?.link.flatMap { URL(string: $0) } ?? Self.defaultPlannerURL }
    var shoppingURL: URL { shopping?.link.flatMap { URL(string: $0) } ?? Self.defaultShoppingURL }

    static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// "HH:mm" as a date on [day], to be shown in the phone's own time format.
    static func clockTime(_ hhmm: String?, on day: Date, calendar: Calendar = .current) -> Date? {
        guard let parts = hhmm?.split(separator: ":"), parts.count == 2,
              let hour = Int(parts[0]), let minute = Int(parts[1]),
              (0..<24).contains(hour), (0..<60).contains(minute)
        else { return nil }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
    }
}

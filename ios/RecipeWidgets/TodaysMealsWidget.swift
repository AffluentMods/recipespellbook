import SwiftUI
import WidgetKit

// "Today's meals": the meals planned for today in the order of the day. A
// meal opens its recipe (recipespellbook://recipe/<id>), anything else opens
// the planner. The app reloads this widget whenever meals change; the
// timeline below also turns the page at each midnight on its own, from the
// coming days the snapshot carries.

struct MealsEntry: TimelineEntry {
    let date: Date
    let title: String
    let emptyText: String
    let meals: [WidgetSnapshot.Meal]
    let total: Int
    let url: URL
    var isPlaceholder = false

    static func make(for date: Date, from snapshot: WidgetSnapshot?) -> MealsEntry {
        let today = snapshot?.mealsPlanned(on: date) ?? (items: [], total: 0)
        return MealsEntry(
            date: date,
            title: snapshot?.labels?.mealsTitle ?? NSLocalizedString("meals.title", comment: ""),
            emptyText: snapshot?.labels?.mealsEmpty ?? NSLocalizedString("meals.empty", comment: ""),
            meals: today.items,
            total: today.total,
            url: snapshot?.mealsURL ?? WidgetSnapshot.defaultPlannerURL
        )
    }

    /// Grey rows for the widget gallery before there is anything to show.
    /// The text is never read: the view redacts it.
    static var placeholder: MealsEntry {
        let meal = WidgetSnapshot.Meal(
            title: "Planned meal", type: nil, typeLabel: "Dinner",
            time: nil, recipeId: nil, link: nil
        )
        return MealsEntry(
            date: Date(),
            title: NSLocalizedString("meals.title", comment: ""),
            emptyText: "",
            meals: [meal, meal, meal],
            total: 3,
            url: WidgetSnapshot.defaultPlannerURL,
            isPlaceholder: true
        )
    }
}

struct MealsProvider: TimelineProvider {
    func placeholder(in context: Context) -> MealsEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (MealsEntry) -> Void) {
        let entry = MealsEntry.make(for: Date(), from: WidgetSnapshot.load())
        completion(context.isPreview && entry.meals.isEmpty ? .placeholder : entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MealsEntry>) -> Void) {
        let snapshot = WidgetSnapshot.load()
        let calendar = Calendar.current
        let now = Date()
        var entries = [MealsEntry.make(for: now, from: snapshot)]
        // One entry at each coming midnight the snapshot can answer for.
        var day = calendar.startOfDay(for: now)
        for _ in 0..<7 {
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
            entries.append(.make(for: day, from: snapshot))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct TodaysMealsView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MealsEntry

    /// Rows that fit with the heading and a "+N" line.
    private var capacity: Int {
        switch family {
        case .systemSmall, .systemMedium: return 3
        default: return 8
        }
    }

    private var shown: [WidgetSnapshot.Meal] { Array(entry.meals.prefix(capacity)) }

    /// A small widget can only open one link: the meal, when there is one.
    private var tapURL: URL {
        family == .systemSmall && entry.meals.count == 1 ? entry.meals[0].url : entry.url
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(systemImage: "fork.knife", title: entry.title, count: entry.total)
            if entry.meals.isEmpty {
                EmptyLine(text: entry.emptyText)
            } else {
                VStack(alignment: .leading, spacing: family == .systemSmall ? 4 : 3) {
                    ForEach(Array(shown.enumerated()), id: \.offset) { _, meal in
                        if family == .systemSmall {
                            SmallMealRow(meal: meal, day: entry.date)
                        } else {
                            Link(destination: meal.url) {
                                MealRow(meal: meal, day: entry.date)
                            }
                        }
                    }
                }
                Spacer(minLength: 0)
                MoreLine(hidden: entry.total - shown.count)
            }
        }
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
        .widgetURL(tapURL)
        .widgetBackground()
    }
}

/// Meal type, title and time, for the medium and large widgets.
struct MealRow: View {
    let meal: WidgetSnapshot.Meal
    let day: Date

    var body: some View {
        HStack(spacing: 8) {
            if let type = meal.typeLabel {
                Text(verbatim: type)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(WidgetTheme.accent)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(WidgetTheme.accentSoft))
            }
            Text(verbatim: meal.title)
                .font(.subheadline)
                .foregroundColor(WidgetTheme.text)
                .lineLimit(1)
            Spacer(minLength: 4)
            if let time = WidgetSnapshot.clockTime(meal.time, on: day) {
                Text(time, style: .time)
                    .font(.caption)
                    .foregroundColor(WidgetTheme.textMuted)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(WidgetTheme.row)
        )
    }
}

/// Title and time on one line, for the small widget.
struct SmallMealRow: View {
    let meal: WidgetSnapshot.Meal
    let day: Date

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(WidgetTheme.accent)
                .frame(width: 5, height: 5)
            Text(verbatim: meal.title)
                .font(.footnote)
                .foregroundColor(WidgetTheme.text)
                .lineLimit(1)
            Spacer(minLength: 2)
            if let time = WidgetSnapshot.clockTime(meal.time, on: day) {
                Text(time, style: .time)
                    .font(.caption2)
                    .foregroundColor(WidgetTheme.textMuted)
                    .lineLimit(1)
            }
        }
    }
}

struct TodaysMealsWidget: Widget {
    /// Must match HomeWidgetService.iosMealsKind in the app.
    let kind = "TodaysMealsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MealsProvider()) { entry in
            TodaysMealsView(entry: entry)
        }
        .configurationDisplayName("meals.title")
        .description("meals.description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

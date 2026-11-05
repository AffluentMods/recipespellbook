import SwiftUI
import WidgetKit

// "Shopping list": the list the Shopping screen last showed, how many items
// are left and the first of them. A tap opens Shopping
// (recipespellbook://shopping). Only the app changes the list, so the app
// reloads this widget whenever it changes and the timeline never expires.

struct ShoppingEntry: TimelineEntry {
    let date: Date
    let title: String
    let emptyText: String
    let items: [WidgetSnapshot.ShoppingItem]
    let unchecked: Int
    let url: URL
    var isPlaceholder = false

    static func make(from snapshot: WidgetSnapshot?) -> ShoppingEntry {
        let shopping = snapshot?.shopping
        let items = shopping?.items ?? []
        return ShoppingEntry(
            date: Date(),
            title: shopping?.name
                ?? snapshot?.labels?.shoppingTitle
                ?? NSLocalizedString("shopping.title", comment: ""),
            emptyText: snapshot?.labels?.shoppingEmpty ?? NSLocalizedString("shopping.empty", comment: ""),
            items: items,
            unchecked: max(shopping?.unchecked ?? items.count, items.count),
            url: snapshot?.shoppingURL ?? WidgetSnapshot.defaultShoppingURL
        )
    }

    /// Grey rows for the widget gallery before there is anything to show.
    /// The text is never read: the view redacts it.
    static var placeholder: ShoppingEntry {
        let item = WidgetSnapshot.ShoppingItem(name: "Shopping item", detail: nil)
        return ShoppingEntry(
            date: Date(),
            title: NSLocalizedString("shopping.title", comment: ""),
            emptyText: "",
            items: [item, item, item, item],
            unchecked: 4,
            url: WidgetSnapshot.defaultShoppingURL,
            isPlaceholder: true
        )
    }
}

struct ShoppingProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShoppingEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (ShoppingEntry) -> Void) {
        let entry = ShoppingEntry.make(from: WidgetSnapshot.load())
        completion(context.isPreview && entry.items.isEmpty ? .placeholder : entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShoppingEntry>) -> Void) {
        completion(Timeline(entries: [.make(from: WidgetSnapshot.load())], policy: .never))
    }
}

struct ShoppingListView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ShoppingEntry

    /// Rows that fit with the heading and a "+N" line.
    private var capacity: Int {
        switch family {
        case .systemSmall, .systemMedium: return 4
        default: return 8
        }
    }

    private var shown: [WidgetSnapshot.ShoppingItem] { Array(entry.items.prefix(capacity)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(systemImage: "cart", title: entry.title, count: entry.unchecked)
            if entry.items.isEmpty {
                EmptyLine(text: entry.emptyText)
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(shown.enumerated()), id: \.offset) { _, item in
                        ShoppingRow(item: item, showDetail: family != .systemSmall)
                    }
                }
                Spacer(minLength: 0)
                MoreLine(hidden: entry.unchecked - shown.count)
            }
        }
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
        .widgetURL(entry.url)
        .widgetBackground()
    }
}

struct ShoppingRow: View {
    let item: WidgetSnapshot.ShoppingItem
    let showDetail: Bool

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "circle")
                .font(.caption2)
                .foregroundColor(WidgetTheme.textMuted)
                .accessibilityHidden(true)
            Text(verbatim: item.name)
                .font(.footnote)
                .foregroundColor(WidgetTheme.text)
                .lineLimit(1)
            Spacer(minLength: 4)
            if showDetail, let detail = item.detail {
                Text(verbatim: detail)
                    .font(.caption)
                    .foregroundColor(WidgetTheme.textMuted)
                    .lineLimit(1)
            }
        }
    }
}

struct ShoppingListWidget: Widget {
    /// Must match HomeWidgetService.iosShoppingKind in the app.
    let kind = "ShoppingListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShoppingProvider()) { entry in
            ShoppingListView(entry: entry)
        }
        .configurationDisplayName("shopping.title")
        .description("shopping.description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

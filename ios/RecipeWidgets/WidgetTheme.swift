import SwiftUI
import UIKit
import WidgetKit

/// The app's warm cream and terracotta, light and dark. Same values as the
/// Android widgets (android/app/src/main/res/values*/widget_colors.xml).
enum WidgetTheme {
    static let background = Color(light: 0xFBF3E8, dark: 0x231B14)
    static let row = Color(light: 0xF3E4D2, dark: 0x30261D)
    static let text = Color(light: 0x3A2E24, dark: 0xF0E7DC)
    static let textMuted = Color(light: 0x7D6B5B, dark: 0xB9A796)
    static let accent = Color(light: 0xB85C38, dark: 0xEE9A6E)
    static let accentSoft = Color(light: 0xF1D6C6, dark: 0x4A3124)
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x2A1A10)

    /// Headings use a serif, like the app's Fraunces titles.
    static let title = Font.system(.subheadline, design: .serif).weight(.bold)
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension View {
    /// The widget's cream background: the container background on iOS 17 and
    /// newer (which also gives the system margins), padding and a fill before.
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) { WidgetTheme.background }
        } else {
            padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(WidgetTheme.background)
        }
    }
}

/// Icon, heading and a count bubble, at the top of both widgets.
struct WidgetHeader: View {
    let systemImage: String
    let title: String
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundColor(WidgetTheme.accent)
                .accessibilityHidden(true)
            Text(verbatim: title)
                .font(WidgetTheme.title)
                .foregroundColor(WidgetTheme.text)
                .lineLimit(1)
            Spacer(minLength: 4)
            if count > 0 {
                Text(verbatim: "\(count)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(WidgetTheme.onAccent)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(WidgetTheme.accent))
            }
        }
    }
}

/// "+3" under a list that has more than fits.
struct MoreLine: View {
    let hidden: Int

    var body: some View {
        if hidden > 0 {
            HStack {
                Spacer()
                Text(verbatim: "+\(hidden)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(WidgetTheme.textMuted)
            }
        }
    }
}

/// The empty state, centred in the space under the heading.
struct EmptyLine: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.footnote)
            .foregroundColor(WidgetTheme.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

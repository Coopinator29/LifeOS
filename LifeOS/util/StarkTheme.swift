import SwiftUI

enum StarkTheme {
    static let ember = Color(red: 0.72, green: 0.14, blue: 0.12)
    static let emberDeep = Color(red: 0.34, green: 0.05, blue: 0.04)
    static let obsidian = Color(red: 0.03, green: 0.04, blue: 0.06)
    static let graphite = Color(red: 0.11, green: 0.14, blue: 0.19)
    static let steel = Color(red: 0.42, green: 0.48, blue: 0.56)
    static let arcBlue = Color(red: 0.30, green: 0.82, blue: 1.0)
    static let arcBlueDeep = Color(red: 0.10, green: 0.36, blue: 0.54)
    static let success = Color(red: 0.34, green: 0.84, blue: 0.63)
    static let warning = Color(red: 0.98, green: 0.74, blue: 0.28)

    static let backgroundGradient = LinearGradient(
        colors: [
            emberDeep,
            graphite,
            obsidian
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [
            steel.opacity(0.14),
            arcBlue.opacity(0.08),
            ember.opacity(0.10),
            Color.black.opacity(0.52)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let elevatedCardGradient = LinearGradient(
        colors: [
            arcBlue.opacity(0.16),
            steel.opacity(0.10),
            ember.opacity(0.12),
            Color.black.opacity(0.46)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let controlGradient = LinearGradient(
        colors: [
            arcBlue.opacity(0.42),
            ember.opacity(0.28),
            graphite
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

import SwiftUI

struct PageHeaderCard<TrailingContent: View>: View {
    let sectionLabel: String
    let title: String
    let subtitle: String
    @ViewBuilder let trailingContent: TrailingContent

    init(
        sectionLabel: String,
        title: String,
        subtitle: String,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.sectionLabel = sectionLabel
        self.title = title
        self.subtitle = subtitle
        self.trailingContent = trailingContent()
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(sectionLabel)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .tracking(3)
                    .foregroundStyle(StarkTheme.arcBlue.opacity(0.88))

                Text(title)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(StarkTheme.steel.opacity(0.9))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailingContent
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .padding(.vertical, 2)
        .padding(.horizontal, 16)
        .background(StarkTheme.elevatedCardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: StarkTheme.arcBlue.opacity(0.12), radius: 18, y: 8)
    }
}

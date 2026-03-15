import SwiftUI

struct LifePage: Identifiable {
    let id: Int
    let title: String
    let systemImage: String
}

struct BottomNavigationDock: View {
    static let reservedBottomInset: CGFloat = 94

    let pages: [LifePage]
    let selectedPage: Int
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Button {
                    onSelect(page.id)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: page.systemImage)
                            .font(.system(size: 14, weight: .bold))

                        Text(page.title)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                    }
                    .foregroundStyle(selectedPage == page.id ? .white : StarkTheme.steel.opacity(0.88))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedPage == page.id ? AnyShapeStyle(StarkTheme.controlGradient) : AnyShapeStyle(StarkTheme.cardGradient))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedPage == page.id ? StarkTheme.arcBlue.opacity(0.35) : StarkTheme.steel.opacity(0.14), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.black.opacity(0.38))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.16), lineWidth: 1)
        )
    }
}

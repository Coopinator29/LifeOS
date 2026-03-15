import SwiftUI

struct ContentView: View {
    @StateObject private var tapStore = TapCounterStore()
    @StateObject private var gymStore = GymStore()
    @StateObject private var proteinStore = ProteinStore()
    @StateObject private var debtStore = DebtStore()
    @State private var selectedPage = 1

    private let pages: [LifePage] = [
        LifePage(id: 0, title: "Finance", systemImage: "sterlingsign.circle.fill"),
        LifePage(id: 1, title: "Core", systemImage: "circle.grid.2x2.fill"),
        LifePage(id: 2, title: "Gym", systemImage: "dumbbell.fill"),
        LifePage(id: 3, title: "Calendar", systemImage: "calendar"),
        LifePage(id: 4, title: "Review", systemImage: "chart.line.uptrend.xyaxis")
    ]

    var body: some View {
        TabView(selection: $selectedPage) {
            FinancePage(store: debtStore)
                .tag(0)

            mainPage
                .tag(1)

            GymView(store: gymStore)
                .tag(2)

            GymCalendarPage(store: gymStore, proteinStore: proteinStore)
                .tag(3)

            WeeklyReviewPage(gymStore: gymStore, proteinStore: proteinStore, debtStore: debtStore)
                .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            BottomNavigationDock(
                pages: pages,
                selectedPage: selectedPage,
                onSelect: { pageID in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        selectedPage = pageID
                    }
                }
            )
                .padding(.horizontal, 18)
                .padding(.bottom, 0)
                .offset(y: 12)
        }
    }

    private var mainPage: some View {
        ZStack {
            StarkTheme.backgroundGradient
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 50)

                Text("LIFE OS")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("CORE SYSTEM")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .tracking(3)
                    .foregroundStyle(StarkTheme.arcBlue.opacity(0.9))

                ReactorView(
                    tapCount: tapStore.tapCount,
                    onTap: {
                        tapStore.increment()
                    }
                )

                ProteinView(store: proteinStore)

                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.and.right")
                    Text("Swipe or use the dock for Finance, Gym, Calendar, and Review")
                }
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(StarkTheme.steel.opacity(0.85))
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .padding(.bottom, BottomNavigationDock.reservedBottomInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}

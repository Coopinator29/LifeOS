import SwiftUI

struct GymCalendarPage: View {
    @ObservedObject var store: GymStore
    @ObservedObject var proteinStore: ProteinStore

    var body: some View {
        ZStack {
            StarkTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer(minLength: 2)

                PageHeaderCard(
                    sectionLabel: "CALENDAR",
                    title: "Gym History",
                    subtitle: "\(store.completedWorkouts.count) workouts logged in total"
                ) {
                    VStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(StarkTheme.arcBlue)

                        Text("\(store.completedWorkouts.count)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 64, height: 64)
                    .background(StarkTheme.cardGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
                    )
                }

                GymCalendarView(store: store, proteinStore: proteinStore)
                    .padding(.top, 0)

                Spacer(minLength: 8)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, BottomNavigationDock.reservedBottomInset/1.6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

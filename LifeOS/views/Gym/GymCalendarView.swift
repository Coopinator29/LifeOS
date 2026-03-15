import SwiftUI

private struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isInDisplayedMonth: Bool
}

struct GymCalendarView: View {
    @ObservedObject var store: GymStore
    @ObservedObject var proteinStore: ProteinStore

    @State private var displayedMonth = Calendar.current.startOfMonth(for: Date())
    @State private var selectedDate: Date?

    private let calendar = Calendar.current

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var days: [CalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end),
            let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: lastDayOfMonth)
        else {
            return []
        }

        let range = DateInterval(start: firstWeekInterval.start, end: lastWeekInterval.end)
        var currentDate = range.start
        var values: [CalendarDay] = []

        while currentDate < range.end {
            values.append(
                CalendarDay(
                    date: currentDate,
                    isInDisplayedMonth: calendar.isDate(currentDate, equalTo: displayedMonth, toGranularity: .month)
                )
            )
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return values
    }

    private var selectedWorkouts: [CompletedWorkout] {
        guard let selectedDate else { return [] }
        return store.workouts(on: selectedDate)
    }

    private var selectedProtein: Double {
        guard let selectedDate else { return 0 }
        return proteinStore.protein(on: selectedDate)
    }

    var body: some View {
        VStack(spacing: 10) {
            if let selectedDate {
                ScrollView(showsIndicators: false) {
                    selectedDayCard(for: selectedDate)
                        .padding(.bottom, 12)
                }
            } else {
                calendarCard
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var calendarCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TRAINING CALENDAR")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .tracking(2.5)
                        .foregroundStyle(StarkTheme.arcBlue.opacity(0.88))

                    Text(monthTitle)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                HStack(spacing: 10) {
                    monthButton(systemName: "chevron.left", step: -1)
                    monthButton(systemName: "chevron.right", step: 1)
                }
            }

            weekdayHeader

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(days) { day in
                    dayCell(for: day)
                }
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(StarkTheme.arcBlue)
                    .frame(width: 8, height: 8)

                Text("Blue marker indicates a gym session was logged.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(StarkTheme.steel.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(StarkTheme.elevatedCardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: StarkTheme.arcBlue.opacity(0.12), radius: 18, y: 8)
    }

    private var weekdayHeader: some View {
        let weekdaySymbols = calendar.veryShortWeekdaySymbols

        return HStack(spacing: 6) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(StarkTheme.steel.opacity(0.82))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(for day: CalendarDay) -> some View {
        let hasWorkout = store.hasWorkout(on: day.date)
        let isToday = calendar.isDateInToday(day.date)

        return Button {
            selectedDate = day.date
        } label: {
            VStack(spacing: 6) {
                Text(day.date.formatted(.dateTime.day()))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(day.isInDisplayedMonth ? .white : StarkTheme.steel.opacity(0.45))

                Circle()
                    .fill(hasWorkout ? StarkTheme.arcBlue : .clear)
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(dayBackgroundStyle(isToday: isToday))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(isToday ? StarkTheme.arcBlue.opacity(0.42) : StarkTheme.steel.opacity(0.14), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!day.isInDisplayedMonth)
        .opacity(day.isInDisplayedMonth ? 1 : 0.45)
    }

    private func selectedDayCard(for date: Date) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DAY REVIEW")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .tracking(2.5)
                        .foregroundStyle(StarkTheme.arcBlue.opacity(0.88))

                    Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                Button {
                    selectedDate = nil
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(StarkTheme.controlGradient)
                        .clipShape(Capsule())
                }
            }

            if selectedWorkouts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(StarkTheme.steel.opacity(0.78))

                    Text("No workouts logged")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("This day is clear in your training log.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(StarkTheme.steel.opacity(0.88))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
            }

            proteinSnapshot

            if !selectedWorkouts.isEmpty {
                VStack(spacing: 12) {
                    ForEach(selectedWorkouts) { workout in
                        workoutSnapshot(for: workout)
                    }
                }
            }
        }
        .padding(16)
        .background(StarkTheme.elevatedCardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: StarkTheme.arcBlue.opacity(0.12), radius: 18, y: 8)
    }

    private var proteinSnapshot: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Protein")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                metricPill(title: "Total", value: "\(formattedNumber(selectedProtein))g")
                metricPill(title: "Status", value: selectedProtein > 0 ? "Logged" : "None")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.16), lineWidth: 1)
        )
    }

    private func workoutSnapshot(for workout: CompletedWorkout) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(workout.exerciseName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                metricPill(title: "Sets", value: "\(workout.setsCount)")
                metricPill(title: "Reps", value: "\(workout.totalReps)")
                metricPill(title: "Top KG", value: formattedNumber(workout.heaviestWeight))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.16), lineWidth: 1)
        )
    }

    private func metricPill(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.82))
                .tracking(1.2)

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(StarkTheme.arcBlue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func monthButton(systemName: String, step: Int) -> some View {
        Button {
            if let nextMonth = calendar.date(byAdding: .month, value: step, to: displayedMonth) {
                displayedMonth = calendar.startOfMonth(for: nextMonth)
                selectedDate = nil
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(StarkTheme.controlGradient)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }

        return String(format: "%.1f", value)
    }

    private func dayBackgroundStyle(isToday: Bool) -> AnyShapeStyle {
        if isToday {
            return AnyShapeStyle(StarkTheme.arcBlue.opacity(0.16))
        }

        return AnyShapeStyle(StarkTheme.cardGradient)
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date)) ?? date
    }
}

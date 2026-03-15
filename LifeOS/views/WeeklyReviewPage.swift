import SwiftUI

private struct WeeklyDaySummary: Identifiable {
    let id = UUID()
    let date: Date
    let workouts: [CompletedWorkout]
    let protein: Double

    var totalVolume: Double {
        workouts.reduce(0) { $0 + $1.totalVolume }
    }
}

struct WeeklyReviewPage: View {
    @ObservedObject var gymStore: GymStore
    @ObservedObject var proteinStore: ProteinStore
    @ObservedObject var debtStore: DebtStore

    private let calendar = Calendar.current

    private var weekInterval: DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: Date()) ?? DateInterval(start: Date(), duration: 604800)
    }

    private var weekDays: [WeeklyDaySummary] {
        var days: [WeeklyDaySummary] = []
        var currentDate = weekInterval.start

        while currentDate < weekInterval.end {
            days.append(
                WeeklyDaySummary(
                    date: currentDate,
                    workouts: gymStore.workouts(on: currentDate),
                    protein: proteinStore.protein(on: currentDate)
                )
            )
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return days
    }

    private var workoutsThisWeek: Int {
        weekDays.reduce(0) { $0 + $1.workouts.count }
    }

    private var workoutDaysCount: Int {
        weekDays.filter { !$0.workouts.isEmpty }.count
    }

    private var averageProtein: Double {
        guard !weekDays.isEmpty else { return 0 }
        let total = weekDays.reduce(0) { $0 + $1.protein }
        return total / Double(weekDays.count)
    }

    private var weeklyVolume: Double {
        weekDays.reduce(0) { $0 + $1.totalVolume }
    }

    private var bestProteinDay: WeeklyDaySummary? {
        weekDays.max { $0.protein < $1.protein }
    }

    private var bestVolumeDay: WeeklyDaySummary? {
        weekDays.max { $0.totalVolume < $1.totalVolume }
    }

    private var insightLine: String {
        if workoutDaysCount >= 4 && averageProtein >= 150 {
            return "Training and nutrition both stayed sharp this week."
        }

        if workoutDaysCount >= 4 && averageProtein < 120 {
            return "Training volume is there, but protein is lagging behind recovery needs."
        }

        if workoutDaysCount <= 1 && averageProtein >= 150 {
            return "Protein stayed strong, but training consistency dropped."
        }

        if workoutDaysCount == 0 {
            return "No gym sessions logged this week. Reset momentum with one session tomorrow."
        }

        return "Midweek consistency looks like the biggest lever for a better next week."
    }

    private var wins: [String] {
        var items: [String] = []

        if workoutDaysCount >= 4 {
            items.append("Trained on \(workoutDaysCount) days this week.")
        }

        if averageProtein >= 140 {
            items.append("Average protein stayed at \(formattedNumber(averageProtein))g.")
        }

        if let bestVolumeDay, bestVolumeDay.totalVolume > 0 {
            items.append("Best training day was \(bestVolumeDay.date.formatted(.dateTime.weekday(.wide))) at \(formattedNumber(bestVolumeDay.totalVolume)) kg volume.")
        }

        if items.isEmpty {
            items.append("You logged data this week, which keeps the review useful.")
        }

        return items
    }

    private var misses: [String] {
        var items: [String] = []

        let zeroProteinDays = weekDays.filter { $0.protein == 0 }.count
        if zeroProteinDays > 0 {
            items.append("\(zeroProteinDays) day\(zeroProteinDays == 1 ? "" : "s") ended with zero protein logged.")
        }

        if workoutDaysCount < 3 {
            items.append("Only \(workoutDaysCount) workout day\(workoutDaysCount == 1 ? "" : "s") logged this week.")
        }

        if let bestProteinDay, bestProteinDay.protein > 0, averageProtein < bestProteinDay.protein * 0.6 {
            items.append("Protein intake was inconsistent compared with your best day.")
        }

        if items.isEmpty {
            items.append("No major misses showed up in this week’s logs.")
        }

        return items
    }

    var body: some View {
        ZStack {
            StarkTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Spacer(minLength: 2)

                    headerCard
                    scorecardGrid
                    weekTimelineCard
                    summaryCard(title: "Wins", items: wins, accent: StarkTheme.success)
                    summaryCard(title: "Misses", items: misses, accent: StarkTheme.warning)
                    insightCard
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, BottomNavigationDock.reservedBottomInset)
            }
        }
    }

    private var headerCard: some View {
        PageHeaderCard(
            sectionLabel: "WEEKLY REVIEW",
            title: "System Check",
            subtitle: weekRangeLabel
        ) {
            VStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(StarkTheme.arcBlue)

                Text("7D")
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
    }

    private var scorecardGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            scoreCard(title: "Workouts", value: "\(workoutsThisWeek)", subtitle: "\(workoutDaysCount) active days")
            scoreCard(title: "Avg Protein", value: "\(formattedNumber(averageProtein))g", subtitle: "Across 7 days")
            scoreCard(title: "Volume", value: "\(formattedNumber(weeklyVolume))", subtitle: "Total kg logged")
            scoreCard(title: "Debt Snapshot", value: currency(debtStore.totalDebt), subtitle: currency(debtStore.totalMonthlyPayments) + " monthly")
        }
    }

    private var weekTimelineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Week Timeline")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                ForEach(weekDays) { day in
                    VStack(spacing: 8) {
                        Text(day.date.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(StarkTheme.steel.opacity(0.82))

                        Text(day.date.formatted(.dateTime.day()))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Circle()
                            .fill(day.workouts.isEmpty ? StarkTheme.steel.opacity(0.28) : StarkTheme.arcBlue)
                            .frame(width: 8, height: 8)

                        Text(day.protein > 0 ? "\(Int(day.protein))g" : "--")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(day.protein > 0 ? .white : StarkTheme.steel.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(StarkTheme.arcBlue.opacity(calendar.isDateInToday(day.date) ? 0.16 : 0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
        )
    }

    private func summaryCard(title: String, items: [String], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: title == "Wins" ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(accent)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)

                    Text(item)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
        )
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("One-Line Insight")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(insightLine)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(StarkTheme.steel.opacity(0.95))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(StarkTheme.elevatedCardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
        )
    }

    private func scoreCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.82))

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(StarkTheme.steel.opacity(0.88))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
        )
    }

    private var weekRangeLabel: String {
        let endDate = calendar.date(byAdding: .day, value: 6, to: weekInterval.start) ?? weekInterval.start
        return "\(weekInterval.start.formatted(.dateTime.day().month(.abbreviated))) - \(endDate.formatted(.dateTime.day().month(.abbreviated).year()))"
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }

        return String(format: "%.1f", value)
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "£0"
    }
}

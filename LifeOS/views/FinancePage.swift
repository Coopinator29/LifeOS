import SwiftUI

struct FinancePage: View {
    @ObservedObject var store: DebtStore

    @State private var showingEditor = false

    var body: some View {
        ZStack {
            StarkTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Spacer(minLength: 2)

                    headerCard

                    overviewCard
                    loanCard
                    creditCard
                    monthsLeftCard
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, BottomNavigationDock.reservedBottomInset)
            }
        }
        .sheet(isPresented: $showingEditor) {
            DebtEditorSheet(store: store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerCard: some View {
        PageHeaderCard(
            sectionLabel: "FINANCE",
            title: "Debt Control",
            subtitle: "Loan and credit-card overview at a glance."
        ) {
            Button {
                showingEditor = true
            } label: {
                Label("Edit", systemImage: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(StarkTheme.controlGradient)
                    .clipShape(Capsule())
            }
        }
    }

    private var overviewCard: some View {
        financeCard(title: "Debt Overview", systemImage: "chart.bar.xaxis") {
            HStack(spacing: 12) {
                metricPill(title: "Total Debt", value: currency(store.totalDebt))
                metricPill(title: "Monthly", value: currency(store.totalMonthlyPayments))
            }
        }
    }

    private var loanCard: some View {
        financeCard(title: "Loan Balance", systemImage: "building.columns.fill") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    metricPill(title: "Balance", value: currency(store.loanBalance))
                    metricPill(title: "Payment", value: currency(store.loanMonthlyPayment))
                    metricPill(title: "APR", value: percent(store.loanAPR))
                }

                timelineRow(
                    title: "Loan Timeline",
                    months: store.loanMonthsLeft,
                    progress: payoffProgress(for: store.loanMonthsLeft)
                )
            }
        }
    }

    private var creditCard: some View {
        financeCard(title: "Credit Card", systemImage: "creditcard.fill") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    metricPill(title: "Balance", value: currency(store.creditCardBalance))
                    metricPill(title: "Limit", value: currency(store.creditCardLimit))
                    metricPill(title: "Min Pay", value: currency(store.creditCardMinimumPayment))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Utilization")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(StarkTheme.steel.opacity(0.9))

                        Spacer()

                        Text(percent(store.creditUtilization * 100))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(StarkTheme.arcBlue.opacity(0.10))

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            StarkTheme.arcBlue,
                                            utilizationColor
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: proxy.size.width * store.creditUtilization)
                        }
                    }
                    .frame(height: 10)
                }

                timelineRow(
                    title: "Card Payoff",
                    months: store.creditCardMonthsLeft,
                    progress: payoffProgress(for: store.creditCardMonthsLeft)
                )
            }
        }
    }

    private var monthsLeftCard: some View {
        financeCard(title: "Overall Debt Timeline", systemImage: "calendar.badge.clock") {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(monthsLeftValue)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(monthsLeftSubtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(StarkTheme.steel.opacity(0.9))
                }

                Spacer()
            }

            timelineBar(progress: 1)
        }
    }

    private func financeCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: StarkTheme.arcBlue.opacity(0.08), radius: 10, y: 6)
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
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(StarkTheme.arcBlue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var monthsLeftValue: String {
        if let months = store.overallDebtTimelineMonths {
            return "\(months)"
        }

        return "--"
    }

    private var monthsLeftSubtitle: String {
        if store.overallDebtTimelineMonths != nil {
            return "Longest remaining payoff timeline across your entered debts."
        }

        return "Add balances and monthly payments to estimate individual payoff timelines."
    }

    private var utilizationColor: Color {
        switch store.creditUtilization {
        case 0..<0.3: return StarkTheme.success
        case 0.3..<0.7: return StarkTheme.warning
        default: return StarkTheme.ember
        }
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "£0"
    }

    private func percent(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }

    private func timelineRow(title: String, months: Int?, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(StarkTheme.steel.opacity(0.9))

                Spacer()

                Text(timelineLabel(for: months))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            timelineBar(progress: progress)
        }
    }

    private func timelineBar(progress: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(StarkTheme.arcBlue.opacity(0.10))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                StarkTheme.arcBlue,
                                StarkTheme.warning
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(proxy.size.width * min(max(progress, 0), 1), progress > 0 ? 12 : 0))
            }
        }
        .frame(height: 10)
    }

    private func payoffProgress(for months: Int?) -> Double {
        guard let months, let overall = store.overallDebtTimelineMonths, overall > 0 else { return 0 }
        return Double(months) / Double(overall)
    }

    private func timelineLabel(for months: Int?) -> String {
        guard let months else { return "Not set" }
        return months == 1 ? "1 month left" : "\(months) months left"
    }
}

private struct DebtEditorSheet: View {
    @ObservedObject var store: DebtStore
    @Environment(\.dismiss) private var dismiss

    @State private var loanBalance: String
    @State private var loanMonthlyPayment: String
    @State private var loanAPR: String
    @State private var creditCardBalance: String
    @State private var creditCardLimit: String
    @State private var creditCardMinimumPayment: String
    @State private var creditCardAPR: String

    init(store: DebtStore) {
        self.store = store
        _loanBalance = State(initialValue: Self.string(for: store.loanBalance))
        _loanMonthlyPayment = State(initialValue: Self.string(for: store.loanMonthlyPayment))
        _loanAPR = State(initialValue: Self.string(for: store.loanAPR))
        _creditCardBalance = State(initialValue: Self.string(for: store.creditCardBalance))
        _creditCardLimit = State(initialValue: Self.string(for: store.creditCardLimit))
        _creditCardMinimumPayment = State(initialValue: Self.string(for: store.creditCardMinimumPayment))
        _creditCardAPR = State(initialValue: Self.string(for: store.creditCardAPR))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Loan") {
                    TextField("Balance", text: $loanBalance)
                        .keyboardType(.decimalPad)
                    TextField("Monthly payment", text: $loanMonthlyPayment)
                        .keyboardType(.decimalPad)
                    TextField("APR", text: $loanAPR)
                        .keyboardType(.decimalPad)
                }

                Section("Credit Card") {
                    TextField("Balance", text: $creditCardBalance)
                        .keyboardType(.decimalPad)
                    TextField("Limit", text: $creditCardLimit)
                        .keyboardType(.decimalPad)
                    TextField("Minimum payment", text: $creditCardMinimumPayment)
                        .keyboardType(.decimalPad)
                    TextField("APR", text: $creditCardAPR)
                        .keyboardType(.decimalPad)
                }
            }
            .scrollContentBackground(.hidden)
            .background(StarkTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Debt Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        store.update(
                            loanBalance: Self.double(from: loanBalance),
                            loanMonthlyPayment: Self.double(from: loanMonthlyPayment),
                            loanAPR: Self.double(from: loanAPR),
                            creditCardBalance: Self.double(from: creditCardBalance),
                            creditCardLimit: Self.double(from: creditCardLimit),
                            creditCardMinimumPayment: Self.double(from: creditCardMinimumPayment),
                            creditCardAPR: Self.double(from: creditCardAPR)
                        )
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(StarkTheme.arcBlue)
        .preferredColorScheme(.dark)
    }

    private static func string(for value: Double) -> String {
        value == 0 ? "" : String(format: "%.2f", value)
    }

    private static func double(from string: String) -> Double {
        Double(string.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }
}

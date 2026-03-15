import Foundation
import SwiftUI
import Combine

final class DebtStore: ObservableObject {
    @AppStorage("loanBalance") var loanBalance: Double = 0 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("loanMonthlyPayment") var loanMonthlyPayment: Double = 0 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("loanAPR") var loanAPR: Double = 0 {
        willSet { objectWillChange.send() }
    }

    @AppStorage("creditCardBalance") var creditCardBalance: Double = 0 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("creditCardLimit") var creditCardLimit: Double = 0 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("creditCardMinimumPayment") var creditCardMinimumPayment: Double = 0 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("creditCardAPR") var creditCardAPR: Double = 0 {
        willSet { objectWillChange.send() }
    }

    var totalDebt: Double {
        loanBalance + creditCardBalance
    }

    var totalMonthlyPayments: Double {
        loanMonthlyPayment + creditCardMinimumPayment
    }

    var weightedAPR: Double {
        let total = totalDebt
        guard total > 0 else { return 0 }

        let weightedLoan = loanBalance * loanAPR
        let weightedCard = creditCardBalance * creditCardAPR
        return (weightedLoan + weightedCard) / total
    }

    var creditUtilization: Double {
        guard creditCardLimit > 0 else { return 0 }
        return min(max(creditCardBalance / creditCardLimit, 0), 1)
    }

    var loanMonthsLeft: Int? {
        payoffMonths(balance: loanBalance, monthlyPayment: loanMonthlyPayment)
    }

    var creditCardMonthsLeft: Int? {
        payoffMonths(balance: creditCardBalance, monthlyPayment: creditCardMinimumPayment)
    }

    var overallDebtTimelineMonths: Int? {
        let values = [loanMonthsLeft, creditCardMonthsLeft].compactMap { $0 }
        return values.max()
    }

    func update(
        loanBalance: Double,
        loanMonthlyPayment: Double,
        loanAPR: Double,
        creditCardBalance: Double,
        creditCardLimit: Double,
        creditCardMinimumPayment: Double,
        creditCardAPR: Double
    ) {
        self.loanBalance = loanBalance
        self.loanMonthlyPayment = loanMonthlyPayment
        self.loanAPR = loanAPR
        self.creditCardBalance = creditCardBalance
        self.creditCardLimit = creditCardLimit
        self.creditCardMinimumPayment = creditCardMinimumPayment
        self.creditCardAPR = creditCardAPR
    }

    private func payoffMonths(balance: Double, monthlyPayment: Double) -> Int? {
        guard balance > 0, monthlyPayment > 0 else { return nil }
        return Int(ceil(balance / monthlyPayment))
    }
}

import Foundation
import SwiftUI
import Combine

final class ProteinStore: ObservableObject {
    @Published var currentProtein: Double = 0 {
        didSet {
            currentProteinStorage = currentProtein
        }
    }

    @AppStorage("dailyProtein") private var currentProteinStorage: Double = 0
    @AppStorage("dailyProteinLastUpdated") private var lastUpdated: String = ""
    @AppStorage("dailyProteinHistoryData") private var historyData: String = ""

    private var proteinHistory: [String: Double] = [:]

    init() {
        loadHistory()
        syncForToday()
    }

    func addProtein(_ amount: Double) {
        guard amount > 0 else { return }
        syncForToday()
        currentProtein += amount
        saveCurrentDayToHistory()
    }

    func subtractProtein(_ amount: Double) {
        guard amount > 0 else { return }
        syncForToday()
        currentProtein = max(0, currentProtein - amount)
        saveCurrentDayToHistory()
    }

    func protein(on date: Date) -> Double {
        proteinHistory[dateKey(for: date)] ?? 0
    }

    func syncForToday() {
        let todayKey = dateKey(for: Date())

        if !lastUpdated.isEmpty, lastUpdated != todayKey {
            proteinHistory[lastUpdated] = currentProteinStorage
            persistHistory()
            currentProteinStorage = 0
        }

        if lastUpdated != todayKey {
            lastUpdated = todayKey
        }

        currentProtein = currentProteinStorage
        saveCurrentDayToHistory()
    }

    private func saveCurrentDayToHistory() {
        proteinHistory[dateKey(for: Date())] = currentProtein
        persistHistory()
    }

    private func loadHistory() {
        let trimmedHistory = historyData.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHistory.isEmpty, let data = trimmedHistory.data(using: .utf8) else {
            proteinHistory = [:]
            return
        }

        do {
            proteinHistory = try JSONDecoder().decode([String: Double].self, from: data)
        } catch {
            proteinHistory = [:]
            historyData = ""
            print("Failed to load protein history. Resetting invalid stored data: \(error)")
        }
    }

    private func persistHistory() {
        do {
            let data = try JSONEncoder().encode(proteinHistory)
            historyData = String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Failed to save protein history: \(error)")
        }
    }

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

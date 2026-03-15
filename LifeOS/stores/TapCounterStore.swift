//
//  TapCounterStore.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//


import Foundation
import Combine

final class TapCounterStore: ObservableObject {
    @Published var tapCount: Int {
        didSet {
            UserDefaults.standard.set(tapCount, forKey: "tapCount")
        }
    }

    init() {
        self.tapCount = UserDefaults.standard.integer(forKey: "tapCount")
    }

    func increment() {
        tapCount += 1
    }

    func reset() {
        tapCount = 0
    }
}

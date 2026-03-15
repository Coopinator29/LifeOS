//
//  GymModels.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//

import Foundation

struct WorkoutSet: Identifiable, Codable, Hashable {
    let id: UUID
    var reps: String
    var weight: String

    init(
        id: UUID = UUID(),
        reps: String,
        weight: String
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
    }
}

struct CompletedWorkout: Identifiable, Codable, Hashable {
    let id: UUID
    var exerciseName: String
    var setEntries: [WorkoutSet]
    let loggedAt: Date

    init(
        id: UUID = UUID(),
        exerciseName: String,
        setEntries: [WorkoutSet],
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.setEntries = setEntries
        self.loggedAt = loggedAt
    }

    var setsCount: Int {
        setEntries.count
    }

    var totalVolume: Double {
        setEntries.reduce(0) { partialResult, setEntry in
            let reps = Double(setEntry.reps) ?? 0
            let weight = Double(setEntry.weight) ?? 0
            return partialResult + (reps * weight)
        }
    }

    var totalReps: Int {
        setEntries.reduce(0) { partialResult, setEntry in
            partialResult + (Int(setEntry.reps) ?? 0)
        }
    }

    var heaviestWeight: Double {
        setEntries.reduce(0) { partialResult, setEntry in
            max(partialResult, Double(setEntry.weight) ?? 0)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case exerciseName
        case setEntries
        case loggedAt
        case reps
        case weight
        case sets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        exerciseName = try container.decode(String.self, forKey: .exerciseName)
        loggedAt = try container.decode(Date.self, forKey: .loggedAt)

        if let setEntries = try container.decodeIfPresent([WorkoutSet].self, forKey: .setEntries) {
            self.setEntries = setEntries
        } else {
            let reps = try container.decodeIfPresent(String.self, forKey: .reps) ?? ""
            let weight = try container.decodeIfPresent(String.self, forKey: .weight) ?? ""
            let setsString = try container.decodeIfPresent(String.self, forKey: .sets) ?? ""
            let fallbackCount = max(Int(setsString) ?? 1, 1)
            self.setEntries = (0..<fallbackCount).map { _ in
                WorkoutSet(reps: reps, weight: weight)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(exerciseName, forKey: .exerciseName)
        try container.encode(setEntries, forKey: .setEntries)
        try container.encode(loggedAt, forKey: .loggedAt)
    }
}

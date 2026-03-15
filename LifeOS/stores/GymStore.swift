//
//  GymStore.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//


import Foundation
import SwiftUI
import Combine

final class GymStore: ObservableObject {
    @Published var completedWorkouts: [CompletedWorkout] = [] {
        didSet { save() }
    }

    @AppStorage("completedWorkoutsData") private var completedWorkoutsData: String = ""

    let availableExercises: [String] = [
        "Leg press",
        "Chest press flat",
        "Incline dumbbell press",
        "Seated row",
        "Lat pulldown",
        "Lateral raises",
        "Leg curl",
        "Leg extension",
        "Shoulder press",
        "Bicep curls",
        "Tricep push down",
        "Romanian deadlifts",
        "Face pulls",
        "Incline walk"
    ]

    init() {
        load()
    }

    private let calendar = Calendar.current

    var todayWorkouts: [CompletedWorkout] {
        workouts(on: Date())
    }

    func workouts(on date: Date) -> [CompletedWorkout] {
        completedWorkouts.filter { workout in
            calendar.isDate(workout.loggedAt, inSameDayAs: date)
        }
    }

    func hasWorkout(on date: Date) -> Bool {
        completedWorkouts.contains { workout in
            calendar.isDate(workout.loggedAt, inSameDayAs: date)
        }
    }

    func addWorkout(exerciseName: String, setEntries: [WorkoutSet]) {
        let workout = CompletedWorkout(
            exerciseName: exerciseName,
            setEntries: setEntries
        )
        completedWorkouts.insert(workout, at: 0)
    }

    func updateWorkout(_ workout: CompletedWorkout, setEntries: [WorkoutSet]) {
        guard let index = completedWorkouts.firstIndex(where: { $0.id == workout.id }) else { return }
        completedWorkouts[index].setEntries = setEntries
    }

    func removeWorkout(_ workout: CompletedWorkout) {
        completedWorkouts.removeAll { $0.id == workout.id }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(completedWorkouts)
            completedWorkoutsData = String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Failed to save workouts: \(error)")
        }
    }

    private func load() {
        guard let data = completedWorkoutsData.data(using: .utf8) else { return }

        do {
            completedWorkouts = try JSONDecoder().decode([CompletedWorkout].self, from: data)
        } catch {
            print("Failed to load workouts: \(error)")
        }
    }
}

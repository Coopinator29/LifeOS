//
//  WorkoutRow.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//


import SwiftUI

struct WorkoutRow: View {
    let workout: CompletedWorkout
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.exerciseName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                HStack(spacing: 10) {
                    statPill(title: "Sets", value: "\(workout.setsCount)")
                    statPill(title: "Reps", value: "\(workout.totalReps)")
                    statPill(title: "Top KG", value: formattedNumber(workout.heaviestWeight))
                }

                Text("Tap to view set breakdown")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(StarkTheme.warning)
                    .frame(width: 36, height: 36)
                    .background(StarkTheme.ember.opacity(0.14))
                    .clipShape(Circle())
            }
        }
        .padding(14)
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: StarkTheme.arcBlue.opacity(0.08), radius: 10, y: 6)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: onTap)
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.82))
                .tracking(1.2)

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 9)
        .background(StarkTheme.arcBlue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }

        return String(format: "%.1f", value)
    }
}

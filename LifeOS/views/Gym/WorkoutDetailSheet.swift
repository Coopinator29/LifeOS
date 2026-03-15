import SwiftUI

struct WorkoutDetailSheet: View {
    let workout: CompletedWorkout
    let onEdit: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    summaryCard

                    VStack(spacing: 12) {
                        ForEach(Array(workout.setEntries.enumerated()), id: \.element.id) { index, setEntry in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(width: 38, height: 38)
                                    .background(StarkTheme.arcBlue.opacity(0.16))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Set \(index + 1)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)

                                    Text("\(setEntry.reps) reps at \(setEntry.weight) kg")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.72))
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(cardBackground)
                            .overlay(cardBorder)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(backgroundGradient)
            .navigationTitle(workout.exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Edit") {
                        dismiss()
                        onEdit()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WORKOUT BREAKDOWN")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.86))

            Text(workout.exerciseName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                summaryPill(title: "Sets", value: "\(workout.setsCount)")
                summaryPill(title: "Volume", value: formattedNumber(workout.totalVolume))
                summaryPill(title: "Top KG", value: formattedNumber(workout.heaviestWeight))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(1.2)
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.82))

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(StarkTheme.arcBlue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }

        return String(format: "%.1f", value)
    }

    private var backgroundGradient: some View {
        StarkTheme.backgroundGradient.ignoresSafeArea()
    }

    private var cardBackground: some View {
        StarkTheme.cardGradient
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
    }
}

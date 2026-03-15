import SwiftUI

private struct EditableWorkoutSet: Identifiable {
    let id: UUID
    var reps: String
    var weight: String

    init(
        id: UUID = UUID(),
        reps: String = "",
        weight: String = ""
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
    }
}

private struct ExerciseInsight {
    let summary: String
    let muscles: String
}

struct AddWorkoutSheet: View {
    let exerciseName: String
    let title: String
    let saveButtonTitle: String
    let initialSetEntries: [WorkoutSet]
    let onSave: (_ setEntries: [WorkoutSet]) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var editableSets: [EditableWorkoutSet]

    init(
        exerciseName: String,
        title: String = "Add Workout",
        saveButtonTitle: String = "Save",
        initialSetEntries: [WorkoutSet] = [],
        onSave: @escaping (_ setEntries: [WorkoutSet]) -> Void
    ) {
        self.exerciseName = exerciseName
        self.title = title
        self.saveButtonTitle = saveButtonTitle
        self.initialSetEntries = initialSetEntries
        self.onSave = onSave

        let seededSets = initialSetEntries.isEmpty
            ? [EditableWorkoutSet()]
            : initialSetEntries.map { EditableWorkoutSet(id: $0.id, reps: $0.reps, weight: $0.weight) }
        _editableSets = State(initialValue: seededSets)
    }

    private var canSave: Bool {
        !editableSets.isEmpty && editableSets.allSatisfy { setEntry in
            !setEntry.reps.trimmingCharacters(in: .whitespaces).isEmpty &&
            !setEntry.weight.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var exerciseInsight: ExerciseInsight {
        switch exerciseName {
        case "Leg press":
            ExerciseInsight(summary: "Drive through a stable foot path to build heavy lower-body output.", muscles: "Targets quads, glutes, and adductors.")
        case "Chest press flat":
            ExerciseInsight(summary: "A flat pressing pattern for pushing strength with a balanced chest load.", muscles: "Targets chest, front delts, and triceps.")
        case "Incline dumbbell press":
            ExerciseInsight(summary: "Press on an incline to bias the upper chest with more shoulder stabilization.", muscles: "Targets upper chest, front delts, and triceps.")
        case "Seated row":
            ExerciseInsight(summary: "Pull to the torso with control to train back thickness and posture.", muscles: "Targets lats, mid-back, rear delts, and biceps.")
        case "Lat pulldown":
            ExerciseInsight(summary: "A vertical pull focused on strong elbow drive and shoulder depression.", muscles: "Targets lats, upper back, and biceps.")
        case "Lateral raises":
            ExerciseInsight(summary: "Controlled raises that widen the shoulder line without heavy pressing fatigue.", muscles: "Targets side delts with support from upper traps.")
        case "Leg curl":
            ExerciseInsight(summary: "A knee-flexion movement for direct hamstring work and posterior-chain balance.", muscles: "Targets hamstrings and calves lightly.")
        case "Leg extension":
            ExerciseInsight(summary: "An isolation movement for clean quad tension through the top range.", muscles: "Targets quads.")
        case "Shoulder press":
            ExerciseInsight(summary: "An overhead press for stacked upper-body strength and shoulder power.", muscles: "Targets delts, triceps, and upper chest.")
        case "Bicep curls":
            ExerciseInsight(summary: "A direct arm movement for elbow flexion strength and biceps size.", muscles: "Targets biceps, brachialis, and forearms.")
        case "Tricep push down":
            ExerciseInsight(summary: "A cable press-down that lets you load triceps with stable form.", muscles: "Targets triceps.")
        case "Romanian deadlifts":
            ExerciseInsight(summary: "A hip-hinge pattern that loads the posterior chain with lengthened tension.", muscles: "Targets hamstrings, glutes, lower back, and grip.")
        case "Face pulls":
            ExerciseInsight(summary: "A high pull for shoulder health, scapular control, and rear-delt work.", muscles: "Targets rear delts, upper back, and rotator cuff support.")
        case "Incline walk":
            ExerciseInsight(summary: "Low-impact incline cardio for steady conditioning and leg endurance.", muscles: "Targets calves, glutes, hamstrings, and cardiovascular endurance.")
        default:
            ExerciseInsight(summary: "Log each set with its own reps and weight so the workout stays precise.", muscles: "Targets the muscle groups trained by this exercise.")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    exerciseCard

                    VStack(spacing: 12) {
                        ForEach(Array(editableSets.enumerated()), id: \.element.id) { index, setEntry in
                            setCard(index: index, setEntry: setEntry)
                        }
                    }

                    Button {
                        editableSets.append(EditableWorkoutSet())
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus")
                            Text("Add Set")
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(StarkTheme.controlGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(StarkTheme.arcBlue.opacity(0.26), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(backgroundGradient)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(saveButtonTitle) {
                        onSave(editableSets.map { WorkoutSet(id: $0.id, reps: $0.reps, weight: $0.weight) })
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(StarkTheme.arcBlue)
        .preferredColorScheme(.dark)
    }

    private var exerciseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXERCISE")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.86))

            Text(exerciseName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(exerciseInsight.summary)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            Text(exerciseInsight.muscles)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(StarkTheme.steel.opacity(0.95))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func setCard(index: Int, setEntry: EditableWorkoutSet) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("Set \(index + 1)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                if editableSets.count > 1 {
                    Button(role: .destructive) {
                        editableSets.removeAll { $0.id == setEntry.id }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(StarkTheme.warning)
                    }
                }
            }

            HStack(spacing: 12) {
                workoutInput(
                    title: "REPS",
                    placeholder: "10",
                    text: binding(for: setEntry.id, keyPath: \.reps),
                    keyboardType: .numberPad
                )

                workoutInput(
                    title: "WEIGHT",
                    placeholder: "60",
                    text: binding(for: setEntry.id, keyPath: \.weight),
                    keyboardType: .decimalPad
                )
            }
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func workoutInput(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.82))

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(StarkTheme.cardGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(StarkTheme.steel.opacity(0.22), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func binding(
        for id: UUID,
        keyPath: WritableKeyPath<EditableWorkoutSet, String>
    ) -> Binding<String> {
        Binding(
            get: {
                editableSets.first(where: { $0.id == id })?[keyPath: keyPath] ?? ""
            },
            set: { newValue in
                guard let index = editableSets.firstIndex(where: { $0.id == id }) else { return }
                editableSets[index][keyPath: keyPath] = newValue
            }
        )
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

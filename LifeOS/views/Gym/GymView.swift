import SwiftUI
import Combine

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

struct GymView: View {
    @ObservedObject var store: GymStore

    @State private var showingExercisePicker = false
    @State private var selectedExercise: IdentifiableString?
    @State private var selectedWorkout: CompletedWorkout?
    @State private var editingWorkout: CompletedWorkout?

    private var todayWorkouts: [CompletedWorkout] {
        store.todayWorkouts
    }

    private var totalLoggedKG: Double {
        todayWorkouts.reduce(0) { partialResult, workout in
            partialResult + workout.totalVolume
        }
    }

    var body: some View {
        ZStack {
            StarkTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer(minLength: 12)

                headerCard

                if todayWorkouts.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(todayWorkouts) { workout in
                                WorkoutRow(
                                    workout: workout,
                                    onTap: {
                                        selectedWorkout = workout
                                    },
                                    onDelete: {
                                        withAnimation(.spring()) {
                                            store.removeWorkout(workout)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .padding(.bottom, 4)
                    }
                }

                Spacer(minLength: 2)

                Button {
                    showingExercisePicker = true
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))

                        Text("Add Workout")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(StarkTheme.controlGradient)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(StarkTheme.arcBlue.opacity(0.28), lineWidth: 1)
                    )
                    .shadow(color: StarkTheme.arcBlue.opacity(0.16), radius: 12, y: 6)
                }
                .padding(.horizontal, 1)
            }
            .padding(.horizontal)
            .padding(.bottom, BottomNavigationDock.reservedBottomInset/1.3)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheet(
                exercises: store.availableExercises,
                onSelect: { exercise in
                    selectedExercise = IdentifiableString(value: exercise)
                    showingExercisePicker = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedExercise) { exercise in
            AddWorkoutSheet(
                exerciseName: exercise.value,
                title: "Add Workout",
                saveButtonTitle: "Save",
                onSave: { setEntries in
                    store.addWorkout(
                        exerciseName: exercise.value,
                        setEntries: setEntries
                    )
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingWorkout) { workout in
            AddWorkoutSheet(
                exerciseName: workout.exerciseName,
                title: "Edit Workout",
                saveButtonTitle: "Update",
                initialSetEntries: workout.setEntries,
                onSave: { setEntries in
                    store.updateWorkout(workout, setEntries: setEntries)
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedWorkout) { workout in
            WorkoutDetailSheet(
                workout: workout,
                onEdit: {
                    selectedWorkout = nil
                    DispatchQueue.main.async {
                        editingWorkout = workout
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var headerCard: some View {
        PageHeaderCard(
            sectionLabel: "WORKOUT LOG",
            title: "Gym Core",
            subtitle: "\(formattedKG(totalLoggedKG)) kg logged today"
        ) {
            GymReactorRing(
                totalKG: totalLoggedKG,
                goalKG: 10000,
                size: 104
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "dumbbell.fill")
                .font(.system(size: 42))
                .foregroundStyle(StarkTheme.arcBlue.opacity(0.92))

            Text("No workouts logged today")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Tap Add Workout below to log today’s session. Past days stay available in the calendar.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(StarkTheme.steel.opacity(0.88))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                Text("Swipe left for calendar history")
            }
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(StarkTheme.steel.opacity(0.82))
            .padding(.top, 6)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formattedKG(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

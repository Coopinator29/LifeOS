//
//  ExercisePickerSheet.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//


import SwiftUI

struct ExercisePickerSheet: View {
    let exercises: [String]
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filteredExercises: [String] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Which Workout?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Choose an exercise to start logging your sets.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(StarkTheme.steel.opacity(0.88))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 12)

                List(filteredExercises, id: \.self) { exercise in
                    Button {
                        onSelect(exercise)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(StarkTheme.arcBlue)

                            Text(exercise)
                                .foregroundStyle(.white)

                            Spacer()
                        }
                    }
                    .listRowBackground(StarkTheme.obsidian.opacity(0.92))
                }
            }
            .navigationTitle("Choose Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .scrollContentBackground(.hidden)
            .background(StarkTheme.backgroundGradient.ignoresSafeArea())
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(StarkTheme.arcBlue)
        .preferredColorScheme(.dark)
    }
}

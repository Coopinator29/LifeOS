import SwiftUI

struct ProteinView: View {
    @ObservedObject var store: ProteinStore

    @State private var proteinInput: String = ""
    @State private var pendingAction: ProteinAction? = nil

    @FocusState private var inputFocused: Bool

    enum ProteinAction {
        case add
        case subtract
    }

    var body: some View {
        VStack(spacing: 16) {
            Divider()
                .overlay(StarkTheme.steel.opacity(0.28))

            VStack(spacing: 10) {
                Text("Protein")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(formattedProtein(store.currentProtein))g")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("today")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(StarkTheme.arcBlue.opacity(0.82))

                if pendingAction != nil {
                    VStack(spacing: 10) {
                        TextField(
                            pendingAction == .add ? "Add grams" : "Subtract grams",
                            text: $proteinInput
                        )
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($inputFocused)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(StarkTheme.cardGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(StarkTheme.arcBlue.opacity(0.28), lineWidth: 1)
                        )
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button("Cancel") {
                                    cancelInput()
                                }

                                Spacer()

                                Button("Done") {
                                    applyProteinChange()
                                }
                            }
                        }

                        Text(pendingAction == .add ? "Enter grams to add" : "Enter grams to subtract")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(StarkTheme.steel.opacity(0.9))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                HStack(spacing: 16) {
                    Button {
                        startInput(.subtract)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(StarkTheme.warning)
                    }

                    Button {
                        startInput(.add)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(StarkTheme.arcBlue)
                    }
                }
            }
        }
        .padding()
        .background(StarkTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(StarkTheme.steel.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: StarkTheme.arcBlue.opacity(0.12), radius: 14, y: 8)
        .onAppear {
            store.syncForToday()
        }
    }

    private func startInput(_ action: ProteinAction) {
        store.syncForToday()
        pendingAction = action
        proteinInput = ""
        inputFocused = true
    }

    private func cancelInput() {
        proteinInput = ""
        pendingAction = nil
        inputFocused = false
    }

    private func applyProteinChange() {
        guard let action = pendingAction,
              let amount = Double(proteinInput),
              amount > 0 else {
            return
        }

        switch action {
        case .add:
            store.addProtein(amount)
        case .subtract:
            store.subtractProtein(amount)
        }

        proteinInput = ""
        pendingAction = nil
        inputFocused = false
    }

    private func formattedProtein(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

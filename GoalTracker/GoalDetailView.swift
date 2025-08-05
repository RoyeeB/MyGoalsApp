import SwiftUI

struct GoalDetailView: View {
    let goal: Goal
    @ObservedObject var goalsVM: GoalsViewModel

    @State private var localAmount: Int = 0
    @State private var isEditing = false
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newCurrent = ""
    @State private var newTarget = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isEditing {
                    goalField(icon: "textformat", title: "Goal Title", text: $newTitle)
                    goalField(icon: "doc.text", title: "Description", text: $newDescription)

                    if goal.isQuantitative {
                        goalField(icon: "target", title: "Target Amount", text: $newTarget)
                        goalField(icon: "chart.bar.fill", title: "Current Progress", text: $newCurrent)
                    }

                    HStack(spacing: 16) {
                        cancelButton
                        saveButton
                    }
                } else {
                    VStack(spacing: 12) {
                        Text(goal.title)
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(goal.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if goal.isQuantitative,
                           let target = goal.targetAmount,
                           let current = goal.currentAmount {
                            VStack(spacing: 8) {
                                ProgressView(value: Double(current), total: Double(target))
                                    .accentColor(goal.isCompleted ? .green : .blue)
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)

                                Text("Progress: \(current) / \(target)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)

                    Button(action: startEditing) {
                        Label("Edit Goal", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .onAppear {
            localAmount = goal.currentAmount ?? 0
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func goalField(icon: String, title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField("Enter \(title.lowercased())", text: text)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
    }

    private var cancelButton: some View {
        Button(action: { isEditing = false }) {
            Label("Cancel", systemImage: "xmark.circle.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .foregroundColor(.black)
                .cornerRadius(10)
        }
    }

    private var saveButton: some View {
        Button(action: saveChanges) {
            Label("Save", systemImage: "checkmark.circle.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    private func startEditing() {
        newTitle = goal.title
        newDescription = goal.description
        newCurrent = "\(goal.currentAmount ?? 0)"
        newTarget = "\(goal.targetAmount ?? 0)"
        isEditing = true
    }

    private func saveChanges() {
        guard let targetInt = Int(newTarget),
              let currentInt = Int(newCurrent) else { return }

        goalsVM.updateFullGoal(
            goal: goal,
            newTitle: newTitle,
            newDescription: newDescription,
            newTarget: targetInt,
            newCurrent: currentInt
        )

        localAmount = min(currentInt, targetInt)
        isEditing = false
    }
}

import SwiftUI

struct AddGoalView: View {
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var goalsVM: GoalsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var isQuantitative = false
    @State private var targetAmount = ""

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create New Goal")
                        .font(.largeTitle.bold())
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Goal Title")
                            .font(.headline)
                        TextField("Enter title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Description")
                            .font(.headline)
                        TextField("Enter description", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Due Date")
                            .font(.headline)
                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    Toggle(isOn: $isQuantitative.animation()) {
                        Text("Quantitative Goal")
                            .font(.headline)
                    }

                    if isQuantitative {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Target Amount")
                                .font(.headline)
                            TextField("e.g. 5", text: $targetAmount)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    HStack(spacing: 20) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                        }

                        Button(action: addGoal) {
                            Text("Add Goal")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(title.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                        }
                        .disabled(title.isEmpty)
                    }
                    .padding(.top)

                    Spacer()
                }
                .padding()
            }
        }
    }

    private func addGoal() {
        guard let userId = authVM.user?.id else { return }

        let goal = Goal(
            title: title,
            description: description,
            isCompleted: false,
            isQuantitative: isQuantitative,
            targetAmount: isQuantitative ? Int(targetAmount) ?? 0 : nil,
            currentAmount: isQuantitative ? 0 : nil,
            dueDate: dueDate,
            userId: userId
        )

        goalsVM.addGoal(goal)
        dismiss()
    }
}

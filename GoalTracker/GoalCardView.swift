import SwiftUI

struct GoalCardView: View {
    let goal: Goal
    @ObservedObject var goalsVM: GoalsViewModel

    @State private var animate = false
    @State private var animateCheckmark = false
    @State private var animatedProgress: Double = 0

    var isExpired: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return !goal.isCompleted && goal.dueDate < today
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(goal.title)
                        .font(.title3.bold())
                        .foregroundColor(goal.isCompleted ? .green : .primary)
                        .strikethrough(goal.isCompleted, color: .green)

                    Text("Due: \(goal.dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(isExpired ? .red : .secondary)
                        .strikethrough(goal.isCompleted, color: .green)
                }

                Spacer()

                Button(action: {
                    goalsVM.deleteGoal(goal: goal)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(.plain)

                Button {
                    goalsVM.toggleComplete(goal: goal)
                    withAnimation(.spring()) {
                        animateCheckmark.toggle()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animateCheckmark = false
                    }
                } label: {
                    Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(goal.isCompleted ? .green : .gray)
                        .font(.title2)
                        .scaleEffect(animateCheckmark ? 1.2 : 1)
                        .animation(.spring(), value: animateCheckmark)
                }
                .buttonStyle(.plain)
            }

            if goal.isQuantitative,
               let current = goal.currentAmount,
               let target = goal.targetAmount {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: animatedProgress, total: Double(target))
                        .accentColor(goal.isCompleted ? .green : .blue)
                        .animation(.easeInOut(duration: 0.3), value: animatedProgress)

                    HStack(spacing: 24) {
                        Button {
                            if current > 0 {
                                goalsVM.setAmount(goal: goal, amount: current - 1)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)

                        Text("\(current) / \(target)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button {
                            if current < target {
                                goalsVM.incrementAmount(goal: goal)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                }
            }

            NavigationLink(destination: GoalDetailView(goal: goal, goalsVM: goalsVM)) {
                HStack {
                    Spacer()
                    Label("More Details", systemImage: "chevron.right.circle")
                        .font(.footnote)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(goal.isCompleted ? Color.green.opacity(0.1) : Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isExpired ? Color.red.opacity(0.6) : Color.clear, lineWidth: animate ? 2 : 0)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .opacity(isExpired && animate ? 0.6 : 1)
        .onAppear {
            if let current = goal.currentAmount {
                animatedProgress = Double(current)
            }
            if isExpired {
                withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                    animate.toggle()
                }
            }
        }
        .onChange(of: goal.currentAmount) { newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = Double(newValue ?? 0)
            }
        }
    }
}

import Foundation
import FirebaseFirestore


class GoalsViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    private let db = Firestore.firestore()

    func fetchGoals(for userId: String) {
        db.collection("goals")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch goals: \(error.localizedDescription)")
                    return
                }

                self.goals = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Goal.self)
                } ?? []
                print("✅ Goals fetched: \(self.goals.count)")
            }
    }

  
    func addGoal(_ goal: Goal) {
        do {
            _ = try db.collection("goals").addDocument(from: goal)
            print("✅ Goal added successfully")
        } catch {
            print("❌ Failed to add goal: \(error.localizedDescription)")
        }
    }

    func deleteGoal(goal: Goal) {
        guard let id = goal.id else { return }
        db.collection("goals").document(id).delete { error in
            if let error = error {
                print("❌ Failed to delete goal: \(error.localizedDescription)")
            } else {
                print("🗑️ Goal deleted")
                DispatchQueue.main.async {
                    self.goals.removeAll { $0.id == id }
                }
            }
        }
    }

    func toggleComplete(goal: Goal) {
        guard let id = goal.id else { return }
        let newStatus = !goal.isCompleted

        db.collection("goals").document(id).updateData([
            "isCompleted": newStatus
        ]) { error in
            if let error = error {
                print("❌ Failed to toggle goal completion: \(error.localizedDescription)")
            } else {
                print(newStatus ? "✅ Goal marked as completed" : "🔁 Goal marked as incomplete")
            }
        }
    }

    func incrementAmount(goal: Goal) {
        guard let id = goal.id,
              let current = goal.currentAmount,
              let target = goal.targetAmount else { return }

        let newAmount = min(current + 1, target)

        db.collection("goals").document(id).updateData([
            "currentAmount": newAmount,
            "isCompleted": newAmount >= target
        ])
    }

    func setAmount(goal: Goal, amount: Int) {
        guard let id = goal.id,
              let target = goal.targetAmount else { return }

        let newAmount = max(0, min(amount, target))

        db.collection("goals").document(id).updateData([
            "currentAmount": newAmount,
            "isCompleted": newAmount >= target
        ])
    }


    func updateGoalTitleAndDescription(goal: Goal, newTitle: String, newDescription: String) {
        guard let id = goal.id else { return }

        db.collection("goals").document(id).updateData([
            "title": newTitle,
            "description": newDescription
        ])
    }

    func updateFullGoal(goal: Goal,
                        newTitle: String,
                        newDescription: String,
                        newTarget: Int,
                        newCurrent: Int) {
        guard let id = goal.id else { return }

        let finalCurrent = min(newCurrent, newTarget)

        db.collection("goals").document(id).updateData([
            "title": newTitle,
            "description": newDescription,
            "targetAmount": newTarget,
            "currentAmount": finalCurrent,
            "isCompleted": finalCurrent >= newTarget
        ])
    }
}

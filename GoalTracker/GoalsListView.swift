import SwiftUI

enum GoalFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case inProgress = "In Progress"
    case completed = "Completed"
    case byDate = "By Date"

    var id: String { self.rawValue }
}

struct GoalsListView: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject var goalsVM = GoalsViewModel()
    @State private var showAddGoal = false
    @State private var selectedFilter: GoalFilter = .all

    var filteredGoals: [Goal] {
        switch selectedFilter {
        case .all:
            return goalsVM.goals
        case .completed:
            return goalsVM.goals.filter { $0.isCompleted }
        case .inProgress:
            return goalsVM.goals.filter { !$0.isCompleted }
        case .byDate:
            return goalsVM.goals.sorted { $0.dueDate < $1.dueDate }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    if let user = authVM.user {
                        VStack(spacing: 4) {
                            Text("Welcome, \(user.name) 👋")
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .padding(.top, 12)

                            Text("Let's achieve your goals today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 16)

                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(GoalFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        ScrollView(showsIndicators: false) {
                            if filteredGoals.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "target")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.blue.opacity(0.8))
                                        .padding(.top, 60)

                                    Text("No goals yet")
                                        .font(.title2.bold())

                                    Text("Try adding one to get started 💪")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .multilineTextAlignment(.center)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            } else {
                                LazyVStack(spacing: 14) {
                                    ForEach(filteredGoals) { goal in
                                        GoalCardView(goal: goal, goalsVM: goalsVM)
                                            .padding(.horizontal)
                                            .transition(.move(edge: .bottom).combined(with: .opacity))
                                    }
                                }
                                .padding(.bottom, 80)
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("My Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGray6), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .shadow(radius: 1)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { authVM.logout() }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView(authVM: authVM, goalsVM: goalsVM)
            }
            .onAppear {
                if let user = authVM.user {
                    goalsVM.fetchGoals(for: user.id)
                }
            }
        }
    }
}

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var isLoading = false
    private let db = Firestore.firestore()

    init() {
        checkIfLoggedIn()
    }

    func checkIfLoggedIn() {
        if let currentUser = Auth.auth().currentUser {
            fetchUser(uid: currentUser.uid)
        }
    }

    func register(name: String, email: String, password: String) {
        print("🔹 Starting registration with email: \(email)")
        isLoading = true
        
        // Step 1: Create user in Auth
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            
            if let error = error {
                print("❌ Error registering with Auth: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {
                print("❌ UID not received from Auth")
                return
            }
            
            print("✅ User created in Auth, UID: \(user.uid)")
            
            // Step 2: Save to Firestore
            let newUser = AppUser(id: user.uid, name: name, email: email)
            
            do {
                try self.db.collection("users").document(user.uid).setData(from: newUser) { error in
                    if let error = error {
                        print("❌ Error saving to Firestore: \(error.localizedDescription)")
                    } else {
                        print("✅ User saved to Firestore")
                        DispatchQueue.main.async {
                            self.user = newUser
                        }
                    }
                }
            } catch {
                print("❌ Firestore save error: \(error.localizedDescription)")
            }
        }
    }

    // Login
    func login(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                print("❌ Error signing in: \(error.localizedDescription)")
                return
            }
            guard let uid = result?.user.uid else { return }
            self.fetchUser(uid: uid)
        }
    }

    // Logout
    func logout() {
        try? Auth.auth().signOut()
        self.user = nil
    }

    // Fetch user from Firestore
    private func fetchUser(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let user = try? snapshot?.data(as: AppUser.self) {
                self.user = user
            }
        }
    }
}

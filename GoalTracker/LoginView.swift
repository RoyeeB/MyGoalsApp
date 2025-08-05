import SwiftUI

struct LoginView: View {
    @StateObject var authVM = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        Group {
            if let user = authVM.user {
                GoalsListView(authVM: authVM)
            } else {
                NavigationView {
                    VStack(spacing: 24) {
                        
                        Image("Image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.top, 40)
                        
                        VStack(spacing: 6) {
                            Text("Welcome to")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("GoalTracker")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Set goals. Stay motivated. Succeed.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        VStack(spacing: 16) {
                            TextField("Email", text: $email)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)

                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)

                            if authVM.isLoading {
                                ProgressView()
                            }

                            Button(action: {
                                authVM.login(email: email, password: password)
                            }) {
                                Text("Login")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .font(.headline)
                            }
                        }

                        Button(action: {
                            showRegister = true
                        }) {
                            Text("Don't have an account? Register")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .padding(.top, 8)

                        Spacer()
                    }
                    .padding()
                    .background(
                        NavigationLink(destination: RegisterView(authVM: authVM),
                                       isActive: $showRegister) { EmptyView() }
                    )
                }
            }
        }
    }
}

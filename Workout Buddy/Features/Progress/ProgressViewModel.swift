import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

// MARK: - AuthViewModel
// Manages Google Sign In / Firebase authentication state.
// NOTE: Add GoogleSignIn-iOS SPM package, then import GoogleSignIn and uncomment the Google sign-in method.

@MainActor
@Observable
final class AuthViewModel {

    var state: AuthState = .loading
    var error: String?

    nonisolated(unsafe) private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    // MARK: - Auth State

    private func listenToAuthState() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                if let user {
                    self.state = .authenticated(uid: user.uid)
                } else {
                    self.state = .unauthenticated
                }
            }
        }
    }

    // MARK: - Sign In with Google
    // Requires GoogleSignIn-iOS SPM package from https://github.com/google/GoogleSignIn-iOS
    // After adding the package, uncomment the code below.

    func signInWithGoogle() async {
        guard let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController
        else { return }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            guard let idToken = result.user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            try await Auth.auth().signIn(with: credential)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Helpers

    var currentUID: String? { state.uid }

    func userPath(_ collection: String) -> String {
        guard let uid = currentUID else { return "users/unknown/\(collection)" }
        return "users/\(uid)/\(collection)"
    }

    func userDoc(_ collection: String, _ doc: String) -> String {
        "\(userPath(collection))/\(doc)"
    }

    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}

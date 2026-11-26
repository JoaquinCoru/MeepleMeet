import Foundation
import Mastery26
import Observation

enum AuthState {
    case notChecked
    case checkingSession
    case restoreError(String)
    case authenticated(AuthenticatedUser)
    case notAuthenticated
}

@Observable @MainActor
final class AuthVM {
    private(set) var state: AuthState
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(state: AuthState = .notChecked) {
        self.state = state
    }

    func restoreSession() async {
        switch state {
        case .notChecked, .restoreError(_):
            state = .checkingSession
        case .checkingSession, .authenticated, .notAuthenticated:
            return
        }

        do {
            if let user = try await Repository().validateJWT() {
                state = .authenticated(user)
            } else {
                state = .notAuthenticated
            }
        } catch NetworkError.status(401) {
            await Repository().clearAuthToken()
            state = .notAuthenticated
        } catch {
            state = .restoreError("No se ha podido comprobar tu sesión. Comprueba tu conexión e inténtalo de nuevo.")
        }
    }

    func login(email: String, password: String) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await Repository().login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password
            )
            state = .authenticated(response.user)
        } catch {
            errorMessage = "No se pudo iniciar sesión. Comprueba tus datos e inténtalo de nuevo."
        }
    }

    func register(name: String, email: String, password: String) async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        defer { isLoading = false }

        do {
            try await Repository().register(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password
            )
            return true
        } catch {
            return false
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

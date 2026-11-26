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
    private let installationMarkerKey = "hasCompletedInitialInstallation"

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

        // Keychain items may survive an app uninstall. UserDefaults is removed
        // with the app, so a missing marker identifies a fresh installation.
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: installationMarkerKey) {
            var security = Security()
            await security.clearAuthToken()
            defaults.set(true, forKey: installationMarkerKey)
        }

        let repository = Repository()
        guard let jwt = await repository.jwt else {
            state = .notAuthenticated
            return
        }

        var security = Security()
        do {
            let user = try await security.getUser(jwt: jwt)
            state = .authenticated(user)
        } catch NetworkError.status(401) {
            await security.clearAuthToken()
            state = .notAuthenticated
        } catch {
            state = .restoreError("No se ha podido comprobar tu sesión. Comprueba tu conexión e inténtalo de nuevo.")
        }
    }

    func invalidateSession() async {
        var security = Security()
        await security.clearAuthToken()
        state = .notAuthenticated
    }

    func login(email: String, password: String) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var security = Security()
        do {
            let response = try await security.login(
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
            try await Security().register(
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

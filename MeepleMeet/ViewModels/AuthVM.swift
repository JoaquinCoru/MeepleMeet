import Foundation
import Observation

@Observable @MainActor
final class AuthVM {
    private(set) var user: AuthenticatedUser?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var isAuthenticated: Bool { user != nil }

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
            user = response.user
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

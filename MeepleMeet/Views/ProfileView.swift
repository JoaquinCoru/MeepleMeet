import SwiftUI

struct ProfileView: View {
    @Environment(AuthVM.self) private var authViewModel

    var body: some View {
        Group {
            switch authViewModel.state {
            case .notChecked, .checkingSession:
                SessionRestoreView()
            case .restoreError(let errorMessage):
                SessionRestoreView(errorMessage: errorMessage) {
                    Task { await authViewModel.restoreSession() }
                }
            case .authenticated(let user):
                loggedInProfile(user: user)
            case .notAuthenticated:
                LoginView()
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loggedInProfile(user: AuthenticatedUser) -> some View {
        ContentUnavailableView("¡Hola, \(user.name)!", systemImage: "person.crop.circle", description: Text(user.email))
    }
}

#Preview("Sin sesión") {
    NavigationStack {
        ProfileView()
            .environment(AuthVM(state: .notAuthenticated))
    }
}


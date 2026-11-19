import SwiftUI

struct ProfileView: View {
    @Environment(AuthVM.self) private var authViewModel

    var body: some View {
        Group {
            if let user = authViewModel.user {
                loggedInProfile(user: user)
            } else {
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
    }
}


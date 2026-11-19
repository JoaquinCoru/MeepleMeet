import SwiftUI

enum ProfileAuthenticationState {
    case loggedOut
    case loggedIn
}

struct ProfileView: View {
    @State private var authenticationState: ProfileAuthenticationState

    init(initialState: ProfileAuthenticationState = .loggedOut) {
        _authenticationState = State(initialValue: initialState)
    }

    var body: some View {
        Group {
            switch authenticationState {
            case .loggedOut:
                LoginView()
            case .loggedIn:
                loggedInProfilePlaceholder
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var loggedInProfilePlaceholder: some View {
        ContentUnavailableView(
            "Tu perfil",
            systemImage: "person.crop.circle",
            description: Text("Aquí aparecerá tu perfil cuando iniciemos sesión.")
        )
    }
}

#Preview("Sin sesión") {
    NavigationStack {
        ProfileView()
    }
}

#Preview("Con sesión") {
    NavigationStack {
        ProfileView(initialState: .loggedIn)
    }
}

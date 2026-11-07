import SwiftUI

struct RootTabView: View {
    @Environment(GamesVM.self) private var gamesViewModel
    @State private var selectedTab: AppTab = .inicio

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label(AppTab.inicio.title, systemImage: AppTab.inicio.symbol) }
            .tag(AppTab.inicio)

            GamesView {
                selectedTab = .quedadas
            }
            .environment(gamesViewModel)
            .tabItem { Label(AppTab.juegos.title, systemImage: AppTab.juegos.symbol) }
            .tag(AppTab.juegos)

            NavigationStack {
                MeetupsView()
            }
            .tabItem { Label(AppTab.quedadas.title, systemImage: AppTab.quedadas.symbol) }
            .tag(AppTab.quedadas)

            NavigationStack {
                GameLibraryView()
            }
            .tabItem { Label(AppTab.ludoteca.title, systemImage: AppTab.ludoteca.symbol) }
            .tag(AppTab.ludoteca)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label(AppTab.perfil.title, systemImage: AppTab.perfil.symbol) }
            .tag(AppTab.perfil)
        }
    }
}

#Preview(traits: .gamesSampleData) {
    RootTabView()
}

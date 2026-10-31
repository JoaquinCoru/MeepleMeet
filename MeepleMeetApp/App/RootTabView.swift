import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: AppTab = .inicio

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label(AppTab.inicio.title, systemImage: AppTab.inicio.symbol) }
            .tag(AppTab.inicio)

            NavigationStack {
                GamesView()
            }
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

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}

import SwiftUI

@main
struct MeepleMeet: App {
    @State private var gamesViewModel = GamesVM()
    @State private var libraryViewModel = LibraryVM()
    @State private var authViewModel = AuthVM()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(gamesViewModel)
                .environment(libraryViewModel)
                .environment(authViewModel)
        }
    }
}

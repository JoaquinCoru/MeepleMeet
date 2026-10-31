import SwiftUI

@main
struct MeepleMeet: App {
    @State private var gamesViewModel = GamesVM()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(gamesViewModel)
        }
    }
}

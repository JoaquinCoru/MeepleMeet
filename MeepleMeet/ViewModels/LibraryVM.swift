import Observation

@Observable @MainActor
final class LibraryVM {
    private(set) var libraryGames: [GameCatalogItem]

    init(libraryGames: [GameCatalogItem] = []) {
        self.libraryGames = libraryGames
    }

    func removeFromLibrary(_ game: GameCatalogItem) {
        libraryGames.removeAll { $0.id == game.id }
    }
}

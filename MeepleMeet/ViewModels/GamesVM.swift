import Observation

@Observable @MainActor
final class GamesVM {
    private(set) var games: [GameCatalogItem]

    init(games: [GameCatalogItem] = []) {
        self.games = games
    }
}

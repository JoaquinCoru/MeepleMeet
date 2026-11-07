import Observation

@Observable @MainActor
final class GamesVM {
    private(set) var games: [GameCatalogItem]
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var hasLoaded: Bool

    init(games: [GameCatalogItem] = []) {
        self.games = games
        hasLoaded = !games.isEmpty
    }

    func loadGames() async {
        guard !hasLoaded, !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            games = try await Repository().getGames()
            hasLoaded = true
        } catch {
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
    }
}

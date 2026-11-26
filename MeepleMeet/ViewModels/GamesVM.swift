import Observation

@Observable @MainActor
final class GamesVM {
    private(set) var state: DataState<[GameCatalogItem]>

    init(games: [GameCatalogItem]? = nil) {
        if let games {
            state = .loaded(games)
        } else {
            state = .idle
        }
    }

    func loadGames() async {
        switch state {
        case .idle, .failed(_):
            state = .loading
        case .loading, .loaded(_):
            return
        }

        do {
            state = .loaded(try await Repository().getGames())
        } catch {
            state = Task.isCancelled ? .idle : .failed(error.localizedDescription)
        }
    }
}

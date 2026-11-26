import Observation

@Observable @MainActor
final class LibraryVM {
    private(set) var state: DataState<[GameCatalogItem]>

    init(libraryGames: [GameCatalogItem]? = nil) {
        if let libraryGames {
            state = .loaded(libraryGames)
        } else {
            state = .idle
        }
    }

    func loadLibraryGames() async {
        switch state {
        case .idle, .failed(_):
            state = .loading
        case .loading, .loaded(_):
            return
        }

        do {
            state = .loaded(try await Repository().getCollection())
        } catch {
            state = Task.isCancelled ? .idle : .failed(error.localizedDescription)
        }
    }

    func removeFromLibrary(_ game: GameCatalogItem) {
        guard case .loaded(var games) = state else { return }
        games.removeAll { $0.id == game.id }
        state = .loaded(games)
    }
}

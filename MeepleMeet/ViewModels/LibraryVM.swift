import Observation

@Observable @MainActor
final class LibraryVM {
    private(set) var state: DataState<[GameCatalogItem]>
    private let repository: any LibraryRepository

    init(
        libraryGames: [GameCatalogItem]? = nil,
        repository: any LibraryRepository = Repository()
    ) {
        self.repository = repository
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
            state = .loaded(try await repository.getCollection())
        } catch {
            state = Task.isCancelled ? .idle : .failed(error.localizedDescription)
        }
    }

    func removeFromLibrary(_ game: GameCatalogItem) async throws {
        try await repository.removeFromCollection(gameID: game.id)
        guard case .loaded(var games) = state else { return }
        games.removeAll { $0.id == game.id }
        state = .loaded(games)
    }

    func addToLibrary(_ game: GameCatalogItem) async throws {
        try await repository.addToCollection(gameID: game.id)
        markAsInLibrary(game)
    }

    func markAsInLibrary(_ game: GameCatalogItem) {
        switch state {
        case .loaded(var games):
            guard !games.contains(where: { $0.id == game.id }) else { return }
            games.append(game)
            state = .loaded(games)
        case .failed(_):
            state = .idle
        case .idle, .loading:
            break
        }
    }
}

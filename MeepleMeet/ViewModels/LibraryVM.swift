import Foundation
import Mastery26
import Observation

enum LibraryOperation: Equatable {
    case add
    case remove
}

enum LibraryActionResult: Equatable {
    case confirmationRequested
    case succeeded
    case failed
    case sessionExpired
}

enum LibraryActionState: Equatable {
    case idle
    case adding(UUID)
    case confirmingRemoval(GameCatalogItem)
    case removing(UUID)
    case failed(gameID: UUID, operation: LibraryOperation, message: String)
}

enum LibraryButtonState: Equatable {
    case adding
    case removing
    case inLibrary
    case available

    var isEmphasized: Bool {
        switch self {
        case .adding, .removing, .inLibrary: return true
        case .available: return false
        }
    }
}

@Observable @MainActor
final class LibraryVM {
    private(set) var state: DataState<[GameCatalogItem]>
    private(set) var actionState: LibraryActionState = .idle
    private let repository: any LibraryRepository
    private var locallyAddedGameIDs: Set<UUID> = []

    var isConfirmingRemoval: Bool {
        get {
            if case .confirmingRemoval = actionState { return true }
            return false
        }
        set {
            if !newValue { cancelRemovalConfirmation() }
        }
    }

    var isShowingActionError: Bool {
        get {
            if case .failed = actionState { return true }
            return false
        }
        set {
            if !newValue { dismissActionError() }
        }
    }

    var pendingRemovalGame: GameCatalogItem? {
        guard case .confirmingRemoval(let game) = actionState else { return nil }
        return game
    }

    var actionErrorMessage: String? {
        guard case .failed(_, _, let message) = actionState else { return nil }
        return message
    }

    var canStartAction: Bool {
        if case .idle = actionState { return true }
        return false
    }

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
            locallyAddedGameIDs.removeAll()
        } catch {
            state = Task.isCancelled ? .idle : .failed(error.localizedDescription)
        }
    }

    func isInLibrary(gameID: UUID) -> Bool {
        if case .loaded(let games) = state {
            return games.contains(where: { $0.id == gameID })
        }
        if locallyAddedGameIDs.contains(gameID) { return true }

        switch actionState {
        case .confirmingRemoval(let game): return game.id == gameID
        case .removing(let removingID): return removingID == gameID
        case .failed(let failedID, .remove, _): return failedID == gameID
        case .idle, .adding(_), .failed(_, .add, _): return false
        }
    }

    func isAdding(gameID: UUID) -> Bool {
        guard case .adding(let addingID) = actionState else { return false }
        return addingID == gameID
    }

    func isRemoving(gameID: UUID) -> Bool {
        guard case .removing(let removingID) = actionState else { return false }
        return removingID == gameID
    }

    func buttonState(for gameID: UUID) -> LibraryButtonState {
        if isAdding(gameID: gameID) { return .adding }
        if isRemoving(gameID: gameID) { return .removing }
        if isInLibrary(gameID: gameID) { return .inLibrary }
        return .available
    }

    func performLibraryAction(for game: GameCatalogItem) async -> LibraryActionResult {
        guard case .idle = actionState else { return .failed }
        if isInLibrary(gameID: game.id) {
            requestRemovalConfirmation(for: game)
            return .confirmationRequested
        }
        return await addToLibrary(game)
    }

    func addToLibrary(_ game: GameCatalogItem) async -> LibraryActionResult {
        guard case .idle = actionState else { return .failed }
        actionState = .adding(game.id)

        do {
            try await repository.addToCollection(gameID: game.id)
            markAsInLibrary(game)
            actionState = .idle
            return .succeeded
        } catch NetworkError.status(409) {
            markAsInLibrary(game)
            actionState = .idle
            return .succeeded
        } catch NetworkError.status(401) {
            actionState = .failed(
                gameID: game.id,
                operation: .add,
                message: "Tu sesión ha caducado. Inicia sesión de nuevo para añadir este juego."
            )
            return .sessionExpired
        } catch {
            actionState = .failed(
                gameID: game.id,
                operation: .add,
                message: "No se pudo añadir el juego. Inténtalo de nuevo."
            )
            return .failed
        }
    }

    func requestRemovalConfirmation(for game: GameCatalogItem) {
        guard case .idle = actionState else { return }
        actionState = .confirmingRemoval(game)
    }

    func cancelRemovalConfirmation() {
        guard case .confirmingRemoval = actionState else { return }
        actionState = .idle
    }

    func beginRemoval() -> GameCatalogItem? {
        guard case .confirmingRemoval(let game) = actionState else { return nil }
        actionState = .removing(game.id)
        return game
    }

    func confirmRemoval(_ game: GameCatalogItem) async -> LibraryActionResult {
        guard case .removing(let gameID) = actionState, gameID == game.id else { return .failed }
        do {
            try await repository.removeFromCollection(gameID: game.id)
            removeFromLoadedLibrary(game)
            locallyAddedGameIDs.remove(game.id)
            actionState = .idle
            return .succeeded
        } catch NetworkError.status(401) {
            actionState = .failed(
                gameID: game.id,
                operation: .remove,
                message: "Tu sesión ha caducado. Inicia sesión de nuevo para quitar este juego."
            )
            return .sessionExpired
        } catch {
            actionState = .failed(
                gameID: game.id,
                operation: .remove,
                message: "No se pudo quitar el juego. Inténtalo de nuevo."
            )
            return .failed
        }
    }

    func dismissActionError() {
        guard case .failed = actionState else { return }
        actionState = .idle
    }

    private func removeFromLoadedLibrary(_ game: GameCatalogItem) {
        guard case .loaded(var games) = state else { return }
        games.removeAll { $0.id == game.id }
        state = .loaded(games)
    }

    private func markAsInLibrary(_ game: GameCatalogItem) {
        locallyAddedGameIDs.insert(game.id)
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

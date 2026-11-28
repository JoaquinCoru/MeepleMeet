import Foundation
import Mastery26
import SwiftUI
import Mastery26

@APIActor
private struct PreviewLibraryRepository: LibraryRepository {
    nonisolated init() {}

    func getCollection() async throws -> [GameCatalogItem] {
        GamesSampleData.libraryGames
    }

    func addToCollection(gameID: UUID) async throws {}
    func removeFromCollection(gameID: UUID) async throws {}
}

enum GamesSampleData {
    static let games: [GameCatalogItem] = [
        GameCatalogItem(
            id: UUID(),
            title: "Catan",
            category: "Estrategia",
            minPlayers: 3,
            maxPlayers: 4,
            minDurationMinutes: 60,
            maxDurationMinutes: 90,
            ownerCount: 3,
            placeholderEmoji: "🏝️"
        ),
        GameCatalogItem(
            id: UUID(),
            title: "Wingspan",
            category: "Familiar",
            minPlayers: 1,
            maxPlayers: 5,
            minDurationMinutes: 40,
            maxDurationMinutes: 70,
            ownerCount: 2,
            placeholderEmoji: "🐦"
        ),
        GameCatalogItem(
            id: UUID(),
            title: "Azul",
            category: "Abstracto",
            minPlayers: 2,
            maxPlayers: 4,
            minDurationMinutes: 30,
            maxDurationMinutes: 45,
            ownerCount: 2,
            placeholderEmoji: "🔷"
        ),
        GameCatalogItem(
            id: UUID(),
            title: "Ark Nova",
            category: "Estrategia",
            minPlayers: 1,
            maxPlayers: 4,
            minDurationMinutes: 90,
            maxDurationMinutes: 150,
            ownerCount: 3,
            placeholderEmoji: "🦁"
        ),
        GameCatalogItem(
            id: UUID(),
            title: "Dixit",
            category: "Familiar",
            minPlayers: 3,
            maxPlayers: 8,
            durationMinutes: 30,
            ownerCount: 2,
            placeholderEmoji: "🎨"
        ),
        GameCatalogItem(
            id: UUID(),
            title: "La Tripulación",
            category: "Cooperativo",
            minPlayers: 2,
            maxPlayers: 5,
            durationMinutes: 20,
            ownerCount: 2,
            placeholderEmoji: "🚀"
        )
    ]

    static var libraryGames: [GameCatalogItem] {
       Array(games.prefix(3))
    }
}

struct GamesPreviewModifier: PreviewModifier {
    typealias Context = GamesPreviewContext

    static func makeSharedContext() async throws -> Context {
        let auth = AuthVM(state: .authenticated(AuthenticatedUser(
            id: UUID(),
            name: "Alex Demo",
            email: "alex@example.com"
        )))
        return Context(
            games: GamesVM(games: GamesSampleData.games),
            library: LibraryVM(
                libraryGames: GamesSampleData.libraryGames,
                repository: PreviewLibraryRepository()
            ),
            auth: auth
        )
    }

    func body(content: Content, context: Context) -> some View {
        content
            .environment(context.games)
            .environment(context.library)
            .environment(context.auth)
    }
}

struct GamesPreviewContext {
    let games: GamesVM
    let library: LibraryVM
    let auth: AuthVM
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var gamesSampleData: Self = .modifier(GamesPreviewModifier())
}


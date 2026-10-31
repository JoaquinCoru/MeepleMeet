import Foundation
import SwiftUI

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
}

struct GamesPreviewModifier: PreviewModifier {
    typealias Context = GamesVM

    static func makeSharedContext() async throws -> GamesVM {
        GamesVM(games: GamesSampleData.games)
    }

    func body(content: Content, context: GamesVM) -> some View {
        content
            .environment(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var gamesSampleData: Self = .modifier(GamesPreviewModifier())
}


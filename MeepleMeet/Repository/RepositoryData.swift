import Foundation
import Mastery26

struct Repository: RepositoryData {
    let delegate: (any URLSessionTaskDelegate)? = nil

    nonisolated init() {}
}

protocol RepositoryData: NetworkInteractor, Sendable {
    func getGames() async throws -> [GameCatalogItem]
}

extension RepositoryData {
    func getGames() async throws -> [GameCatalogItem] {
        try await getJSON(
            .request(url: .getGames),
            type: [GameCatalogItem].self
        )
    }
}

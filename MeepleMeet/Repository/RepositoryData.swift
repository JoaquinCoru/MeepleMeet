import Foundation
import Mastery26

struct Repository: RepositoryData {
    @Keychain(key: "jwt") private var token
    var jwtToken: Data? { token }
    let delegate: (any URLSessionTaskDelegate)? = nil

    nonisolated init() {}
}

protocol RepositoryData: NetworkInteractor, Sendable {
    var jwtToken: Data? { get }
    func getGames() async throws -> [GameCatalogItem]
    func getCollection() async throws -> [GameCatalogItem]
}

extension RepositoryData {
    func getGames() async throws -> [GameCatalogItem] {
        try await getJSON(
            .request(url: .getGames),
            type: [GameCatalogItem].self
        )
    }

    func getCollection() async throws -> [GameCatalogItem] {
        try await getJSON(
            .request(url: .getCollection, token: jwt),
            type: [GameCatalogItem].self
        )
    }

    var jwt: String? {
        get async {
            var security = Security()
            guard let tokenData = jwtToken,
                  let token = String(data: tokenData, encoding: .utf8) else { return nil }
            do {
                try await security.validateJWT(jwt: token)
            } catch JWTError.tokenExpired {
                return nil
            } catch {
                print(error)
            }
            return token
        }
    }
}

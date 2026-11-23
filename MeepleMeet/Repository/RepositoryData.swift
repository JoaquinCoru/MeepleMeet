import Foundation
import Mastery26

struct Repository: RepositoryData {
    @Keychain(key: "meeplemeet.auth.token") private var storedToken
    var authToken: Data? {
        get { storedToken }
        nonmutating set { storedToken = newValue }
    }
    let delegate: (any URLSessionTaskDelegate)? = nil

    nonisolated init() {}

    func login(email: String, password: String) async throws -> LoginResponse {
        let credentials = Data("\(email):\(password)".utf8).base64EncodedString()
        let response = try await getJSON(
            .request(.post, url: .login, token: credentials, authentication: .basic),
            type: LoginResponse.self
        )
        authToken = Data(response.token.utf8)
        return response
    }

    func register(name: String, email: String, password: String) async throws {
        let request = RegisterRequest(name: name, email: email, password: password)
        try await getStatus(.request(.post, url: .register, body: request), status: 201)
    }
}

protocol RepositoryData: NetworkInteractor, Sendable {
    var authToken: Data? { get set }
    func getGames() async throws -> [GameCatalogItem]
    func register(name: String, email: String, password: String) async throws
}

extension RepositoryData {
    func getGames() async throws -> [GameCatalogItem] {
        try await getJSON(
            .request(url: .getGames),
            type: [GameCatalogItem].self
        )
    }
}

import Foundation
import Mastery26

struct Security: SecurityData {
    @Keychain(key: "jwt") private var storedToken

    var authToken: Data? {
        get { storedToken }
        nonmutating set { storedToken = newValue }
    }

    let delegate: (any URLSessionTaskDelegate)? = nil

    nonisolated init() {}
}

protocol SecurityData: NetworkInteractor, Sendable {
    var authToken: Data? { get set }

    mutating func login(email: String, password: String) async throws -> LoginResponse
    func register(name: String, email: String, password: String) async throws
    func validateJWT() async throws(NetworkError) -> AuthenticatedUser?
    mutating func clearAuthToken()
}

extension SecurityData {
    mutating func login(email: String, password: String) async throws -> LoginResponse {
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

    func validateJWT() async throws(NetworkError) -> AuthenticatedUser? {
        guard let authToken,
              let token = String(data: authToken, encoding: .utf8) else {
            return nil
        }

        return try await getJSON(
            .request(url: .validateJWT, token: token),
            type: AuthenticatedUser.self
        )
    }

    mutating func clearAuthToken() {
        authToken = nil
    }
}

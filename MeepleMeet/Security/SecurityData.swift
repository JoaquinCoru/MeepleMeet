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
    mutating func validateJWT(jwt: String) async throws
    func getUser(jwt: String) async throws -> AuthenticatedUser
    mutating func clearAuthToken()
}

extension SecurityData {
    var validator: JWT<AppPayload> {
        JWT(
            pemURL: Bundle.main.url(forResource: "meeplemeet_ecdsa-public", withExtension: "pem"),
            payloadType: AppPayload.self
        )
    }

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

    mutating func validateJWT(jwt: String) async throws {
        do {
            let payload = try await validator.validateJWT(jwt: jwt)
            guard payload.expiration > Date() else {
                throw JWTError.tokenExpired
            }
            guard payload.issuer == "MeepleMeetAPI" else {
                throw JWTError.invalidSignature
            }
        } catch JWTError.tokenExpired {
            clearAuthToken()
            throw JWTError.tokenExpired
        }
    }

    func getUser(jwt: String) async throws -> AuthenticatedUser {
        try await getJSON(
            .request(url: .getUser, token: jwt),
            type: AuthenticatedUser.self
        )
    }

    mutating func clearAuthToken() {
        authToken = nil
    }
}

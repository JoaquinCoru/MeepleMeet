import Foundation

struct LoginResponse: Decodable, Sendable {
    let token: String
    let user: AuthenticatedUser
}

struct AuthenticatedUser: Decodable, Sendable, Identifiable {
    let id: UUID
    let name: String
    let email: String
}

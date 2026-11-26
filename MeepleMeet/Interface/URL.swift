import Foundation

private let dev = URL(string: "http://localhost:8080/api/v1")!
private let api = dev

extension URL {
    /// GET /api/v1/games
    static let getGames = api
        .appending(path: "games")

    /// POST /api/v1/auth/login
    static let login = api
        .appending(path: "auth")
        .appending(path: "login")

    /// GET /api/v1/auth/me
    static let validateJWT = api
        .appending(path: "auth")
        .appending(path: "me")

    /// POST /api/v1/auth/register
    static let register = api
        .appending(path: "auth")
        .appending(path: "register")
}

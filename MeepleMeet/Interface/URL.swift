import Foundation

private let dev = URL(string: "http://localhost:8080/api/v1")!
private let api = dev

extension URL {
    /// GET /api/v1/games
    static let getGames = api
        .appending(path: "games")

    /// GET /api/v1/collection
    static let getCollection = api
        .appending(path: "collection")

    /// POST /api/v1/collection/:gameID
    static func addToCollection(gameID: UUID) -> URL {
        api
            .appending(path: "collection")
            .appending(path: gameID.uuidString)
    }

    /// POST /api/v1/auth/login
    static let login = api
        .appending(path: "auth")
        .appending(path: "login")

    /// GET /api/v1/auth/me
    static let getUser = api
        .appending(path: "auth")
        .appending(path: "me")

    /// POST /api/v1/auth/register
    static let register = api
        .appending(path: "auth")
        .appending(path: "register")
}

import Foundation

private let dev = URL(string: "http://localhost:8080/api")!
private let api = dev

extension URL {
    /// GET /api/v1/games
    static let getGames = api
        .appending(path: "v1")
        .appending(path: "games")
}

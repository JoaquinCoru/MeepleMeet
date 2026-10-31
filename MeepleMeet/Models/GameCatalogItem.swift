import Foundation

/// Decodable representation of a game returned by `GET /api/v1/games`.
struct GameCatalogItem: Decodable, Hashable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let category: String?
    let minPlayers: Int?
    let maxPlayers: Int?
    let durationMinutes: Int?
    let minDurationMinutes: Int?
    let maxDurationMinutes: Int?
    let imageURL: URL?
    let ownerCount: Int?
    let placeholderEmoji: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case minPlayers
        case maxPlayers
        case durationMinutes
        case minDurationMinutes
        case maxDurationMinutes
        case imageURL = "image"
        case ownerCount
        case placeholderEmoji
    }

    init(
        id: UUID,
        title: String,
        category: String? = nil,
        minPlayers: Int? = nil,
        maxPlayers: Int? = nil,
        durationMinutes: Int? = nil,
        minDurationMinutes: Int? = nil,
        maxDurationMinutes: Int? = nil,
        imageURL: URL? = nil,
        ownerCount: Int? = nil,
        placeholderEmoji: String? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.durationMinutes = durationMinutes
        self.minDurationMinutes = minDurationMinutes
        self.maxDurationMinutes = maxDurationMinutes
        self.imageURL = imageURL
        self.ownerCount = ownerCount
        self.placeholderEmoji = placeholderEmoji
    }

    var playersLabel: String? {
        switch (minPlayers, maxPlayers) {
        case let (minimum?, maximum?) where minimum == maximum:
            "\(minimum) \(minimum == 1 ? "jugador" : "jugadores")"
        case let (minimum?, maximum?):
            "\(minimum)–\(maximum) jugadores"
        case let (minimum?, nil):
            "Desde \(minimum) jugadores"
        case let (nil, maximum?):
            "Hasta \(maximum) jugadores"
        case (nil, nil):
            nil
        }
    }

    var detailsLabel: String? {
        [category, playersLabel]
            .compactMap { $0 }
            .joined(separator: " · ")
            .nilIfEmpty
    }

    var durationLabel: String? {
        if let minimum = minDurationMinutes, let maximum = maxDurationMinutes {
            return minimum == maximum ? "\(minimum) min" : "\(minimum)–\(maximum) min"
        }

        return durationMinutes.map { "\($0) min" }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

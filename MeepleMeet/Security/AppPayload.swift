//
//  AppPayload.swift
//  MeepleMeet
//
//  Created by Joaquín Corugedo Rodríguez on 26/11/2026.
//

import Foundation

struct AppPayload: Codable {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuer = "iss"
    }

    var subject: String
    var expiration: Date
    var issuer: String
}

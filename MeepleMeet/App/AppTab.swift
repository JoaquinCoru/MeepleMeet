import SwiftUI

enum AppTab: Hashable, CaseIterable, Identifiable {
    case inicio
    case juegos
    case quedadas
    case ludoteca
    case perfil

    var id: Self { self }

    var title: String {
        switch self {
        case .inicio: "Inicio"
        case .juegos: "Juegos"
        case .quedadas: "Quedadas"
        case .ludoteca: "Ludoteca"
        case .perfil: "Perfil"
        }
    }

    var symbol: String {
        switch self {
        case .inicio: "house"
        case .juegos: "die.face.5"
        case .quedadas: "person.3"
        case .ludoteca: "books.vertical"
        case .perfil: "person.crop.circle"
        }
    }
}

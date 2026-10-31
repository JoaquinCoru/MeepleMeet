import SwiftUI

struct GamesView: View {
    var body: some View {
        ContentUnavailableView("Juegos", systemImage: "die.face.5")
            .navigationTitle("Juegos")
    }
}

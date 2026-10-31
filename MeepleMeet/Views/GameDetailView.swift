import SwiftUI

struct GameDetailView: View {
    let game: GameCatalogItem

    var body: some View {
        Color.clear
            .navigationTitle(game.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

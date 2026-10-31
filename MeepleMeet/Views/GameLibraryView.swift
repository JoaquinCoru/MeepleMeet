import SwiftUI

struct GameLibraryView: View {
    var body: some View {
        ContentUnavailableView("Ludoteca", systemImage: "books.vertical")
            .navigationTitle("Ludoteca")
    }
}

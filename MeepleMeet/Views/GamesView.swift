import SwiftUI

struct GamesView: View {
    @Environment(GamesVM.self) private var viewModel
    @State private var path: [GameCatalogItem] = []

    var body: some View {

            Group {
                if viewModel.games.isEmpty {
                    ContentUnavailableView("Juegos", systemImage: "die.face.5")
                } else {
                    NavigationStack(path: $path) {
                        List(viewModel.games) { game in
                            Button {
                                path.append(game)
                            } label: {
                                GameListItemView(game: game)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .navigationTitle("Juegos")
                        .navigationDestination(for: GameCatalogItem.self) { game in
                            GameDetailView(game: game)
                        }
                    }
                }
            }
    }
}

#Preview(traits: .gamesSampleData) {
    GamesView()
}

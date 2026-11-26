import SwiftUI

struct GamesView: View {
    var onSearchMeetups: () -> Void = {}
    @Environment(GamesVM.self) private var viewModel
    @State private var path: [GameCatalogItem] = []

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Cargando juegos…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failed(let errorMessage):
                    ContentUnavailableView {
                        Label("No se pudieron cargar los juegos", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Reintentar") {
                            Task { await viewModel.loadGames() }
                        }
                    }
                case .loaded(let games) where games.isEmpty:
                    ContentUnavailableView("No hay juegos", systemImage: "die.face.5")
                case .loaded(let games):
                    List(games) { game in
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
                }
            }
            .navigationTitle("Juegos")
            .navigationDestination(for: GameCatalogItem.self) { game in
                GameDetailView(game: game, onSearchMeetups: onSearchMeetups)
            }
        }
        .task {
            await viewModel.loadGames()
        }
    }
}

#Preview(traits: .gamesSampleData) {
    GamesView()
}

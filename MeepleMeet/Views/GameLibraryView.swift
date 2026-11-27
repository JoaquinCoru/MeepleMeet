import SwiftUI

struct GameLibraryView: View {
    var onExploreGames: () -> Void = {}
    var onSearchMeetups: () -> Void = {}
    var onRequestLogin: () -> Void = {}
    @Environment(AuthVM.self) private var authViewModel
    @Environment(LibraryVM.self) private var viewModel
    @State private var path: [GameCatalogItem] = []
    @State private var gamePendingDeletion: GameCatalogItem?
    @State private var deletionError: String?

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch authViewModel.state {
                case .notChecked, .checkingSession:
                    SessionRestoreView()
                case .restoreError(let errorMessage):
                    SessionRestoreView(errorMessage: errorMessage) {
                        Task { await authViewModel.restoreSession() }
                    }
                case .authenticated(_):
                    libraryList
                case .notAuthenticated:
                    LibraryNoSessionView(onRequestLogin: onRequestLogin)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(for: GameCatalogItem.self) { game in
                GameDetailView(
                    game: game,
                    onSearchMeetups: onSearchMeetups,
                    onRequestLogin: onRequestLogin
                )
            }
            .alert(deletionError == nil ? "¿Eliminar juego?" : "No se pudo eliminar", isPresented: deletionAlertIsPresented) {
                if deletionError != nil {
                    Button("Aceptar", role: .cancel) { deletionError = nil }
                } else {
                    Button("Cancelar", role: .cancel) {
                        gamePendingDeletion = nil
                    }
                    Button("Eliminar", role: .destructive) {
                        guard let game = gamePendingDeletion else { return }
                        self.gamePendingDeletion = nil
                        Task {
                            do {
                                try await viewModel.removeFromLibrary(game)
                            } catch {
                                deletionError = error.localizedDescription
                            }
                        }
                    }
                }
            } message: {
                if let deletionError {
                    Text(deletionError)
                } else if let gamePendingDeletion {
                    Text("¿Quieres quitar «\(gamePendingDeletion.title)» de tu ludoteca?")
                }
            }
        }
    }

    private var libraryList: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Mi ludoteca")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.libraryAccent)
                        Text("Los juegos que puedes llevar a la mesa.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)

                    summaryCard
                }
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
            }

            Section {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Cargando tu ludoteca…")
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                case .failed(let errorMessage):
                    ContentUnavailableView {
                        Label("No se pudo cargar la ludoteca", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Reintentar") {
                            Task { await viewModel.loadLibraryGames() }
                        }
                    }
                    .listRowBackground(Color.clear)
                case .loaded(let games) where games.isEmpty:
                    ContentUnavailableView {
                        Label("Tu ludoteca está vacía", systemImage: "books.vertical")
                    } description: {
                        Text("Añade juegos desde el catálogo para compartir qué puedes llevar a la mesa.")
                    }
                    .padding(.vertical, 8)
                case .loaded(let games):
                    ForEach(games) { game in
                        GameListItemView(
                            game: game,
                            trailingSymbol: nil,
                            onSelect: { path.append(game) },
                            onDelete: {
                                gamePendingDeletion = game
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
            }

            Section {
                Button(action: onExploreGames) {
                    Label("Añadir juegos", systemImage: "plus")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.green)
                .overlay(Capsule().stroke(Color.green, lineWidth: 1))
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)

                ownersPrompt
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listRowSeparator(.hidden)
        .task {
            await viewModel.loadLibraryGames()
        }
    }

    private var deletionAlertIsPresented: Binding<Bool> {
        Binding(
            get: { gamePendingDeletion != nil || deletionError != nil },
            set: { isPresented in
                if !isPresented {
                    gamePendingDeletion = nil
                    deletionError = nil
                }
            }
        )
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "books.vertical")
                .font(.system(size: 18, weight: .medium))
            Text("\(libraryGameCount) \(libraryGameCount == 1 ? "juego" : "juegos")")
                .font(.title3.bold())
            Text("Tu colección personal")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.82))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.libraryAccent, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var libraryGameCount: Int {
        guard case .loaded(let games) = viewModel.state else { return 0 }
        return games.count
    }

    private var ownersPrompt: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿Buscas un juego de alguien?")
                .font(.headline)
                .foregroundStyle(.libraryAccent)
            Text("Abre el catálogo y consulta qué usuarios tienen cada título para encontrar posibilidades de partida.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: onExploreGames) {
                Text("Buscar propietarios")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground), in: Capsule())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary.opacity(0.75))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview("Mi ludoteca", traits: .gamesSampleData) {
    GameLibraryView()
}

#Preview("Ludoteca sin sesión") {
    GameLibraryView()
        .environment(LibraryVM(libraryGames: GamesSampleData.libraryGames))
        .environment(AuthVM(state: .notAuthenticated))
}

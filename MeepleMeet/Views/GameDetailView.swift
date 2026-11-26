import SwiftUI
import Mastery26

struct GameDetailView: View {
    let game: GameCatalogItem
    var onSearchMeetups: () -> Void = {}
    var onRequestLogin: () -> Void = {}

    @Environment(AuthVM.self) private var authViewModel
    @Environment(LibraryVM.self) private var libraryViewModel
    @State private var addState: AddToLibraryState = .idle

    private enum AddToLibraryState {
        case idle
        case adding
        case added
        case alreadyInLibrary
        case failed(String)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                gameHeader

                VStack(alignment: .leading, spacing: 7) {
                    Text("Sobre el juego")
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Text(game.description ?? "Descubre \(game.title) y disfruta de una nueva partida con tus amigos.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                gameFacts

                libraryButton

                ownersCard

                Button(action: onSearchMeetups) {
                    Label("Buscar quedadas de \(game.title)", systemImage: "calendar")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.accent)
                .background(.accent.opacity(0.07), in: Capsule())
                .overlay(Capsule().stroke(.accent.opacity(0.7), lineWidth: 1))

                if let rulesURL = game.rulesURL {
                    Link(destination: rulesURL) {
                        HStack(spacing: 8) {
                            Label("Consultar reglas oficiales", systemImage: "book")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.footnote)
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.accent)
                        .padding(.horizontal, 2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var gameHeader: some View {
        HStack(spacing: 16) {
            gameImage
                .frame(width: 104, height: 126)

            VStack(alignment: .leading, spacing: 8) {
                Text(game.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let category = game.category {
                    Text(category)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.sand.opacity(0.65), in: Capsule())
                }

                if let playersLabel = game.playersLabel {
                    Label(playersLabel, systemImage: "person.2")
                }
                if let durationLabel = game.durationLabel {
                    Label(durationLabel, systemImage: "clock")
                }
            }
            .font(.caption)
            .foregroundStyle(Color.primary.opacity(0.76))

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .leading)
        .background(Color.sand, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private var gameImage: some View {
        if let imageURL = game.imageURL {
            AsyncImage(url: imageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                } else if phase.error != nil {
                    imagePlaceholder
                } else {
                    ProgressView()
                        .tint(.accent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 15))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .accessibilityLabel("Imagen de \(game.title)")
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(Color.white.opacity(0.55))
            .overlay {
                Text(game.placeholderEmoji ?? "🎲")
                    .font(.system(size: 40))
            }
    }

    private var gameFacts: some View {
        HStack(spacing: 12) {
            factCard(title: "Jugadores", value: game.playersLabel ?? "Por confirmar", symbol: "person.2")
            factCard(title: "Duración", value: game.durationLabel ?? "Por confirmar", symbol: "clock")
        }
    }

    private func factCard(title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: symbol)
                .font(.subheadline)
                .foregroundStyle(.accent)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var libraryButton: some View {
        VStack(spacing: 8) {
            Button {
                guard hasAuthenticatedSession else {
                    onRequestLogin()
                    return
                }
                Task { await addGameToLibrary() }
            } label: {
                Group {
                    if isAdding {
                        HStack(spacing: 9) {
                            ProgressView().tint(.white)
                            Text("Añadiendo…")
                        }
                    } else if isInLibrary {
                        Label("En mi ludoteca", systemImage: "checkmark")
                    } else if hasAuthenticatedSession {
                        Label("Añadir a mi ludoteca", systemImage: "plus")
                    } else {
                        Label("Inicia sesión para añadir", systemImage: "person.crop.circle")
                    }
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(isInLibrary || isAdding ? .white : .accent)
                .background(isInLibrary || isAdding ? .accent : .accent.opacity(0.08), in: Capsule())
                .overlay(Capsule().stroke(.accent, lineWidth: isInLibrary || isAdding ? 0 : 1))
            }
            .buttonStyle(.plain)
            .disabled(isAdding || (hasAuthenticatedSession && isInLibrary))
            .accessibilityHint(isInLibrary ? "Este juego ya está en tu ludoteca" : "Añade el juego a tu ludoteca")

            if case .failed(let message) = addState {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var hasAuthenticatedSession: Bool {
        if case .authenticated(_) = authViewModel.state { return true }
        return false
    }

    private var isAdding: Bool {
        if case .adding = addState { return true }
        return false
    }

    private var isInLibrary: Bool {
        if case .loaded(let games) = libraryViewModel.state,
           games.contains(where: { $0.id == game.id }) {
            return true
        }

        switch addState {
        case .added, .alreadyInLibrary:
            return true
        case .idle, .adding, .failed(_):
            return false
        }
    }

    @MainActor
    private func addGameToLibrary() async {
        addState = .adding
        do {
            try await libraryViewModel.addToLibrary(game)
            addState = .added
        } catch NetworkError.status(409) {
            libraryViewModel.markAsInLibrary(game)
            addState = .alreadyInLibrary
        } catch NetworkError.status(401) {
            addState = .idle
            await authViewModel.invalidateSession()
        } catch {
            addState = .failed("No se pudo añadir el juego. Inténtalo de nuevo.")
        }
    }

    private var ownersCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Personas que lo tienen")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if let ownerCount = game.ownerCount {
                    Text("\(ownerCount)")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: Capsule())
                }
            }

            Text("En la versión real aparecerán aquí los perfiles públicos y opciones para conectar con la comunidad.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview("Detalle del juego", traits: .gamesSampleData) {
    NavigationStack {
        GameDetailView(game: GamesSampleData.games[0])
    }
}

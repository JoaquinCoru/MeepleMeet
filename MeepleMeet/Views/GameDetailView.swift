import SwiftUI

struct GameDetailView: View {
    let game: GameCatalogItem
    var onSearchMeetups: () -> Void = {}

    @State private var isInLibrary = false

    private let accent = Color(red: 0.02, green: 0.59, blue: 0.28)
    private let sand = Color(red: 0.91, green: 0.86, blue: 0.76)

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
                .foregroundStyle(accent)
                .background(accent.opacity(0.07), in: Capsule())
                .overlay(Capsule().stroke(accent.opacity(0.7), lineWidth: 1))

                if let rulesURL = game.rulesURL {
                    Link(destination: rulesURL) {
                        HStack(spacing: 8) {
                            Label("Consultar reglas oficiales", systemImage: "book")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.footnote)
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(accent)
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
                        .background(.white.opacity(0.65), in: Capsule())
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
        .background(sand, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
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
                        .tint(accent)
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
            .fill(.white.opacity(0.55))
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
                .foregroundStyle(accent)
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
        Button {
            withAnimation(.snappy(duration: 0.2)) {
                isInLibrary.toggle()
            }
        } label: {
            Label(
                isInLibrary ? "En mi ludoteca · Quitar" : "Añadir a mi ludoteca",
                systemImage: isInLibrary ? "checkmark" : "plus"
            )
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(isInLibrary ? .white : accent)
            .background(isInLibrary ? accent : accent.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(accent, lineWidth: isInLibrary ? 0 : 1))
        }
        .buttonStyle(.plain)
        .accessibilityHint(isInLibrary ? "Quita el juego de tu ludoteca" : "Añade el juego a tu ludoteca")
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

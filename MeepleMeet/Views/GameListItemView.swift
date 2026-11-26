import SwiftUI

struct GameListItemView: View {
    let game: GameCatalogItem
    var trailingSymbol: String? = "chevron.right"
    var onSelect: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let onSelect {
                Button(action: onSelect) {
                    gameInformation
                }
                .buttonStyle(.plain)
            } else {
                gameInformation
            }

            Spacer(minLength: 8)

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.trash)
                        .frame(width: 36, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Eliminar \(game.title) de mi ludoteca")
            } else if let trailingSymbol {
                Image(systemName: trailingSymbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary.opacity(0.8))
                    .accessibilityHidden(true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private var gameInformation: some View {
        HStack(spacing: 12) {
            cover

            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                if let details = game.detailsLabel {
                    Text(details)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }

                if let duration = game.durationLabel {
                    Text(duration)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }

                if let ownerCount = game.ownerCount {
                    Text("\(ownerCount) \(ownerCount == 1 ? "usuario lo tiene" : "usuarios lo tienen")")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.green)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var cover: some View {
        if let imageURL = game.imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                coverPlaceholder
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityLabel("Portada de \(game.title)")
        } else {
            coverPlaceholder
                .accessibilityHidden(true)
        }
    }

    private var coverPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(.sand)
            .overlay {
                Text(game.placeholderEmoji ?? "🎲")
                    .font(.system(size: 29))
            }
            .frame(width: 70, height: 70)
    }
}

#Preview("Fila del catálogo", traits: .gamesSampleData) {
    GameListItemView(game: GamesSampleData.games[0])
        .padding(8)
}

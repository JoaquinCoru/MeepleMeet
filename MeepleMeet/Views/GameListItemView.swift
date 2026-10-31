import SwiftUI

struct GameListItemView: View {
    let game: GameCatalogItem

    var body: some View {
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

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.secondary.opacity(0.8))
                .accessibilityHidden(true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
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
            .fill(Color(red: 0.91, green: 0.86, blue: 0.76))
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

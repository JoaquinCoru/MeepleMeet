import SwiftUI

struct LibraryNoSessionView: View {
    var onRequestLogin: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.sand)
                            .frame(width: 96, height: 96)
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.libraryAccent)
                    }

                    VStack(spacing: 8) {
                        Text("Tu ludoteca te espera")
                            .font(.title2.bold())
                            .foregroundStyle(.libraryAccent)
                            .multilineTextAlignment(.center)
                        Text("Debes iniciar sesión para poder ver y editar tu ludoteca.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button(action: onRequestLogin) {
                    Label("Iniciar sesión", systemImage: "person.crop.circle")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.libraryAccent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Text("Inicia sesión para consultar tus juegos y mantener tu colección al día.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            .padding(24)
            .frame(maxWidth: 440)
            .frame(maxWidth: .infinity, minHeight: 420, alignment: .center)
            .padding(.horizontal, 16)
        }
    }
}

#Preview("Ludoteca sin sesión") {
    LibraryNoSessionView()
}

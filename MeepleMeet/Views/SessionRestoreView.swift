import SwiftUI

struct SessionRestoreView: View {
    var errorMessage: String?
    var onRetry: () -> Void = {}

    var body: some View {
        Group {
            if let errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(.libraryAccent)

                    Text("No se pudo comprobar la sesión")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Reintentar", action: onRetry)
                        .buttonStyle(.borderedProminent)
                        .tint(.libraryAccent)
                }
                .padding(24)
                .frame(maxWidth: 420)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView("Comprobando tu sesión…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
}

#Preview {
    SessionRestoreView(errorMessage: "No se ha podido comprobar tu sesión. Comprueba tu conexión e inténtalo de nuevo.", onRetry: {})
}

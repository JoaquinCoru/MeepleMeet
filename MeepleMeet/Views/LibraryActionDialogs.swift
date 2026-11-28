import SwiftUI

struct LibraryActionDialogs: ViewModifier {
    @Environment(AuthVM.self) private var authViewModel
    @Environment(LibraryVM.self) private var libraryViewModel

    func body(content: Content) -> some View {
        @Bindable var bindableLibraryViewModel = libraryViewModel

        content
            .confirmationDialog(
                "¿Quitar juego de tu ludoteca?",
                isPresented: $bindableLibraryViewModel.isConfirmingRemoval,
                titleVisibility: .visible
            ) {
                Button("Quitar de mi ludoteca", role: .destructive) {
                    guard let game = libraryViewModel.beginRemoval() else { return }
                    Task {
                        let result = await libraryViewModel.confirmRemoval(game)
                        if result == .sessionExpired {
                            await authViewModel.invalidateSession()
                        }
                    }
                }
                Button("Cancelar", role: .cancel) {
                    libraryViewModel.cancelRemovalConfirmation()
                }
            } message: {
                if let game = libraryViewModel.pendingRemovalGame {
                    Text("¿Quieres quitar «\(game.title)» de tu ludoteca?")
                }
            }
            .alert("No se pudo actualizar tu ludoteca", isPresented: $bindableLibraryViewModel.isShowingActionError) {
                Button("Aceptar", role: .cancel) {}
            } message: {
                if let message = libraryViewModel.actionErrorMessage {
                    Text(message)
                }
            }
    }
}

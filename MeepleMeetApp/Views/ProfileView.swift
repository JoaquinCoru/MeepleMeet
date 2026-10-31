import SwiftUI

struct ProfileView: View {
    var body: some View {
        ContentUnavailableView("Perfil", systemImage: "person.crop.circle")
            .navigationTitle("Perfil")
    }
}

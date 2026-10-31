import SwiftUI

struct HomeView: View {
    var body: some View {
        ContentUnavailableView("Inicio", systemImage: "house")
            .navigationTitle("Inicio")
    }
}

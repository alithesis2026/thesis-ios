import SwiftUI

struct FavoritesScreenView: View {
    @ObservedObject private var viewModel = FavoritesViewModel(favoritesStore: FavoritesStore())

    var body: some View {
        List(viewModel.favorites) { movie in
            Text(movie.title)
        }
        .navigationTitle("Favorites")
    }
}

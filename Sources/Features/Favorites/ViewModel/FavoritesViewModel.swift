import Foundation
import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [Movie] = []

    private let favoritesStore: FavoritesStoring
    private var cancellables = Set<AnyCancellable>()

    init(favoritesStore: FavoritesStoring) {
        self.favoritesStore = favoritesStore

        favoritesStore.favoritesChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.reload() }
            .store(in: &cancellables)

        reload()
    }

    func reload() {
        favorites = favoritesStore.fetchAllFavorites()
    }
}

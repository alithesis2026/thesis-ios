import Foundation

final class AppDependencyContainer {
    let apiClient: APIClient
    let tmdbService: TMDBServicing
    let favoritesStore: FavoritesStoring

    init(
        apiClient: APIClient = URLSessionAPIClient(),
        tmdbService: TMDBServicing? = nil,
        favoritesStore: FavoritesStoring = FavoritesStore()
    ) {
        self.apiClient = apiClient
        self.tmdbService = tmdbService ?? TMDBService(apiClient: apiClient)
        self.favoritesStore = favoritesStore
    }

    @MainActor
    func makeMovieListViewController() -> MovieListViewController {
        let viewController = MovieListViewController(viewModel: MovieListViewModel(tmdbService: tmdbService))
        viewController.onSelectMovie = { [weak viewController] movieId in
            guard let viewController else { return }
            let detailViewController = self.makeMovieDetailViewController(movieId: movieId)
            viewController.navigationController?.pushViewController(detailViewController, animated: true)
        }
        return viewController
    }

    @MainActor
    func makeMovieDetailViewController(movieId: Int) -> MovieDetailViewController {
        let viewModel = MovieDetailViewModel(movieId: movieId, tmdbService: tmdbService, favoritesStore: favoritesStore)
        return MovieDetailViewController(viewModel: viewModel)
    }

    @MainActor
    func makeFavoritesViewController() -> FavoritesViewController {
        let viewController = FavoritesViewController(viewModel: FavoritesViewModel(favoritesStore: favoritesStore))
        viewController.onSelectMovie = { [weak viewController] movieId in
            guard let viewController else { return }
            let detailViewController = self.makeMovieDetailViewController(movieId: movieId)
            viewController.navigationController?.pushViewController(detailViewController, animated: true)
        }
        return viewController
    }

    @MainActor
    func makeSearchViewController() -> SearchViewController {
        let viewController = SearchViewController(viewModel: SearchViewModel(tmdbService: tmdbService))
        viewController.onSelectMovie = { [weak viewController] movieId in
            guard let viewController else { return }
            let detailViewController = self.makeMovieDetailViewController(movieId: movieId)
            viewController.navigationController?.pushViewController(detailViewController, animated: true)
        }
        return viewController
    }

    @MainActor
    func makeSettingsViewController() -> SettingsViewController {
        SettingsViewController(viewModel: SettingsViewModel())
    }
}

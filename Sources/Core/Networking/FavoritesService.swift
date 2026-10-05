import Foundation

final class FavoritesService {
    private let movieService: MovieService

    init(movieService: MovieService) {
        self.movieService = movieService
    }

    func favoritedTrendingMovies(favoriteIds: Set<Int>) async -> [MovieDTO] {
        let trending = (try? await movieService.fetchTrending()) ?? []
        return trending.filter { favoriteIds.contains($0.id) }
    }
}

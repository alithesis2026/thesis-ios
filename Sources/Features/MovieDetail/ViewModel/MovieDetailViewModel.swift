import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published private(set) var detail: MovieDetailDTO?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorite: Bool

    let movieId: Int
    private let tmdbService: TMDBServicing
    private let favoritesStore: FavoritesStoring

    init(movieId: Int, tmdbService: TMDBServicing, favoritesStore: FavoritesStoring) {
        self.movieId = movieId
        self.tmdbService = tmdbService
        self.favoritesStore = favoritesStore
        self.isFavorite = favoritesStore.isFavorite(movieId: movieId)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            detail = try await tmdbService.movieDetail(id: movieId)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func toggleFavorite() {
        guard let detail else { return }
        favoritesStore.toggleFavorite(movie: Movie(detail: detail))
        isFavorite = favoritesStore.isFavorite(movieId: movieId)
        AnalyticsManager.shared.track("favorite_toggled", parameters: ["movie_id": movieId, "is_favorite": isFavorite])
    }
}

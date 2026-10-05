import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published private(set) var detail: MovieDetailDTO?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorite: Bool
    @Published private(set) var similarMovies: [Movie] = []

    let movieId: Int
    private let tmdbService: TMDBServicing
    private let favoritesStore: FavoritesStoring
    private var similarMoviesTask: URLSessionDataTask?

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
    }

    func loadSimilarMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)/similar") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(APIConfig.readAccessToken)", forHTTPHeaderField: "Authorization")

        similarMoviesTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data, let response = try? JSONDecoder().decode(MoviePageDTO.self, from: data) else { return }
            self.similarMovies = response.results.map { Movie(dto: $0) }
        }
        similarMoviesTask?.resume()
    }
}

import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published private(set) var detail: MovieDetailDTO?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorite: Bool
    @Published private(set) var trailerKey: String?

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
    }

    func loadTrailer() async {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)/videos") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(APIConfig.readAccessToken)", forHTTPHeaderField: "Authorization")

        struct VideoListResponse: Decodable {
            struct Video: Decodable {
                let key: String
                let site: String
                let type: String
            }
            let results: [Video]
        }

        guard let (data, _) = try? await URLSession.shared.data(for: request) else { return }
        let response = try? JSONDecoder().decode(VideoListResponse.self, from: data)
        trailerKey = response?.results.first(where: { $0.site == "YouTube" && $0.type == "Trailer" })?.key
    }
}

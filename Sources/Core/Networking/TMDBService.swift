import Foundation

protocol TMDBServicing {
    func popularMovies(page: Int) async throws -> MoviePageDTO
    func movieDetail(id: Int) async throws -> MovieDetailDTO
    func searchMovies(query: String, page: Int) async throws -> MoviePageDTO
}

final class TMDBService: TMDBServicing {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func popularMovies(page: Int) async throws -> MoviePageDTO {
        try await apiClient.request(.popularMovies(page: page))
    }

    func movieDetail(id: Int) async throws -> MovieDetailDTO {
        try await apiClient.request(.movieDetail(id: id))
    }

    func searchMovies(query: String, page: Int) async throws -> MoviePageDTO {
        try await apiClient.request(.searchMovies(query: query, page: page))
    }
}

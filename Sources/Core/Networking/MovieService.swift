import Foundation

final class MovieService {
    func fetchTrending() async throws -> [MovieDTO] {
        let url = URL(string: "https://api.themoviedb.org/3/trending/movie/day")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(APIConfig.readAccessToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(MoviePageDTO.self, from: data).results
    }
}

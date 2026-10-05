import Foundation

enum APIConfig {
    static let baseURL = URL(string: "https://api.themoviedb.org/3")!
    static let imageBaseURL = URL(string: "https://image.tmdb.org/t/p")!

    static var readAccessToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDBAPIReadAccessToken") as? String,
              !token.isEmpty else {
            assertionFailure("Missing TMDB_API_READ_ACCESS_TOKEN — copy Config/Secrets.xcconfig.example to Config/Secrets.xcconfig and fill it in.")
            return ""
        }
        return token
    }
}

enum TMDBImageSize: String {
    case w185
    case w342
    case w500
    case original
}

extension String {
    func tmdbImageURL(size: TMDBImageSize) -> URL? {
        guard !isEmpty else { return nil }
        return APIConfig.imageBaseURL
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(self)
    }
}

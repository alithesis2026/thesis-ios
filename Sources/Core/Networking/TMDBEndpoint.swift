import Foundation

enum TMDBEndpoint {
    case popularMovies(page: Int)
    case movieDetail(id: Int)
    case searchMovies(query: String, page: Int)
    case genres

    var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .movieDetail(let id):
            return "/movie/\(id)"
        case .searchMovies:
            return "/search/movie"
        case .genres:
            return "/genre/movie/list"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .popularMovies(let page):
            return [URLQueryItem(name: "page", value: String(page))]
        case .movieDetail:
            return []
        case .searchMovies(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .genres:
            return []
        }
    }

    func makeURL(baseURL: URL) -> URL? {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }
}

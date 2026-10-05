import Foundation

protocol MovieListDataSource {
    func fetch(page: Int) async throws -> [Movie]
    func search(query: String, page: Int) async throws -> [Movie]
    func filter(by genreId: Int) -> [Movie]
    func sort(by criterion: String) -> [Movie]
    func paginate(currentPage: Int) -> Int
    func cache(movies: [Movie])
    func cachedMovies() -> [Movie]
    func refresh() async throws -> [Movie]
    func clearCache()
    func prefetchImages(for movies: [Movie])
    func markFavorite(_ movie: Movie)
    func unmarkFavorite(_ movie: Movie)
}

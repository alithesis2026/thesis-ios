import Foundation
import Combine
import CoreData

@MainActor
final class MovieListViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var favoriteMovieIds: Set<Int> = []

    private let tmdbService: TMDBServicing
    private var currentPage = 0
    private var totalPages = 1
    private var isFetching = false

    init(tmdbService: TMDBServicing) {
        self.tmdbService = tmdbService
    }

    func refreshFavoriteIds() {
        let request = FavoriteMovie.fetchRequest()
        let entities = (try? CoreDataStack.shared.viewContext.fetch(request)) ?? []
        favoriteMovieIds = Set(entities.map { Int($0.id) })
    }

    private var hasMorePages: Bool { currentPage < totalPages }

    func loadInitialPageIfNeeded() async {
        guard movies.isEmpty else { return }
        await loadNextPage()
    }

    func refresh() async {
        currentPage = 0
        totalPages = 1
        movies = []
        refreshFavoriteIds()
        await loadNextPage()
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentIndex >= movies.count - 5, hasMorePages, !isFetching else { return }
        Task { await loadNextPage() }
    }

    private func loadNextPage() async {
        guard !isFetching, currentPage == 0 || hasMorePages else { return }
        isFetching = true
        isLoading = currentPage == 0
        errorMessage = nil
        defer {
            isFetching = false
            isLoading = false
        }

        do {
            let response = try await tmdbService.popularMovies(page: currentPage + 1)
            movies.append(contentsOf: response.results.map { Movie(dto: $0) })
            currentPage = response.page
            totalPages = response.totalPages
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }
}

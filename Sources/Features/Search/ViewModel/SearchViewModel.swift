import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var queryText: String = ""
    @Published private(set) var results: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var sortByRating = false {
        didSet { applySorting() }
    }

    private let tmdbService: TMDBServicing
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var totalPages = 1
    private var isFetching = false
    private var activeQuery = ""
    private var unsortedResults: [Movie] = []

    init(tmdbService: TMDBServicing) {
        self.tmdbService = tmdbService

        $queryText
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                Task { await self?.search(query: text) }
            }
            .store(in: &cancellables)
    }

    private var hasMorePages: Bool { currentPage < totalPages }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentIndex >= results.count - 5, hasMorePages, !isFetching else { return }
        Task { await loadNextPage() }
    }

    private func search(query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        activeQuery = trimmedQuery
        currentPage = 0
        totalPages = 1
        unsortedResults = []
        applySorting()
        errorMessage = nil

        guard !trimmedQuery.isEmpty else { return }
        await loadNextPage()
    }

    private func applySorting() {
        results = sortByRating ? unsortedResults.sorted { $0.voteAverage > $1.voteAverage } : unsortedResults
    }

    private func loadNextPage() async {
        guard !isFetching, !activeQuery.isEmpty, currentPage == 0 || hasMorePages else { return }
        let query = activeQuery
        isFetching = true
        isLoading = currentPage == 0
        defer {
            isFetching = false
            isLoading = false
        }

        do {
            let response = try await tmdbService.searchMovies(query: query, page: currentPage + 1)
            guard query == activeQuery else { return }
            unsortedResults.append(contentsOf: response.results.map { Movie(dto: $0) })
            applySorting()
            currentPage = response.page
            totalPages = response.totalPages
        } catch let error as NetworkError {
            guard query == activeQuery else { return }
            errorMessage = error.userMessage
        } catch {
            guard query == activeQuery else { return }
            errorMessage = NetworkError.unknown.userMessage
        }
    }
}

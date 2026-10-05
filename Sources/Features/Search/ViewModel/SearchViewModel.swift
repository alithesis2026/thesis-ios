import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var queryText: String = ""
    @Published private(set) var results: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var recentQueries: [String] = UserDefaults.standard.stringArray(forKey: "search.recentQueries") ?? []

    private let tmdbService: TMDBServicing
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var totalPages = 1
    private var isFetching = false
    private var activeQuery = ""

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
        results = []
        errorMessage = nil

        guard !trimmedQuery.isEmpty else { return }
        recordRecentQuery(trimmedQuery)
        await loadNextPage()
    }

    private func recordRecentQuery(_ query: String) {
        var updated = recentQueries.filter { $0 != query }
        updated.insert(query, at: 0)
        recentQueries = Array(updated.prefix(5))
        UserDefaults.standard.set(recentQueries, forKey: "search.recentQueries")
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
            results.append(contentsOf: response.results.map { Movie(dto: $0) })
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

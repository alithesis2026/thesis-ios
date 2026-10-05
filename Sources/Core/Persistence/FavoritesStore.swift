import Foundation
import CoreData
import Combine

protocol FavoritesStoring {
    var favoritesChanged: AnyPublisher<Void, Never> { get }
    func isFavorite(movieId: Int) -> Bool
    func toggleFavorite(movie: Movie)
    func fetchAllFavorites() -> [Movie]
    func clearAll()
}

final class FavoritesStore: FavoritesStoring {
    private let context: NSManagedObjectContext
    private let changeSubject = PassthroughSubject<Void, Never>()

    var favoritesChanged: AnyPublisher<Void, Never> { changeSubject.eraseToAnyPublisher() }

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func isFavorite(movieId: Int) -> Bool {
        fetchEntity(id: movieId) != nil
    }

    func toggleFavorite(movie: Movie) {
        if let existing = fetchEntity(id: movie.id) {
            context.delete(existing)
        } else {
            let entity = FavoriteMovie(context: context)
            entity.id = Int64(movie.id)
            entity.title = movie.title
            entity.posterPath = movie.posterPath
            entity.voteAverage = movie.voteAverage
            entity.releaseDate = movie.releaseDate
            entity.addedAt = Date()
        }
        saveAndNotify()
    }

    func fetchAllFavorites() -> [Movie] {
        let request = FavoriteMovie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        guard let entities = try? context.fetch(request) else { return [] }
        return entities.map { entity in
            Movie(
                id: Int(entity.id),
                title: entity.title ?? "",
                overview: "",
                posterPath: entity.posterPath,
                backdropPath: nil,
                voteAverage: entity.voteAverage,
                releaseDate: entity.releaseDate
            )
        }
    }

    func clearAll() {
        let request = FavoriteMovie.fetchRequest()
        guard let entities = try? context.fetch(request) else { return }
        entities.forEach { context.delete($0) }
        saveAndNotify()
    }

    private func fetchEntity(id: Int) -> FavoriteMovie? {
        let request = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first
    }

    private func saveAndNotify() {
        do {
            try context.save()
            changeSubject.send()
        } catch {
            assertionFailure("Failed to save favorite: \(error)")
        }
    }
}

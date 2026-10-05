import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    init(modelName: String = "TMDBMovieApp", inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: modelName)
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
        persistentContainer.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data store failed to load: \(error)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
}

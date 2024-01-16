import CoreData
import OSLog

class CoreDataManager {
    private let persistentContainer: NSPersistentContainer

    private var mainManagedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// - Parameters:
    ///   - persistentContainer: NSPersistentContainer with loaded persistent stores.
    init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func saveContext() throws {
        guard mainManagedObjectContext.hasChanges else {
            return
        }

        try mainManagedObjectContext.save()
    }

    func rollbackContext() {
        mainManagedObjectContext.rollback()
    }

    func createManagedObject<T>(of type: T.Type) -> T where T: NSManagedObject {
        return T(context: mainManagedObjectContext)
    }

    func deleteManagedObject(_ object: NSManagedObject) {
        mainManagedObjectContext.delete(object)
    }

    func fetchedResultsController<T>(
        of type: T.Type,
        sortDescriptors: [NSSortDescriptor],
        sectionNameKeyPath: String? = nil
    ) -> NSFetchedResultsController<T> where T: NSManagedObject {
        guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else {
            fatalError()
        }
        fetchRequest.sortDescriptors = sortDescriptors

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: mainManagedObjectContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil
        )

        return fetchedResultsController
    }

    func object<T>(of type: T.Type, with managedObjectID: NSManagedObjectID) -> T? where T: NSManagedObject {
        guard let object = mainManagedObjectContext.object(with: managedObjectID) as? T else {
            fatalError()
        }

        return object
    }
}

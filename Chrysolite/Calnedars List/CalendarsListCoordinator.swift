import UIKit
import EventKit

protocol CalendarsListFlowCoordinatorProtocol: Coordinator {
    func showDetails(for calendar: EKCalendar)
}

class CalendarsListFlowCoordinator: CalendarsListFlowCoordinatorProtocol {
    var childCoordinators = [Coordinator]()
    
    var router: Router
    
    let eventStore: EKEventStore
    
    init(navigationController: UINavigationController, eventStore: EKEventStore) {
        router = Router(navigationController: navigationController)
        
        self.eventStore = eventStore
    }
    
    func start() {
        let viewModel = CalendarsViewModel(coordinator: self,
                                               calendarManager: .init(eventStore: eventStore),
                                               eventManager: .init(eventStore: eventStore))
        let viewController = CalendarsViewController(viewModel: viewModel)
        
        router.pushViewController(viewController, animated: false)
    }
    
    func showDetails(for calendar: EKCalendar) {
        let viewModel = CalendarDetailsViewModel(eventManager: .init(eventStore: eventStore),
                                                 calendar: calendar)
        let viewController = CalendarDetailsViewController(viewModel: viewModel)
        
        router.pushViewController(viewController)
    }
}

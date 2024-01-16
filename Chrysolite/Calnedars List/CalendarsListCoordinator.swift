import UIKit
import EventKit

class CalendarsFlowCoordinator: CalendarsFlowCoordinatorProtocol {
    var childCoordinators = [Coordinator]()
    
    var router: NavigationRouter
    
    let eventStore: EKEventStore
    
    init(navigationController: UINavigationController, eventStore: EKEventStore) {
        router = NavigationRouter(navigationController: navigationController)
        
        self.eventStore = eventStore
    }
    
    func start() {
        let viewModel = CalendarsViewModel(coordinator: self, calendarManager: .init(eventStore: eventStore), eventManager: .init(eventStore: eventStore))
        let viewController = CalendarsViewController(viewModel: viewModel)
        
        router.pushViewController(viewController, animated: false)
    }
    
    func showDetails(for calendar: EKCalendar) {
        let viewModel = CalendarDetailsViewModel(calendar: calendar, eventManager: .init(eventStore: eventStore))
        let viewController = CalendarDetailsViewController(viewModel: viewModel)
        
        router.pushViewController(viewController)
    }
}

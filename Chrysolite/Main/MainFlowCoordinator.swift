import UIKit
import EventKit

class MainFlowCoordinator: NSObject, MainFlowCoordinatorProtocol {
    var childCoordinators = [Coordinator]()
    
    var router: NavigationRouter
    
    var eventStore: EKEventStore
    
    init(navigationController: UINavigationController, eventStore: EKEventStore) {
        router = NavigationRouter(navigationController: navigationController)
        
        self.eventStore = eventStore
    }
    
    func start() {
        let viewModel = MainViewModel(coordinator: self, eventManager: .init(eventStore: eventStore))
        let viewController = MainViewController(viewModel: viewModel)
        
        router.pushViewController(viewController, animated: false)
    }
    
    func startCalendarsListFlow() {
        let navigationController = UINavigationController()
        navigationController.transitioningDelegate = self
        navigationController.modalPresentationStyle = .custom
        navigationController.modalTransitionStyle = .crossDissolve
        
        let coordinator = CalendarsFlowCoordinator(navigationController: navigationController, eventStore: eventStore)

        childCoordinators.append(coordinator)
        router.presentViewController(navigationController)
        coordinator.start()
    }
    
    func showDetails(for event: EKEvent) {
        let viewModel = EventDetailsViewModel(event: event, eventManager: .init(eventStore: eventStore))
        let viewController = EventDetailsViewController(viewModel: viewModel)
        
        router.pushViewController(viewController)
    }
}

extension MainFlowCoordinator: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

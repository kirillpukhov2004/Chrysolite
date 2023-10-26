import UIKit

class Router {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func presentViewController(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.present(viewController, animated: animated)
    }
    
    func dismissViewController(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
    
    func popToRootViewController(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }
}

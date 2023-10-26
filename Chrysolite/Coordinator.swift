import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get }
    var router: Router { get }
    
    func start()
}

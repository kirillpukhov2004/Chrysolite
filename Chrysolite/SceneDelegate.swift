import UIKit
import EventKit
import OSLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    var rootCoordinator: Coordinator!

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let eventStore = EKEventStore()
        
        Task {
            do {
                try await PermisionManager.requestFullAccessToEvents(with: eventStore)
                if PermisionManager.isFullAccessToEventsGranted {
                    Logger.general.log("Full access to events is granted")
                } else {
                    Logger.general.log("Full access to events isn't granted")
                }
            } catch {
                Logger.general.log("\(error.localizedDescription)")
            }
        }
        
        let navigationController = UINavigationController()
        
        rootCoordinator = MainFlowCoordinator(navigationController: navigationController, eventStore: eventStore)
        rootCoordinator.start()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

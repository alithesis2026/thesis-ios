import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let dependencyContainer = AppDependencyContainer()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootTabBarController(dependencyContainer: dependencyContainer)
        let storedMode = UserDefaults.standard.integer(forKey: AppearanceMode.storageKey)
        window.overrideUserInterfaceStyle = (AppearanceMode(rawValue: storedMode) ?? .system).userInterfaceStyle
        window.makeKeyAndVisible()
        self.window = window
    }
}

import UIKit

final class RootTabBarController: UITabBarController {
    private let dependencyContainer: AppDependencyContainer

    init(dependencyContainer: AppDependencyContainer) {
        self.dependencyContainer = dependencyContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [movieListTab(), searchTab(), favoritesTab(), settingsTab()]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMovieNotificationTap(_:)),
            name: .didTapMovieNotification,
            object: nil
        )
    }

    @objc private func handleMovieNotificationTap(_ notification: Notification) {
        guard let movieId = notification.userInfo?["movieId"] as? Int else { return }
        selectedIndex = 0
        guard let navigationController = viewControllers?.first as? UINavigationController else { return }
        navigationController.popToRootViewController(animated: false)
        let detailViewController = dependencyContainer.makeMovieDetailViewController(movieId: movieId)
        navigationController.pushViewController(detailViewController, animated: true)
    }

    private func movieListTab() -> UIViewController {
        let movieListViewController = dependencyContainer.makeMovieListViewController()
        movieListViewController.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "film"), tag: 0)
        return UINavigationController(rootViewController: movieListViewController)
    }

    private func searchTab() -> UIViewController {
        let searchViewController = dependencyContainer.makeSearchViewController()
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        return UINavigationController(rootViewController: searchViewController)
    }

    private func favoritesTab() -> UIViewController {
        let favoritesViewController = dependencyContainer.makeFavoritesViewController()
        favoritesViewController.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart"), tag: 2)
        return UINavigationController(rootViewController: favoritesViewController)
    }

    private func settingsTab() -> UIViewController {
        let settingsViewController = dependencyContainer.makeSettingsViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 3)
        return UINavigationController(rootViewController: settingsViewController)
    }
}

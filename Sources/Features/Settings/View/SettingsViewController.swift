import UIKit
import Combine
import CoreData

final class SettingsViewController: UITableViewController {
    private enum Row {
        case appearance
        case notifications
        case clearCache
        case resetData
        case about
    }

    private let sections: [(title: String, rows: [Row])] = [
        (title: "Görünüm", rows: [.appearance]),
        (title: "Bildirimler", rows: [.notifications]),
        (title: "Depolama", rows: [.clearCache, .resetData]),
        (title: "Hakkında", rows: [.about])
    ]

    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        viewModel.refreshCacheSize()

        viewModel.$cacheSizeDescription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section].rows[indexPath.row] {
        case .appearance:
            return appearanceCell()
        case .notifications:
            return notificationsCell()
        case .clearCache:
            return clearCacheCell()
        case .resetData:
            return resetDataCell()
        case .about:
            return aboutCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section].rows[indexPath.row] {
        case .clearCache:
            viewModel.clearImageCache()
        case .resetData:
            resetAllAppData()
        default:
            break
        }
    }

    private func resetAllAppData() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")

        let context = CoreDataStack.shared.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        try? context.save()

        viewModel.clearImageCache()

        let alert = UIAlertController(title: "Tamamlandı", message: "Tüm uygulama verileri sıfırlandı.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    private func appearanceCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.text = "Tema"

        let segmentedControl = UISegmentedControl(items: AppearanceMode.allCases.map(\.title))
        segmentedControl.selectedSegmentIndex = viewModel.appearanceMode.rawValue
        segmentedControl.addAction(UIAction { [weak self] _ in
            guard let self, let mode = AppearanceMode(rawValue: segmentedControl.selectedSegmentIndex) else { return }
            self.viewModel.appearanceMode = mode
            self.view.window?.overrideUserInterfaceStyle = mode.userInterfaceStyle
        }, for: .valueChanged)

        cell.accessoryView = segmentedControl
        return cell
    }

    private func notificationsCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.text = "Bildirimlere izin ver"

        let toggle = UISwitch()
        toggle.isOn = viewModel.notificationsEnabled
        toggle.addAction(UIAction { [weak self] _ in
            self?.viewModel.notificationsEnabled = toggle.isOn
            if toggle.isOn {
                NotificationPermissionManager.shared.requestAuthorizationIfNeeded()
            }
        }, for: .valueChanged)

        cell.accessoryView = toggle
        return cell
    }

    private func clearCacheCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Görsel önbelleğini temizle"
        cell.textLabel?.textColor = .systemRed
        cell.detailTextLabel?.text = viewModel.cacheSizeDescription
        return cell
    }

    private func resetDataCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Tüm verileri sıfırla"
        cell.textLabel?.textColor = .systemRed
        return cell
    }

    private func aboutCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.text = "Sürüm"
        cell.detailTextLabel?.text = viewModel.appVersionDescription
        return cell
    }
}

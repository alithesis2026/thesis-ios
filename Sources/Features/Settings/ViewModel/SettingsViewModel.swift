import Foundation
import UIKit
import Kingfisher

enum AppearanceMode: Int, CaseIterable {
    static let storageKey = "settings.appearanceMode"

    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: return "Sistem"
        case .light: return "Açık"
        case .dark: return "Koyu"
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: Keys.appearanceMode) }
    }
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }
    @Published private(set) var cacheSizeDescription = "Hesaplanıyor…"

    private enum Keys {
        static let appearanceMode = AppearanceMode.storageKey
        static let notificationsEnabled = "settings.notificationsEnabled"
    }

    var appVersionDescription: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }

    init() {
        let storedMode = UserDefaults.standard.integer(forKey: Keys.appearanceMode)
        appearanceMode = AppearanceMode(rawValue: storedMode) ?? .system
        notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
    }

    func refreshCacheSize() {
        ImageCache.default.calculateDiskStorageSize { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let size):
                    self?.cacheSizeDescription = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
                case .failure:
                    self?.cacheSizeDescription = "-"
                }
            }
        }
    }

    func clearImageCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache { [weak self] in
            self?.refreshCacheSize()
        }
    }
}

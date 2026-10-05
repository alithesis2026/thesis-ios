import Foundation

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    func track(_ event: String, parameters: [String: Any] = [:]) {
        print("[Analytics] \(event) \(parameters)")
    }
}

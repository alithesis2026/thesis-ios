import Foundation

enum DateFormatterHelper {
    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    static func displayString(fromAPIDate apiDate: String) -> String {
        guard let date = apiDateFormatter.date(from: apiDate) else { return apiDate }
        return displayDateFormatter.string(from: date)
    }
}

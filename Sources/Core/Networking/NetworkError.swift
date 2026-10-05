import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case noConnection
    case unknown

    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Geçersiz istek."
        case .requestFailed(let statusCode):
            return "Sunucu hatası (\(statusCode))."
        case .decodingFailed:
            return "Veri işlenemedi."
        case .noConnection:
            return "İnternet bağlantısı yok."
        case .unknown:
            return "Beklenmeyen bir hata oluştu."
        }
    }
}

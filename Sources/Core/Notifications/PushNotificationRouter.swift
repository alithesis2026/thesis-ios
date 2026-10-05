import Foundation

extension Notification.Name {
    static let didTapMovieNotification = Notification.Name("didTapMovieNotification")
}

enum PushNotificationPayloadKey {
    static let movieId = "movie_id"
}

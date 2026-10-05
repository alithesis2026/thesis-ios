import UIKit

final class LimitedImageDownloader {
    static let shared = LimitedImageDownloader()

    private let maxConcurrentDownloads = 4
    private var activeDownloads = 0
    private let queue = DispatchQueue(label: "com.tmdb.imagedownloader")

    private init() {}

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        queue.async {
            guard self.activeDownloads < self.maxConcurrentDownloads else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.downloadImage(from: url, completion: completion)
                }
                return
            }
            self.activeDownloads += 1
            URLSession.shared.dataTask(with: url) { data, _, _ in
                self.queue.async { self.activeDownloads -= 1 }
                let image = data.flatMap { UIImage(data: $0) }
                DispatchQueue.main.async { completion(image) }
            }.resume()
        }
    }
}

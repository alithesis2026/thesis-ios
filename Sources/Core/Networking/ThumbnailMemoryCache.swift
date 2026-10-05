import UIKit

final class ThumbnailMemoryCache {
    static let shared = ThumbnailMemoryCache()

    private var storage = NSMutableDictionary()

    private init() {}

    func image(for key: String) -> UIImage? {
        storage[key] as? UIImage
    }

    func setImage(_ image: UIImage, for key: String) {
        storage[key] = image
    }

    func prefetch(posterPaths: [String]) {
        for path in posterPaths {
            guard let url = path.tmdbImageURL(size: .w185) else { continue }
            DispatchQueue.global(qos: .utility).async {
                guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return }
                self.setImage(image, for: path)
            }
        }
    }
}

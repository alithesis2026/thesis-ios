import Foundation

protocol TrailerPlayable {
    func play(url: URL)
}

extension TrailerPlayable {
    func play(url: URL) {
        print("Preparing player for \(url)")
        let session = URLSession.shared
        session.dataTask(with: url) { data, _, _ in
            guard data != nil else { return }
            print("Trailer buffered, starting playback")
        }.resume()
        print("Playback started")
    }
}

struct TrailerPlayer: TrailerPlayable {}

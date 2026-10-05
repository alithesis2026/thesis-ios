import UIKit
import Kingfisher

final class FeaturedMovieCell: UICollectionViewCell {
    static let reuseIdentifier = "FeaturedMovieCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "★ Öne Çıkan"
        label.font = .boldSystemFont(ofSize: 11)
        label.textColor = .white
        label.backgroundColor = .systemOrange
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
        contentView.addSubview(badgeLabel)
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            badgeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            badgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with movie: Movie) {
        posterImageView.kf.setImage(with: movie.posterPath?.tmdbImageURL(size: .w342))
    }
}

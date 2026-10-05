import UIKit
import Kingfisher

final class MovieListCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieListCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 2
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        titleLabel.isAccessibilityElement = true
        ratingLabel.text = String(format: "★ %.1f", movie.voteAverage)
        ratingLabel.isAccessibilityElement = true
        posterImageView.kf.setImage(with: movie.posterPath?.tmdbImageURL(size: .w342))
    }

    private func setUpLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, ratingLabel])
        stack.axis = .vertical
        stack.spacing = 2

        contentView.addSubview(posterImageView)
        contentView.addSubview(stack)

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),

            stack.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
}

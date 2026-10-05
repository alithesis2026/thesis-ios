import UIKit
import Kingfisher

protocol SearchResultCellDelegate: AnyObject {
    func searchResultCellDidTapFavorite(_ cell: SearchResultCell)
}

final class SearchResultCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchResultCell"

    weak var delegate: SearchResultCellDelegate?

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(handleFavoriteTap), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
        contentView.addSubview(favoriteButton)
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with movie: Movie) {
        posterImageView.kf.setImage(with: movie.posterPath?.tmdbImageURL(size: .w342))
    }

    @objc private func handleFavoriteTap() {
        delegate?.searchResultCellDidTapFavorite(self)
    }
}

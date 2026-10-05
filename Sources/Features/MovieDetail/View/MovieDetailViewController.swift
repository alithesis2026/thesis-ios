import UIKit
import Combine
import Kingfisher

final class MovieDetailViewController: UIViewController {
    private let viewModel: MovieDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.numberOfLines = 0
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private lazy var favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(handleFavoriteTapped))
    var dateFormatter = DateFormatter()

    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = favoriteButton
        setUpLayout()
        bindViewModel()

        Task { await viewModel.load() }
    }

    private func setUpLayout() {
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        scrollView.addSubview(contentStack)

        [backdropImageView, titleLabel, metaLabel, taglineLabel, overviewLabel].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(4, after: titleLabel)

        [scrollView, contentStack, activityIndicator, backdropImageView, titleLabel, metaLabel, taglineLabel, overviewLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let contentInset: CGFloat = 16
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -contentInset),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            backdropImageView.heightAnchor.constraint(equalTo: backdropImageView.widthAnchor, multiplier: 0.56),

            titleLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: contentInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -contentInset),
            metaLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: contentInset),
            metaLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -contentInset),
            taglineLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: contentInset),
            taglineLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -contentInset),
            overviewLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: contentInset),
            overviewLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -contentInset),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$detail
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                self?.configure(with: detail)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.presentError(message: message)
            }
            .store(in: &cancellables)

        viewModel.$isFavorite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                self?.favoriteButton.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
            }
            .store(in: &cancellables)
    }

    private func configure(with detail: MovieDetailDTO) {
        title = detail.title
        titleLabel.text = detail.title
        taglineLabel.text = detail.tagline
        taglineLabel.isHidden = detail.tagline?.isEmpty ?? true
        overviewLabel.text = detail.overview

        var metaParts: [String] = [String(format: "★ %.1f", detail.voteAverage)]
        if let releaseDate = detail.releaseDate, !releaseDate.isEmpty {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let parsedDate = dateFormatter.date(from: releaseDate) {
                dateFormatter.dateStyle = .medium
                dateFormatter.dateFormat = nil
                metaParts.append(dateFormatter.string(from: parsedDate))
            } else {
                metaParts.append(releaseDate)
            }
        }
        if let runtime = detail.runtime {
            metaParts.append("\(runtime) dk")
        }
        if !detail.genres.isEmpty {
            metaParts.append(detail.genres.map(\.name).joined(separator: ", "))
        }
        metaLabel.text = metaParts.joined(separator: " · ")

        backdropImageView.kf.setImage(with: (detail.backdropPath ?? detail.posterPath)?.tmdbImageURL(size: .w500))
    }

    @objc private func handleFavoriteTapped() {
        viewModel.toggleFavorite()
    }

    private func presentError(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

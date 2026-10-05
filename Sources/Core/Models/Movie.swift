import Foundation

struct Movie: Identifiable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?

    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        releaseDate: String?
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
    }

    init(dto: MovieDTO) {
        id = dto.id
        title = dto.title
        overview = dto.overview
        posterPath = dto.posterPath
        backdropPath = dto.backdropPath
        voteAverage = dto.voteAverage
        releaseDate = dto.releaseDate
    }

    init(detail: MovieDetailDTO) {
        id = detail.id
        title = detail.title
        overview = detail.overview
        posterPath = detail.posterPath
        backdropPath = detail.backdropPath
        voteAverage = detail.voteAverage
        releaseDate = detail.releaseDate
    }
}

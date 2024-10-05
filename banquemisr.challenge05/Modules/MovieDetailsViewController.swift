//
//  MovieDetailsViewController.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var backdropPathImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var ageRatingLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var originalLanguageLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var totalVoteLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var popularityDetailsLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    // MARK: - Properties
    var movieID: Int?
    var movie: Movie?
    var movieImages:Data?

    var networkManager: NetworkManagerProtocol?
    var connectivityManager: ConnectivityManagerProtocol?
    var coreDataManager: MovieCoreDataServiceProtocol?


    // MARK: - Initialization
    required init?(coder: NSCoder) {
        networkManager = NetworkManager()
        connectivityManager = ConnectivityManager()
        coreDataManager = MovieCoreDataManager.shared
        super.init(coder: coder)
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        loadDataFromApi()
        configureUIDesign()
    }

    // MARK: - Data Loading
    private func loadDataFromApi() {
        guard let movieID = movieID else { return }
        let responseType = Movie.self

        networkManager?.fetchData(from: .details(id: movieID), responseType: responseType) { [weak self] result in
            guard let movie = result else {
                // Handle error here, e.g., show an alert or a placeholder view
                return
            }
            DispatchQueue.main.async {
                self?.movie = movie
                self?.setupUI()
            }
        }
    }
    private func loadCoreData() {

    }

    private func loadData() {
        showLoadingIndicator()
        connectivityManager?.checkInternetConnection {[weak self] state in
                self?.hideLoadingIndicator()
                if state {
                    self?.loadDataFromApi()
                } else {
                    DispatchQueue.main.async {
                        self?.showNoInternetAlert()
                        self?.loadCoreData()
                    }
                }

            }

        }


    // MARK: - UI Configuration
    private func configureUIDesign() {
        ageRatingLabel.layer.cornerRadius = 5
        ageRatingLabel.layer.borderWidth = 2
        ageRatingLabel.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func setupUI() {
        guard let movie = movie else { return }
        let (popularityCategory, popularityDetails) = calculatePopularity(movie.popularity)

        // Populate UI elements with movie data
        titleLabel.text = movie.title
        taglineLabel.text = movie.tagline
        genresLabel.text = formattedGenres(movie.genres)
        ageRatingLabel.text = movie.adult ? "+18" : "PG"
        voteAverageLabel.text = formattedVoteAverage(movie.voteAverage)
        originalLanguageLabel.text = movie.originalLanguage.capitalized
        releaseDateLabel.text = "🗓️ \(movie.releaseDate)"
        durationLabel.text = calculateRuntime(movie.runtime ?? 0)
        budgetLabel.text = formattedAmount(movie.budget ?? 0)
        revenueLabel.text = formattedAmount(movie.revenue ?? 0)
        totalVoteLabel.text = "\(movie.voteCount)"
        popularityLabel.text = popularityCategory
        popularityDetailsLabel.text = popularityDetails
        overviewLabel.text = movie.overview

        loadBackdropImage()
    }

    // MARK: - Helper Methods
    private func calculateRuntime(_ totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "🕔\(hours)h \(minutes)m"
    }

    private func calculatePopularity(_ popularityScore: Double) -> (String, String) {
        let roundedPopularity = Int(popularityScore)
        let popularityCategory: String
        let popularityDetails: String

        switch roundedPopularity {
        case let score where score > 1000:
            popularityCategory = "High"
            popularityDetails = "This movie is trending and is among the most popular choices among viewers."
        case let score where score > 500:
            popularityCategory = "Moderate"
            popularityDetails = "This movie has a decent following and is gaining interest."
        default:
            popularityCategory = "Low"
            popularityDetails = "This movie is not widely watched and may be less popular."
        }

        return ("\(roundedPopularity) - \(popularityCategory)", popularityDetails)
    }

    private func formattedVoteAverage(_ voteAverage: Double) -> String {
        return voteAverage != 0.0
            ? "★ \(String(format: "%0.1f", voteAverage))"
            : "No Rating Yet"
    }

    private func formattedGenres(_ genres: [Genre]?) -> String {
        return genres?.map { $0.name }.joined(separator: " | ") ?? "No Genres Available"
    }

    private func formattedAmount(_ amountText: Int) -> String {
        return amountText > 0
            ? String(format: "%d$", locale: Locale.current, amountText)
            : "Not available"
    }

    // MARK: - Image Loading
    private func loadBackdropImage() {
        guard let backdropPath = movie?.backdropPath else { return }

        networkManager?.loadImage(from: backdropPath) { [weak self] data in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.backdropPathImage.image = UIImage(data: data)
            }
        }
    }
}

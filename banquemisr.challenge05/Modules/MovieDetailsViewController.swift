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
    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Properties
    var movieID: Int?
    var movie: Movie?
    var movieImage: Data?
    var connectionState: Bool?

    var networkManager: NetworkManagerProtocol?
    var connectivityManager: ConnectivityManagerProtocol?
    var coreDataManager: MovieCoreDataServiceProtocol?
    private let refreshControl = UIRefreshControl()

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
        configureUIDesign()
        setupRefreshControl()
        loadData()
    }

    // MARK: - UI Configuration
    private func configureUIDesign() {
        ageRatingLabel.layer.cornerRadius = 5
        ageRatingLabel.layer.borderWidth = 2
        ageRatingLabel.layer.borderColor = UIColor.lightGray.cgColor
    }

    // MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: Constants.PullToRefresh)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }

    // MARK: - Pull to Refresh Action
    @objc private func didPullToRefresh() {
        loadData()
    }

    // MARK: - Data Loading
    private func loadData() {
        showLoadingIndicator(view)
        connectivityManager?.checkInternetConnection { [weak self] state in
            guard let self = self else { return }
            self.connectionState = state
            if state {
                self.loadDataFromApi()
            } else {
                DispatchQueue.main.async {
                    self.showNoInternetAlert()
                    self.hideLoadingIndicator(self.view)
                    self.loadCoreData()
                }
            }
        }
    }

    // MARK: - Load Data from API
    private func loadDataFromApi() {
        defer { self.refreshControl.endRefreshing() }
        guard let movieID = movieID else { return }
        let responseType = Movie.self

        networkManager?.fetchData(from: .details(id: movieID), responseType: responseType) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.view.displayEmptyMessage(error)
                return
            }
            guard let movie = result else { return }

            DispatchQueue.main.async {
                self.movie = movie
                self.setupUI()
                self.coreDataManager?.updateMovie(withId: movieID, updatedMovie: movie)
                self.hideLoadingIndicator(self.view)
            }
        }
    }
    // MARK: - Load Data from Core Data
    private func loadCoreData() {
        defer { self.refreshControl.endRefreshing() }
        guard let movieID = movieID, let movie = coreDataManager?.getMovie(forMovieWithId: movieID) else {
            self.view.displayEmptyMessage(DataError.noCoreDataAvailable)
            return
        }
        if movie.0 == nil {
            self.view.displayEmptyMessage(DataError.noCachedDataFound)
        } else {
            self.movie = movie.0
            self.movieImage = movie.1
            setupUI()
        }
    }

    // MARK: - Setup UI with Movie Data
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
        showLoadingIndicator(backdropPathImage)

        if connectionState == true {
            guard let movieID = movieID, let backdropPath = movie?.backdropPath else {
                hideLoadingIndicator(backdropPathImage)
                backdropPathImage.displayEmptyMessage(DataError.dataCorruption)
                return
            }

            networkManager?.loadImage(from: backdropPath) { [weak self] data in
                guard let self = self else { return }
                self.hideLoadingIndicator(self.backdropPathImage)

                guard let imageData = data else {
                    self.backdropPathImage.displayEmptyMessage(APIError.responseMalformed)
                    return
                }

                DispatchQueue.main.async {
                    self.backdropPathImage.image = UIImage(data: imageData)
                    self.coreDataManager?.storeMovieImage(imageData, forMovieWithId: movieID, imageType: .backdrop)
                }
            }
        } else {
            hideLoadingIndicator(backdropPathImage)
            if let movieImage = movieImage {
                backdropPathImage.image = UIImage(data: movieImage)
            } else {
                backdropPathImage.displayEmptyMessage(DataError.noCachedDataFound)
            }
        }
    }
}

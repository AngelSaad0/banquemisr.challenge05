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
    @IBOutlet var movieInfoStack: UIStackView!
    
    // MARK: - Properties
    private let refreshControl = UIRefreshControl()
    let viewModel: MovieDetailsViewModel!

    // MARK: - Initialization
    required init?(coder: NSCoder) {
        viewModel = MovieDetailsViewModel()
        super.init(coder: coder)
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIDesign()
        setupRefreshControl()
        setupViewModel()
        viewModel.loadData()
    }

    // MARK: - UI Configuration
    private func configureUIDesign() {
        movieInfoStack.isHidden = true
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
        viewModel.loadData()
    }

    // MARK: - Setup View Model
    func setupViewModel() {
        viewModel.setLoadingIndicator = { state in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                state ? self.showLoadingIndicator(self.view) : self.hideLoadingIndicator(self.view)
            }
        }
        viewModel.showNoInternetAlert = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showNoInternetAlert()
            }
        }
        viewModel.endRefreshControl = {
            self.refreshControl.endRefreshing()
        }
        viewModel.displayEmptyMessage = { message in
            self.view.displayEmptyMessage(message)
        }
        viewModel.removeEmptyMessage = {
            self.view.removeEmptyMessage()
        }
        viewModel.setupUI = {
            DispatchQueue.main.async { [weak self] in
                self?.setupUI()
            }
        }
        viewModel.setImageLoadingIndicator = { state in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                state ? self.showLoadingIndicator(self.backdropPathImage) : self.hideLoadingIndicator(self.backdropPathImage)
            }
        }
        viewModel.displayImageEmptyMessage = { message in
            self.backdropPathImage.displayEmptyMessage(message)
        }
        viewModel.removeImageEmptyMessage = {
            self.backdropPathImage.removeEmptyMessage()
        }
        viewModel.setBackdropImage = { [weak self] imageData in
            DispatchQueue.main.async {
                self?.backdropPathImage.image = UIImage(data: imageData)
            }
        }
    }
    
    // MARK: - Setup UI with Movie Data
    private func setupUI() {
        movieInfoStack.isHidden = false
        view.removeEmptyMessage()
        guard let movie = viewModel.movie else { return }

        let (popularityCategory, popularityDetails) = viewModel.calculatePopularity(movie.popularity)
        // Populate UI elements with movie data
        titleLabel.text = movie.title
        taglineLabel.text = movie.tagline
        genresLabel.text = viewModel.formattedGenres(movie.genres)
        ageRatingLabel.text = movie.adult ? "+18" : "PG"
        voteAverageLabel.text = viewModel.formattedVoteAverage(movie.voteAverage)
        originalLanguageLabel.text = movie.originalLanguage.capitalized
        releaseDateLabel.text = "🗓️ \(movie.releaseDate)"
        durationLabel.text = viewModel.calculateRuntime(movie.runtime ?? 0)
        budgetLabel.text = viewModel.formattedAmount(movie.budget ?? 0)
        revenueLabel.text = viewModel.formattedAmount(movie.revenue ?? 0)
        totalVoteLabel.text = "\(movie.voteCount)"
        popularityLabel.text = popularityCategory
        popularityDetailsLabel.text = popularityDetails
        overviewLabel.text = movie.overview
        viewModel.loadBackdropImage()
    }

    func hideLoadingIndicatorForImage () {
        DispatchQueue.main.async {
            self.hideLoadingIndicator(self.backdropPathImage)
        }
    }
}

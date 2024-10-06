//
//  MovieDetailsViewModel.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/5/24.
//

import Foundation
class MovieDetailsViewModel {

    // MARK: - Properties
    var movieID: Int?
    var movie: Movie?
    var movieImage: Data?
    var connectionState: Bool?
    var connectivityManager: ConnectivityManagerProtocol?
    var coreDataManager: MovieCoreDataServiceProtocol?
    var fetchMovieDetailsUseCase: FetchMoviesUseCaseProtocol?
    var loadBackdropImageUseCase: LoadMovieImageUseCaseProtocol?
    
    // MARK: - Closures
    var setLoadingIndicator: (Bool) -> Void = {_ in}
    var showNoInternetAlert: () -> Void = {}
    var endRefreshControl: () -> Void = {}
    var displayEmptyMessage: (any LocalizedError) -> Void = {_ in}
    var removeEmptyMessage: () -> Void = {}
    var setupUI: () -> Void = {}
    var setImageLoadingIndicator: (Bool) -> Void = {_ in}
    var displayImageEmptyMessage: (any LocalizedError) -> Void = {_ in}
    var removeImageEmptyMessage: () -> Void = {}
    var setBackdropImage: (Data) -> Void = {_ in}
    
    // MARK: - Initializer
    init() {
        fetchMovieDetailsUseCase = FetchMoviesUseCase()
        loadBackdropImageUseCase = LoadMovieImageUseCase()
        connectivityManager = ConnectivityManager()
        coreDataManager = MovieCoreDataManager.shared
    }
    
    // MARK: - Data Loading
    func loadData() {
        setLoadingIndicator(true)
        removeEmptyMessage()
        connectivityManager?.checkInternetConnection { [weak self] state in
            guard let self = self else { return }
            self.connectionState = state
            if state {
                self.loadDataFromApi()
            } else {
                self.setLoadingIndicator(false)
                self.showNoInternetAlert()
                self.loadCoreData()
            }
        }
    }

    // MARK: - Load Data from API
    private func loadDataFromApi() {
        defer { self.endRefreshControl() }
        guard let movieID = movieID else { return }
        let responseType = Movie.self

        fetchMovieDetailsUseCase?.execute(from: .details(id: movieID), responseType: responseType) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movie):
                self.movie = movie
                self.setupUI()
                DispatchQueue.main.async {
                    self.coreDataManager?.updateMovie(withId: movieID, updatedMovie: movie)
                }
                self.setLoadingIndicator(false)
            case .failure(let error):
                self.displayEmptyMessage(error)
                self.setLoadingIndicator(false)
            }
        }
    }
    
    // MARK: - Load Data from Core Data
    private func loadCoreData() {
        defer { endRefreshControl() }
        guard let movieID = movieID, let movie = coreDataManager?.getMovie(forMovieWithId: movieID) else {
            self.displayEmptyMessage(DataError.noCoreDataAvailable)
            return
        }
        if movie.0 == nil {
            self.displayEmptyMessage(DataError.noCachedDataFound)
        } else {
            self.movie = movie.0
            self.movieImage = movie.1
            setupUI()
        }
    }

    // MARK: - Image Loading
    func loadBackdropImage() {
        setImageLoadingIndicator(true)
        removeImageEmptyMessage()
        
        if connectionState == true {
            guard let movieID = movieID, let backdropPath = movie?.backdropPath else {
                setImageLoadingIndicator(false)
                displayImageEmptyMessage(DataError.dataCorruption)
                return
            }
            loadBackdropImageUseCase?.execute(imageUrl: backdropPath) { [weak self] result in
                guard let self = self else { return }
                self.setImageLoadingIndicator(false)
                switch result {
                case .success(let imageData):
                    DispatchQueue.main.async {
                        self.setBackdropImage(imageData)
                        self.coreDataManager?.storeMovieImage(imageData, forMovieWithId: movieID, imageType: .backdrop)
                    }
                case .failure(let error):
                    self.displayImageEmptyMessage(error)
                }
            }
        } else {
            setImageLoadingIndicator(false)
            if let movieImage = movieImage {
                setBackdropImage(movieImage)
            } else {
                displayImageEmptyMessage(DataError.noCachedDataFound)
            }
        }
    }

    // MARK: - Helper Methods
    func calculateRuntime(_ totalMinutes: Int) -> String {
        if totalMinutes == 0 {
            return "⏲️ Currently not available"
        }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "🕔\(hours)h \(minutes)m"
    }

    func calculatePopularity(_ popularityScore: Double) -> (String, String) {
        let roundedPopularity = Int(popularityScore)
        let popularityCategory: String
        let popularityDetails: String
        switch roundedPopularity {
        case 0 :
            return ("Not Available", "")
        case let score where score > 1000:
            popularityCategory = "High"
            popularityDetails = Constants.highPopularity
        case let score where score > 500:
            popularityCategory = "Moderate"
            popularityDetails = Constants.moderatePopularity
        default:
            popularityCategory = "Low"
            popularityDetails = Constants.lowPopularity
        }
        return ("\(roundedPopularity) - \(popularityCategory)", popularityDetails)
    }

    func formattedVoteAverage(_ voteAverage: Double) -> String {
        return voteAverage != 0.0
        ? "★ \(String(format: "%0.1f", voteAverage))"
        : "No Rating Yet"
    }

    func formattedGenres(_ genres: [Genre]?) -> String {
        return genres?.map { $0.name }.joined(separator: " | ") ?? "No Genres Available"
    }

    func formattedAmount(_ amountText: Int) -> String {
        return amountText > 0
        ? String(format: "%d$💰", locale: Locale.current, amountText)
        : "Not available"
    }
}

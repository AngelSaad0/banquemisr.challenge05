//
//  MoviesViewModel.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/5/24.
//

import Foundation

class MoviesViewModel {
    // MARK: - Properties
    var navigationTitle: String?
    var moviesCategory: MovieAPIProvider?
    var movieList: [Movie] = []
    var movieImages: [Data?] = []
    var connectivityManager: ConnectivityManagerProtocol?
    var coreDataManager: MovieCoreDataServiceProtocol?
    var fetchMoviesUseCase: FetchMoviesUseCaseProtocol?
    
    // MARK: - Initializer
    init() {
        fetchMoviesUseCase = FetchMoviesUseCase()
        connectivityManager = ConnectivityManager()
        coreDataManager = MovieCoreDataManager.shared
    }
    
    // MARK: - Closures
    var setLoadingIndicator: (Bool) -> Void = { _ in }
    var showNoInternetAlert: () -> Void = {}
    var endRefreshControl: () -> Void = {}
    var displayEmptyMessage: (any LocalizedError) -> Void = { _ in }
    var removeEmptyMessage: () -> Void = {}
    var bindDataToTableView: () -> Void = {}
    
    // MARK: - Data Loading
    func loadData() {
        removeEmptyMessage()
        setLoadingIndicator(true)
        
        connectivityManager?.checkInternetConnection { [weak self] state in
            guard let self = self else { return }
            
            if state {
                self.loadDataFromNetwork()
            } else {
                self.showNoInternetAlert()
                self.setLoadingIndicator(false)
                self.loadCoreData()
            }
        }
    }
    
    // MARK: - Data Loading from Network
    private func loadDataFromNetwork() {
        defer {
            self.endRefreshControl()
        }
        
        guard let movieUrl = moviesCategory else {
            setLoadingIndicator(false)
            displayEmptyMessage(DataError.unknownError)
            return
        }
        
        fetchMoviesUseCase?.execute(from: movieUrl, responseType: Movies.self) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setLoadingIndicator(false)
            }
            
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self.movieList = movies.results
                    self.bindDataToTableView()
                    self.storeMoviesInCoreData(movies: movies.results)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.displayEmptyMessage(error)
                }
            }
        }
    }
    
    // MARK: - Data Loading from Core Data
    private func loadCoreData() {
        defer {
            self.endRefreshControl()
        }
        
        guard let movies = coreDataManager?.getMovies(category: moviesCategory!) else {
            displayEmptyMessage(DataError.noCoreDataAvailable)
            return
        }
        
        if movies.0.isEmpty {
            displayEmptyMessage(DataError.noCachedDataFound)
        } else {
            self.movieList = movies.0
            self.movieImages = movies.1
            bindDataToTableView()
        }
    }
    
    // MARK: - Store Movies in Core Data
    private func storeMoviesInCoreData(movies: [Movie]) {
        guard let coreDataManager = coreDataManager, let moviesCategory = moviesCategory else {
            return
        }
        coreDataManager.storeMovies(movies: movies, category: moviesCategory)
    }
}

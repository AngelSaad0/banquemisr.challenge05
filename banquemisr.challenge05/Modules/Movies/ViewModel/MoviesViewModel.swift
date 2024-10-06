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
    var networkManager: NetworkManagerProtocol
    var connectivityManager: ConnectivityManagerProtocol?
    var coreDataManager: MovieCoreDataServiceProtocol?
    
    // MARK: - Initializer
    init() {
        networkManager = NetworkManager()
        connectivityManager = ConnectivityManager()
        coreDataManager = MovieCoreDataManager.shared
    }
    
    // MARK: - Closures
    var setLoadingIndicator: (Bool) -> Void = {_ in}
    var showNoInternetAlert: () -> Void = {}
    var endRefreshControl: () -> Void = {}
    var displayEmptyMessage: (any LocalizedError) -> Void = {_ in}
    var removeEmptyMessage: () -> Void = {}
    var bindDataToTableView: () -> Void = {}
    
    // MARK: - Data Loading
    func loadData() {
        removeEmptyMessage()
        setLoadingIndicator(true)
        connectivityManager?.checkInternetConnection {[weak self] state in
            guard let self = self else {return}
            if state {
                self.loadDataFromNetwork()
            } else {
                self.showNoInternetAlert()
                self.setLoadingIndicator(false)
                self.loadCoreData()
            }
        }
    }
    
    // MARK: -  Data Loading from Network
    private func loadDataFromNetwork() {
        defer {
            self.endRefreshControl()
        }
        guard let movieUrl = moviesCategory else {
            self.setLoadingIndicator(false)
            self.displayEmptyMessage(DataError.unknownError)
            
            return
        }
        let responseType = Movies.self
        networkManager.fetchData(from: movieUrl, responseType: responseType) { [weak self] result, error in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.setLoadingIndicator(false)
            }
            if let error = error {
                self.displayEmptyMessage(error)
            }
            guard let movies = result else {
                self.displayEmptyMessage(APIError.responseMalformed)
                return
            }
            DispatchQueue.main.async {
                self.movieList = movies.results
                self.bindDataToTableView()
                if let coreDataManager = self.coreDataManager,let moviesCategory = self.moviesCategory {
                    coreDataManager.storeMovies(movies: movies.results, category: moviesCategory)
                }
            }
        }
    }
    
    // MARK: -  Data Loading from Core Data
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
}

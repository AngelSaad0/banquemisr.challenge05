//
//  MoviesViewController.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import UIKit

class MoviesViewController: UIViewController {

    // MARK: IBOutlet
    @IBOutlet weak var moviesTableView: UITableView!

    // MARK: Properties
    var navigationTitle: String?
    var moviesCategory: MovieAPIProvider?
    var movieList: [Movie] = []
    var movieImages: [Data?] = []

    private let refreshControl = UIRefreshControl()
    var networkManager: NetworkManagerProtocol
    var connectivityManager: ConnectivityManagerProtocol?
    var coreDataManager: MovieCoreDataServiceProtocol?

    // MARK: Initalization
    required init?(coder: NSCoder) {
        networkManager = NetworkManager()
        connectivityManager = ConnectivityManager()
        coreDataManager = MovieCoreDataManager.shared
        super.init(coder: coder)
    }

    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = navigationTitle
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
    }

    // MARK: - Refresh Control Setup
    private func setupRefreshControl() {
        moviesTableView.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string:Constants.PullToRefresh )
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    // MARK: - Pull to Refresh Action
    @objc private func didPullToRefresh() {
        loadData()
    }
    // MARK: -  Data Loading
    private func loadData() {
        moviesTableView.removeEmptyMessage()
        showLoadingIndicator(view)
        connectivityManager?.checkInternetConnection {[weak self] state in
            guard let self = self else {return}
            if state {
                self.loadDataFromNetwork()
            } else {
                DispatchQueue.main.async {
                    self.showNoInternetAlert()
                    self.hideLoadingIndicator(self.view)
                    self.loadCoreData()
                }
            }
        }
    }
    // MARK: -  Data Loading from Network
    private func loadDataFromNetwork() {
        defer {
            self.refreshControl.endRefreshing()
        }
        guard let movieUrl = moviesCategory else {
            self.hideLoadingIndicator(self.view)
            self.moviesTableView.displayEmptyMessage(DataError.unknownError)

            return
        }
        let responseType = Movies.self
        networkManager.fetchData(from: movieUrl, responseType: responseType) { [weak self] result, error in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.hideLoadingIndicator(self.view)
            }
            if let error = error {
                self.moviesTableView.displayEmptyMessage(error)
            }
            guard let movies = result else {
                self.moviesTableView.displayEmptyMessage(APIError.responseMalformed)
                return
            }
            DispatchQueue.main.async {
                self.movieList = movies.results
                self.moviesTableView.reloadData()
                if let coreDataManager = self.coreDataManager,let moviesCategory = self.moviesCategory {
                    coreDataManager.storeMovies(movies: movies.results, category: moviesCategory)
                }
            }
        }
    }
    // MARK: -  Data Loading from Core Data
    private func loadCoreData() {
        defer {
            self.refreshControl.endRefreshing()
        }
        guard let movies = coreDataManager?.getMovies(category: moviesCategory!) else {
            moviesTableView.displayEmptyMessage(DataError.noCoreDataAvailable)
            return
        }
        if movies.0.isEmpty {
            moviesTableView.displayEmptyMessage(DataError.noCachedDataFound)
        } else {
            self.movieList = movies.0
            self.movieImages = movies.1
            moviesTableView.reloadData()
        }
    }

}
// MARK: - TableView Delegate
extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = storyboard?
            .instantiateViewController(identifier: Constants.movieDetailsVC) as? MovieDetailsViewController
        let  movie = movieList[indexPath.row]
        movieDetailVC?.movieID = movie.id
        movieDetailVC?.movie = movie
        navigationController?.pushViewController(movieDetailVC!, animated: true)
    }
}
// MARK: - TableView DataSource
extension MoviesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.movieTVCell, for: indexPath) as? MovieTableViewCell else {
            print("Can't cast tableView cell to expected MovieTableViewCell Class")
            return UITableViewCell()
        }
        if movieImages.isEmpty {
            cell.config(with: movieList[indexPath.row], category: moviesCategory ?? .nowPlaying)
        } else {
            var movieImage:Data?
            if movieImages.indices.contains(indexPath.row) {
                movieImage = movieImages[indexPath.row]
            }
            cell.config(with: movieList[indexPath.row], category: moviesCategory ?? .nowPlaying,imageData:movieImage)
        }
        return cell
    }
}

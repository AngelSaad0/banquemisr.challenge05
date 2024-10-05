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
    var moviesCategory: MovieApi?
    var movieList: [Movie] = []

    var networkManager: NetworkManagerProtocol
    var connectivityManager: ConnectivityManagerProtocol?


    // MARK: Initalization
    required init?(coder: NSCoder) {
        networkManager = NetworkManager()
        connectivityManager = ConnectivityManager()
        super.init(coder: coder)
    }

    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        loadDataFromApi()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = navigationTitle
    }

    private func setupUI() {
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
    }

    private func loadDataFromApi() {
        guard let movieUrl = moviesCategory else {return}
        let responseType = Movies.self
        networkManager.fetchData(from: movieUrl, responseType: responseType) { [weak self] result in
            guard let movies = result else {
                self?.moviesTableView.displayEmptyMessage("error in loading data")
                return
            }
            DispatchQueue.main.async {
                self?.movieList = movies.results
                self?.moviesTableView.reloadData()
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
        cell.config(with: movieList[indexPath.row], category: moviesCategory ?? .nowPlaying)
        return cell
    }
}

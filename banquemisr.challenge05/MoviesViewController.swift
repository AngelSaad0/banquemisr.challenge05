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
    var networkManager: NetworkManagerProtocol
    var movieList: [Movie] = []

    // MARK: Initalization
    required init?(coder: NSCoder) {
        networkManager = NetworkManager()
        super.init(coder: coder)
    }

    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
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
   
    private func loadData() {
        loadDataFromApi()
    }

}
extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = storyboard?
            .instantiateViewController(identifier: "MovieDetailsViewController") as? MovieDetailsViewController
//        movieDetailVC?.movieId = movieList[indexPath.row].id
        navigationController?.pushViewController(movieDetailVC!, animated: true)
    }

}

extension MoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieTableViewCell",
            for: indexPath
        ) as? MovieTableViewCell else {
            print("cant dequeue cell withIdentifier MovieTableViewCell")
            return UITableViewCell()
        }
        cell.config(with: movieList[indexPath.row], category: moviesCategory ?? .nowPlaying)
        return cell
    }
}

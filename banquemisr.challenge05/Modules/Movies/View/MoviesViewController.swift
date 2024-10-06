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
    private let refreshControl = UIRefreshControl()
    let viewModel: MoviesViewModel!
    
    
    // MARK: Initalization
    required init?(coder: NSCoder) {
        viewModel = MoviesViewModel()
        super.init(coder: coder)
    }
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        setupViewModel()
        viewModel.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = viewModel.navigationTitle
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
        viewModel.loadData()
    }
    
    func setupViewModel() {
        viewModel.setLoadingIndicator = { state in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                state ? self.showLoadingIndicator(self.view) : self.hideLoadingIndicator(self.view)
            }
        }
        viewModel.showNoInternetAlert = {
            DispatchQueue.main.async { [weak self] in
                self?.showNoInternetAlert()
            }
        }
        viewModel.endRefreshControl = {
            self.refreshControl.endRefreshing()
        }
        viewModel.displayEmptyMessage = { message in
            self.moviesTableView.displayEmptyMessage(message)
        }
        viewModel.removeEmptyMessage = {
            self.moviesTableView.removeEmptyMessage()
        }
        viewModel.bindDataToTableView = {
            DispatchQueue.main.async { [weak self] in
                self?.moviesTableView.reloadData()
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
        let  movie = viewModel.movieList[indexPath.row]
        movieDetailVC?.viewModel.movieID = movie.id
        movieDetailVC?.viewModel.movie = movie
        navigationController?.pushViewController(movieDetailVC!, animated: true)
    }
}
// MARK: - TableView DataSource
extension MoviesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.movieTVCell, for: indexPath) as? MovieTableViewCell else {
            print("Can't cast tableView cell to expected MovieTableViewCell Class")
            return UITableViewCell()
        }
        if viewModel.movieImages.isEmpty {
            cell.config(with: viewModel.movieList[indexPath.row], category: viewModel.moviesCategory ?? .nowPlaying)
        } else {
            var movieImage:Data?
            if viewModel.movieImages.indices.contains(indexPath.row) {
                movieImage = viewModel.movieImages[indexPath.row]
            }
            cell.config(with: viewModel.movieList[indexPath.row], category: viewModel.moviesCategory ?? .nowPlaying,imageData:movieImage)
        }
        return cell
    }
}

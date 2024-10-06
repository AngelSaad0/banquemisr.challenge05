//
//  MainTabBarController.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//
import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTabBarAppearance()
    }
    // MARK: -  setup UI for Main TabBar
    private func setupUI() {
        let nowPlayingVC = createViewController(for: Constants.moviesVC, image: Constants.nowPlayingImage, category: .nowPlaying)
        let popularVC = createViewController(for: Constants.moviesVC, image: Constants.popularImage, category: .popular)
        let upcomingVC = createViewController(for: Constants.moviesVC, image: Constants.upcomingImage, category: .upcoming)
        viewControllers = [nowPlayingVC, popularVC, upcomingVC]
    }

    // MARK: -  create ViewController
    private func createViewController(for viewControllerID: String, image: String, category: MovieAPIProvider) -> UIViewController {
        let title = category.title
        let moviesVC = storyboard?.instantiateViewController(withIdentifier: viewControllerID) as! MoviesViewController

        moviesVC.tabBarItem.title = title
        moviesVC.tabBarItem.image = UIImage(systemName: image)
        moviesVC.moviesCategory = category
        moviesVC.navigationTitle = "\(title) 🎬"
        return moviesVC
    }

    // MARK: -  setup TabBar Appearance
    private func setupTabBarAppearance() {
        let customFont = UIFont(name: Constants.wickedMouseFont, size: 20) ?? UIFont.systemFont(ofSize: 20)
        let customAttributes: [NSAttributedString.Key: Any] = [ .font: customFont, .foregroundColor: UIColor.tabBarItem]
        navigationController?.navigationBar.titleTextAttributes = customAttributes

        let backButton = UIBarButtonItem()
        backButton.tintColor = .tabBarItem
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton

        tabBar.tintColor = .tabBarItem

    }
}


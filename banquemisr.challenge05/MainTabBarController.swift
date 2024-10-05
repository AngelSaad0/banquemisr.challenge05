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

    private func setupUI() {
        let nowPlayingVC = createViewController(for: Constants.moviesVC, title: "Now Playing", image: "play.circle.fill", category: .nowPlaying)
        let popularVC = createViewController(for: Constants.moviesVC, title: "Popular", image: "flame.fill", category: .popular)
        let upcomingVC = createViewController(for: Constants.moviesVC, title: "Upcoming", image: "clock.fill", category: .upcoming)
        viewControllers = [nowPlayingVC, popularVC, upcomingVC]
    }

    private func createViewController(for viewControllerID: String, title: String, image: String, category: MovieApi) -> UIViewController {
        
        let moviesVC = storyboard?.instantiateViewController(withIdentifier: viewControllerID) as! MoviesViewController
        moviesVC.moviesCategory = category
        moviesVC.navigationTitle = "\(title) 🎬"

        moviesVC.tabBarItem.title = title
        moviesVC.tabBarItem.image = UIImage(systemName: image)

        let customFont = UIFont(name: "Wicked Mouse", size: 20) ?? UIFont.systemFont(ofSize: 20)
        let customAttributes: [NSAttributedString.Key: Any] = [ .font: customFont, .foregroundColor: UIColor.tabBarItem]
        navigationController?.navigationBar.titleTextAttributes = customAttributes

        let backButton = UIBarButtonItem()
        backButton.tintColor =  UIColor(named: "tabBarItemColor")
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        return moviesVC
    }

    private func setupTabBarAppearance() {
        tabBar.tintColor = UIColor(named: "tabBarItemColor")
    }
}


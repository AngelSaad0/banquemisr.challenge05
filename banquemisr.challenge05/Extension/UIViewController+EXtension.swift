//
//  UIViewController+EXtension.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/5/24.
//

import Foundation
import UIKit

extension UIViewController {

    private var loadingIndicator: UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = UIColor(red: 115/255, green: 43/255, blue: 50/255, alpha: 1)
        return indicator
    }

    @MainActor func showLoadingIndicator() {
        let indicator = loadingIndicator
        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 100),
            indicator.heightAnchor.constraint(equalToConstant: 100)
        ])

        indicator.startAnimating()
    }

    @MainActor func hideLoadingIndicator() {
        for subview in view.subviews {
            if let indicator = subview as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
    func showNoInternetAlert() {
        let alertTitle = "No Internet"
        let alertMessage = "Please check your internet connection."
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              alert.dismiss(animated: true)
            }

        }
    }
}


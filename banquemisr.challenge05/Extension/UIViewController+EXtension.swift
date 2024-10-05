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
        indicator.color = .tabBarItem
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

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.tabBarItem,
            .font: UIFont(name: Constants.wickedMouseFont, size: 14) ?? UIFont.systemFont(ofSize: 14)
        ]
        let attributedTitle = NSAttributedString(string: alertTitle, attributes: titleAttributes)
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        let attributedMessage = NSAttributedString(string: alertMessage, attributes: messageAttributes)

        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")

        // Present the alert
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                alert.dismiss(animated: true)
            }
        }
    }

}


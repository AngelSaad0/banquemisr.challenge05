//
//  UIView+Extension.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import UIKit
extension UIView {
    @MainActor func displayEmptyMessage(_ error: any LocalizedError) {
        DispatchQueue.main.async {
            let messageLabel = UILabel()
            messageLabel.text = error.errorDescription
            messageLabel.textColor = .tabBarItem
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: Constants.montserratBold, size: 20)
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20),
                messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20)
            ])
        }
    }

    @MainActor func removeEmptyMessage() {
        for subview in self.subviews {
            if let label = subview as? UILabel {
                label.removeFromSuperview()
            }
        }
    }

}


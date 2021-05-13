//
//  UIViewController+Extension.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import UIKit

let activityIndicator = UIActivityIndicatorView(style: .large)

extension UIViewController {
    
    func isNetworkActivity(_ active: Bool) {
        
        activityIndicator.hidesWhenStopped = true
        if active {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        
        self.view.addSubview(activityIndicator)
        constraintsFor(activityIndicator)
        
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//      present(alertVC, animated: true, completion: nil)
        show(alertVC, sender: nil)
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        TMDBClient.logOut(completion: logOutResponseHandler(success:error:))
        
    }
    
    func logOutResponseHandler(success: Bool, error: Error?) {
        if success {
            DispatchQueue.main.async { [self] in
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func constraintsFor(_ ai: UIActivityIndicatorView) {
        ai.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ai.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            ai.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
}

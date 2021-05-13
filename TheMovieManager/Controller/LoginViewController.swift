//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        isNetworkActivity(true)
        loginButton.isEnabled = false
        TMDBClient.getRequestToken(completion: handleRequestTokenResponse(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        isNetworkActivity(false)
        TMDBClient.getRequestToken { (success, error) in
            if success {
                    UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func handleRequestTokenResponse(success: Bool, error: Error?) {
        if success {
            TMDBClient.login(username: self.emailTextField.text ?? "",
                             password: self.passwordTextField.text ?? "") { [self] (success, error) -> (Void) in
                if success {
                    TMDBClient.getSessionId(completion: self.handleSessionIdResponse(success:error:))
                } else {
                    self.isNetworkActivity(false)
                    loginButton.isEnabled = true
                }
            }
        }
        else {
            print(error as Any)
            showLoginFailure(message: error?.localizedDescription ?? "")
            loginButton.isEnabled = false
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        if success {
            print(TMDBClient.Auth.requestToken + "-requestToken")
        } else {
            print("Error requestToken")
            self.isNetworkActivity(false)
            loginButton.isEnabled = true
        }
    }
    
    func handleSessionIdResponse(success: Bool, error: Error?) {
        self.isNetworkActivity(false)
        loginButton.isEnabled = true
        if success {
            print(TMDBClient.Auth.sessionId + "-sessionID")
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            print("Error sessionID")
        }
    }
    
    
    

}

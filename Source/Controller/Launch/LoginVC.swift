//
//  LoginVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class LoginVC: UIViewController {
    
    //MARK: - Properties

    //MARK: - Outlets
    
    @IBOutlet weak var loginButton: LoadingButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var logoView: UIView!
    
    @IBOutlet weak var emailField: JVFloatLabeledTextField!
    @IBOutlet weak var passwordField: JVFloatLabeledTextField!
    
    
    //MARK: - Actions
    
    func showLoginError(message: String) {
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func login(_ sender: LoadingButton) {
        view.endEditing(true)
        sender.showLoading()
        
        let email = emailField.text!
        let password = passwordField.text!
        
        guard !email.isEmpty else {
            showLoginError(message: "Email required")
            sender.hideLoading()
            return
        }
        
        guard !password.isEmpty else {
            showLoginError(message: "Password required")
            sender.hideLoading()
            return
        }
        
        /*
        try! Request.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                sender.hideLoading()
                
                switch result {
                case .failure(let error):
                    // Handle Error
                    switch error {
                    case .userNotFound: // Email incorrect
                        self.showLoginError(message: "Incorrect email")
                    case .unauthorised: // Password incorrect
                        self.showLoginError(message: "Incorrect password")
                    default: // Generic error
                        print(error)
                        self.showLoginError(message: "An error occurred.")
                    }
                case .success(_):
                    // return to loading screen
                    print("Successfully logged in")
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }*/
    }
    
    @IBAction func forgotPassword() {
        loginButton.showLoading()
        
        let email = emailField.text!
        
        guard !email.isEmpty else {
            loginButton.hideLoading()
            let alert = UIAlertController(title: "Error", message: "Please enter an email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        /*
        do {
            try Request.shared.forgotPassword(email: email) { result in
                DispatchQueue.main.async {
                    self.loginButton.hideLoading()
                    switch result {
                    case .failure(let error):
                        var alert: UIAlertController!
                        switch error {
                        case .userNotFound: // invalid email
                            alert = UIAlertController(title: "Invalid email", message: "That email doesn't belong to any user account.", preferredStyle: .alert)
                        default:
                            alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: .alert)
                        }
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case .success(_):
                        let alert = UIAlertController(title: "Success", message: "Please check your email for a password reset link.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } catch {
            let alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }*/
        
    }
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        backButton.setImage(#imageLiteral(resourceName: "Left Arrow").withRenderingMode(.alwaysTemplate), for: .normal)

    }
    
}

extension LoginVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

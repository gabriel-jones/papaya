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
        self.hero_dismissViewController()
    }
    
    @IBAction func login(_ sender: LoadingButton) {
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
        
        /*User.current.login(email: email, password: password) { success, code in
            sender.hideLoading()
            
            if success {
                //return to home screen
                print("login success")
                print(User.current.auth_token)
                return
            }
            
            switch code {
            case .userNotFound:
                // incorrect email
                self.showLoginError(message: "Incorrect email")
            case .unauthorised:
                // incorrect password
                self.showLoginError(message: "Incorrect password")
            default:
                //request error, handle somehow
                print(code)
                self.showLoginError(message: "An error occurred.")
            }
        }*/
        
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        
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

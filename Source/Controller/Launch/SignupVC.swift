//
//  SignupVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/22/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class SignupVC: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - Outlets
    
    @IBOutlet weak var signupButton: LoadingButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var logoView: UIView!
    
    @IBOutlet weak var fnameField: JVFloatLabeledTextField!
    @IBOutlet weak var lnameField: JVFloatLabeledTextField!
    @IBOutlet weak var emailField: JVFloatLabeledTextField!
    @IBOutlet weak var passwordField: JVFloatLabeledTextField!
    
    //MARK: - Actions
    
    func showSignupError(message: String) {
        let alert = UIAlertController(title: "Signup Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.hero_dismissViewController()
    }
    
    @IBAction func signup(_ sender: LoadingButton) {
        sender.showLoading()
        
        let fname = fnameField.text!
        let lname = lnameField.text!
        let email = emailField.text!
        let password = passwordField.text!
        
        if fname.isEmpty || lname.isEmpty || email.isEmpty || password.isEmpty {
            showSignupError(message: "Please fill out all the fields.")
            sender.hideLoading()
            return
        }
        
        if fname.length > 50 || lname.length > 50 {
            showSignupError(message: "Maximum name length is 50 characters.")
            sender.hideLoading()
            return
        }
        
        if email.length > 120 {
            showSignupError(message: "Maximum email length is 120 characters.")
            sender.hideLoading()
            return
        }
        
        
        
    }
    
    @IBAction func goToLogin(_ sender: Any) {
        //TODO: goToLogin
    }
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        backButton.setImage(#imageLiteral(resourceName: "Left Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
    }
}

extension SignupVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

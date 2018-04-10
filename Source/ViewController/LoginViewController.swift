//
//  LoginVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class LoginViewController: UIViewController {
    
    private let backButton = UIButton()
    private let logoView = UIView()
    private let logoImage = UIImageView()
    private let logoName = UILabel()
    private let subtitle = UILabel()
    
    private let emailField = JVFloatLabeledTextField()
    private let passwordField = JVFloatLabeledTextField()
    
    private let loginButton = LoadingButton()
    private let forgotButton = UIButton()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.gradientBackground()
        
        backButton.tintColor = .white
        backButton.setImage(#imageLiteral(resourceName: "Left Arrow").tintable, for: .normal)
        backButton.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        logoImage.image = #imageLiteral(resourceName: "Logo")
        logoView.addSubview(logoImage)
        logoName.text = "Papaya"
        logoName.font = Font.gotham(weight: .bold, size: 25)
        logoName.textColor = .white
        logoView.addSubview(logoName)
        logoView.heroID = "logoView"
        view.addSubview(logoView)
        
        subtitle.text = "Log in to start shopping"
        subtitle.font = Font.gotham(size: 15)
        subtitle.textColor = .white
        subtitle.textAlignment = .center
        view.addSubview(subtitle)
        
        emailField.floatingLabelYPadding = 4
        emailField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        emailField.textColor = .white
        emailField.placeholderColor = .white
        emailField.floatingLabelTextColor = .white
        emailField.floatingLabelActiveTextColor = .white
        emailField.font = Font.gotham(size: 16)
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.keyboardAppearance = .dark
        emailField.borderStyle = .roundedRect
        emailField.autocapitalizationType = .none
        emailField.tintColor = .white
        emailField.autocorrectionType = .no
        view.addSubview(emailField)
        
        passwordField.floatingLabelYPadding = 4
        passwordField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        passwordField.textColor = .white
        passwordField.placeholderColor = .white
        passwordField.floatingLabelTextColor = .white
        passwordField.floatingLabelActiveTextColor = .white
        passwordField.font = Font.gotham(size: 16)
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.tintColor = .white
        passwordField.keyboardAppearance = .dark
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        view.addSubview(passwordField)
        
        loginButton.backgroundColor = .white
        loginButton.layer.cornerRadius = 10
        loginButton.setTitleColor(UIColor(named: .green), for: .normal)
        loginButton.setTitle("Log in", for: .normal)
        loginButton.titleLabel?.font = Font.gotham(weight: .bold, size: 16)
        loginButton.tintColor = UIColor(named: .green)
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        view.addSubview(loginButton)
        
        forgotButton.setTitle("Forgot Password?", for: .normal)
        forgotButton.setTitleColor(.white, for: .normal)
        forgotButton.titleLabel?.font = Font.gotham(size: 15)
        forgotButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        forgotButton.addTarget(self, action: #selector(forgotPassword(_:)), for: .touchUpInside)
        view.addSubview(forgotButton)
    }
    
    private func buildConstraints() {
        backButton.snp.makeConstraints { make in
            make.left.equalTo(view.snp.leftMargin)
            make.height.width.equalTo(50)
            make.centerY.equalTo(logoView.snp.centerY)
        }
        
        logoImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
            make.height.equalTo(40)
            make.width.equalTo(logoImage.snp.height)
        }
        
        logoName.snp.makeConstraints { make in
            make.top.bottom.centerY.equalToSuperview()
            make.width.equalTo(92)
            make.left.equalTo(logoImage.snp.right).offset(16)
        }
        
        logoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.topMargin).offset(8)
            make.height.equalTo(50)
            make.width.equalTo(168)
        }
        
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(30)
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(24)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(30)
            make.height.equalTo(44)
            make.leading.equalTo(emailField.snp.leading)
            make.trailing.equalTo(emailField.snp.trailing)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(30)
            make.height.equalTo(50)
            make.leading.equalTo(passwordField.snp.leading).offset(16)
            make.trailing.equalTo(passwordField.snp.trailing).offset(-16)
        }
        
        forgotButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
        }
    }
    
    //MARK: - Actions
    
    func showLoginError(message: String) {
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func login(_ sender: LoadingButton) {
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
        
        Request.shared.login(email: email, password: password) { result in
            print("Login result: \(result)")
            sender.hideLoading()
            switch result {
            case .success(let user):
                self.navigationController?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                switch error as? RequestError {
                case .userNotFound?: // Email incorrect
                    self.showLoginError(message: "Incorrect email")
                case .unauthorised?: // Password incorrect
                    self.showLoginError(message: "Incorrect password")
                default: // Generic error
                    print(error)
                    self.showLoginError(message: "An error occurred")
                }
            }
        }
    }
    
    @objc func forgotPassword(_ sender: UIButton) {
        loginButton.showLoading()
        
        guard let email = emailField.text, !email.isEmpty else {
            loginButton.hideLoading()
            let alert = UIAlertController(title: "Error", message: "Please enter an email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        Request.shared.forgotPassword(email: email) { result in
            self.loginButton.hideLoading()
            switch result {
            case .success(let user):
                let alert = UIAlertController(title: "Success", message: "Please check your email for a password reset link.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .failure(let error):
                var alert: UIAlertController!
                switch error as? RequestError {
                case .userNotFound?:
                    alert = UIAlertController(title: "Invalid email", message: "That email doesn't belong to any user account.", preferredStyle: .alert)
                default:
                    alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: .alert)
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

//
//  SignupVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/22/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import RxSwift

class SignupVC: UIViewController {
    
    private let backButton = UIButton()
    private let logoView = UIView()
    private let logoImage = UIImageView()
    private let logoName = UILabel()
    private let subtitle = UILabel()
    private let fnameField = JVFloatLabeledTextField()
    private let lnameField = JVFloatLabeledTextField()
    private let emailField = JVFloatLabeledTextField()
    private let passwordField = JVFloatLabeledTextField()
    private let signupButton = LoadingButton()
    
    private let disposeBag = DisposeBag()
    
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
        
        subtitle.text = "Sign up to start shopping"
        subtitle.font = Font.gotham(size: 15)
        subtitle.textColor = .white
        subtitle.textAlignment = .center
        view.addSubview(subtitle)
        
        fnameField.floatingLabelYPadding = 4
        fnameField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        fnameField.textColor = .white
        fnameField.placeholderColor = .white
        fnameField.floatingLabelTextColor = .white
        fnameField.floatingLabelActiveTextColor = .white
        fnameField.font = Font.gotham(size: 16)
        fnameField.placeholder = "First Name"
        fnameField.keyboardType = .default
        fnameField.keyboardAppearance = .dark
        fnameField.borderStyle = .roundedRect
        fnameField.autocapitalizationType = .none
        fnameField.tintColor = .white
        fnameField.autocorrectionType = .no
        view.addSubview(fnameField)
        
        lnameField.floatingLabelYPadding = 4
        lnameField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        lnameField.textColor = .white
        lnameField.placeholderColor = .white
        lnameField.floatingLabelTextColor = .white
        lnameField.floatingLabelActiveTextColor = .white
        lnameField.font = Font.gotham(size: 16)
        lnameField.placeholder = "Last Name"
        lnameField.keyboardType = .default
        lnameField.keyboardAppearance = .dark
        lnameField.borderStyle = .roundedRect
        lnameField.autocapitalizationType = .none
        lnameField.tintColor = .white
        lnameField.autocorrectionType = .no
        view.addSubview(lnameField)
        
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
        
        signupButton.backgroundColor = .white
        signupButton.layer.cornerRadius = 10
        signupButton.setTitleColor(UIColor(named: .green), for: .normal)
        signupButton.setTitle("Sign up", for: .normal)
        signupButton.titleLabel?.font = Font.gotham(weight: .bold, size: 16)
        signupButton.tintColor = UIColor(named: .green)
        signupButton.addTarget(self, action: #selector(signup(_:)), for: .touchUpInside)
        view.addSubview(signupButton)
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
        
        fnameField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(30)
            make.height.equalTo(44)
            make.leading.equalTo(emailField.snp.leading)
            make.width.equalTo(emailField.snp.width).dividedBy(2).offset(-8)
        }
        
        lnameField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(30)
            make.height.equalTo(44)
            make.trailing.equalTo(emailField.snp.trailing)
            make.width.equalTo(emailField.snp.width).dividedBy(2).offset(-8)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(fnameField.snp.bottom).offset(30)
            make.height.equalTo(44)
            make.leading.equalTo(fnameField.snp.leading)
            make.trailing.equalTo(lnameField.snp.trailing)
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(30)
            make.height.equalTo(50)
            make.leading.equalTo(passwordField.snp.leading).offset(16)
            make.trailing.equalTo(passwordField.snp.trailing).offset(-16)
        }
    }
    
    func showSignupError(message: String) {
        let alert = UIAlertController(title: "Signup Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func signup(_ sender: LoadingButton) {
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
        
        if fname.count > 50 || lname.count > 50 {
            showSignupError(message: "Maximum name length is 50 characters.")
            sender.hideLoading()
            return
        }
        
        if email.count > 120 {
            showSignupError(message: "Maximum email length is 120 characters.")
            sender.hideLoading()
            return
        }
        
        Request.shared.signup(email: email, password: password, fname: fname, lname: lname)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.navigationController?.dismiss(animated: true, completion: nil)
                }, onError: { [unowned self] error in
                    sender.hideLoading()
                    switch error as? RequestError {
                    case .userNotFound?: // Email incorrect
                        self.showSignupError(message: "Incorrect email")
                    case .unauthorised?: // Password incorrect
                        self.showSignupError(message: "Incorrect password")
                    default: // Generic error
                        print(error)
                        self.showSignupError(message: "An error occurred.")
                    }
                }, onCompleted: {
                    sender.hideLoading()
            })
            .disposed(by: disposeBag)
    }
    
    @objc func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//
//  SignupVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/22/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import PhoneNumberKit
import SafariServices

func format(phoneNumber sourcePhoneNumber: String) -> String? {
    // Remove any character that is not a number
    let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let length = numbersOnly.count
    let hasLeadingOne = numbersOnly.hasPrefix("1")
    
    // Check for supported phone number length
    guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
        return nil
    }
    
    let hasAreaCode = (length >= 10)
    var sourceIndex = 0
    
    // Leading 1
    var leadingOne = ""
    if hasLeadingOne {
        leadingOne = "1 "
        sourceIndex += 1
    }
    
    // Area code
    var areaCode = ""
    if hasAreaCode {
        let areaCodeLength = 3
        guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
            return nil
        }
        areaCode = String(format: "(%@) ", areaCodeSubstring)
        sourceIndex += areaCodeLength
    }
    
    // Prefix, 3 characters
    let prefixLength = 3
    guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
        return nil
    }
    sourceIndex += prefixLength
    
    // Suffix, 4 characters
    let suffixLength = 4
    guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
        return nil
    }
    
    return leadingOne + areaCode + prefix + "-" + suffix
}

extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}

func buildTextField() -> JVFloatLabeledTextField {
    let t = JVFloatLabeledTextField()
    t.floatingLabelYPadding = 4
    t.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    t.textColor = .white
    t.placeholderColor = .white
    t.floatingLabelTextColor = .white
    t.floatingLabelActiveTextColor = .white
    t.font = Font.gotham(size: 16)
    t.keyboardAppearance = .dark
    t.borderStyle = .roundedRect
    t.autocapitalizationType = .none
    t.tintColor = .white
    t.autocorrectionType = .no
    return t
}

class SignupViewController: UIViewController {
    
    private var activeTextField: UITextField?
    private var didScrollUp = false
    
    private let backButton = UIButton()
    private let logoView = UIView()
    private let logoImage = UIImageView()
    private let logoName = UILabel()
    private let subtitle = UILabel()
    
    private let fnameField: JVFloatLabeledTextField = buildTextField()
    private let lnameField: JVFloatLabeledTextField = buildTextField()
    private let emailField: JVFloatLabeledTextField = buildTextField()
    private let passwordField: JVFloatLabeledTextField = buildTextField()
    private let phoneField: JVFloatLabeledTextField = buildTextField()
    private let signupButton = LoadingButton()
    
    private let termsButton = UIButton()
    
    private let phoneNumberKit = PhoneNumberKit()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func buildViews() {
        view.gradientBackground()
        
        backButton.tintColor = .white
        backButton.setImage(#imageLiteral(resourceName: "Close").tintable, for: .normal)
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
        
        fnameField.placeholder = "First Name"
        fnameField.keyboardType = .default
        fnameField.delegate = self
        fnameField.autocapitalizationType = .words
        view.addSubview(fnameField)
        
        lnameField.placeholder = "Last Name"
        lnameField.keyboardType = .default
        lnameField.delegate = self
        lnameField.autocapitalizationType = .words
        view.addSubview(lnameField)
        
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.delegate = self
        view.addSubview(emailField)
        
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        view.addSubview(passwordField)
        
        phoneField.placeholder = "Phone Number"
        phoneField.keyboardType = .phonePad
        phoneField.autocorrectionType = .yes
        phoneField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        phoneField.delegate = self
        view.addSubview(phoneField)
        
        signupButton.backgroundColor = .white
        signupButton.layer.cornerRadius = 10
        signupButton.setTitleColor(UIColor(named: .green), for: .normal)
        signupButton.setTitle("Sign up", for: .normal)
        signupButton.titleLabel?.font = Font.gotham(weight: .bold, size: 16)
        signupButton.tintColor = UIColor(named: .green)
        signupButton.addTarget(self, action: #selector(signup(_:)), for: .touchUpInside)
        view.addSubview(signupButton)
        
        termsButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let attr = NSMutableAttributedString(string: "By signing up, I agree to the terms and conditions. View")
        attr.addAttribute(.foregroundColor, value: UIColor.white, range: NSMakeRange(0, attr.string.count))
        attr.addAttribute(.foregroundColor, value: UIColor(named: .yellow), range: (attr.string as NSString).range(of: "View"))
        termsButton.setAttributedTitle(attr, for: .normal)
        termsButton.titleLabel?.lineBreakMode = .byWordWrapping
        termsButton.titleLabel?.font = Font.gotham(size: 15)
        termsButton.titleLabel?.textAlignment = .center
        termsButton.titleLabel?.numberOfLines = 0
        termsButton.addTarget(self, action: #selector(viewTermsAndConditions(_:)), for: .touchUpInside)
        view.addSubview(termsButton)
    }
    
    @objc private func viewTermsAndConditions(_ sender: UIButton) {
        let vc = SFSafariViewController(url: URL(string: C.URL.termsOfService)!)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    private func buildConstraints() {
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
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
            make.top.equalTo(24)
            make.height.equalTo(50)
            make.width.equalTo(168)
        }
        
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.left.right.equalToSuperview()
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
        
        phoneField.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(30)
            make.height.equalTo(44)
            make.leading.equalTo(passwordField.snp.leading)
            make.trailing.equalTo(passwordField.snp.trailing)
        }
        
        termsButton.snp.makeConstraints { make in
            make.centerX.equalTo(phoneField.snp.centerX)
            make.top.equalTo(phoneField.snp.bottom).offset(16)
            make.leading.equalTo(phoneField.snp.leading).offset(16)
            make.trailing.equalTo(phoneField.snp.trailing).offset(-16)
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(termsButton.snp.bottom).offset(16)
            make.height.equalTo(50)
            make.leading.equalTo(phoneField.snp.leading)
            make.trailing.equalTo(phoneField.snp.trailing)
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
        var phone = phoneField.text!
        
        if fname.isEmpty || lname.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty {
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
        
        // E.164
        
        var phoneNumber = ""
        do {
            let pn = try phoneNumberKit.parse(phone, withRegion: "BM")
            phoneNumber = phoneNumberKit.format(pn, toType: .e164)
        }
        catch {
            phone = "(441) " + phone
            do {
                let pn = try phoneNumberKit.parse(phone, withRegion: "BM")
                phoneNumber = phoneNumberKit.format(pn, toType: .e164)
            } catch {
                showSignupError(message: "Invalid phone number.")
                sender.hideLoading()
                return
            }
        }
        
        Request.shared.signup(email: email, password: password, fname: fname, lname: lname, phone: phoneNumber) { result in
            sender.hideLoading()
            switch result {
            case .success(_):
                self.navigationController?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                switch error {
                case .emailExists:
                    self.showSignupError(message: "That email is already linked with another user's account.")
                case .invalidEmail:
                    self.showSignupError(message: "Invalid email.")
                default: // Generic error
                    self.showSignupError(message: "An error occurred. Please try again.")
                }
            }
        }
    }
    
    @objc private func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc private func textDidChange(_ sender: UITextField) {
        if let formatted = format(phoneNumber: sender.text!) {
            sender.text = formatted
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        didScrollUp = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                if let active = activeTextField {
                    var rect = view.frame
                    rect.size.height -= keyboardSize.height + active.frame.height + 50
                    if !rect.contains(active.frame.origin) {
                        didScrollUp = true
                        view.frame.origin.y -= keyboardSize.height
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 && didScrollUp {
                view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

extension SignupViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

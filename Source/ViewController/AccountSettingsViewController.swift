//
//  AccountSettingsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import PhoneNumberKit
import GSMessages

class AccountSettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let activityIndicator = LoadingView()
    private let retryButton = UIButton()
    private var activeTextField: UITextField?
    
    private var user: User?
    
    private var didScrollUp = false
    private var madeChanges = false
    private let phoneNumberKit = PhoneNumberKit()
    
    @objc private func fetchUserDetails() {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        retryButton.isHidden = true
        tableView.isHidden = true
        Request.shared.getUserDetails { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let user):
                self.hideMessage()
                self.user = user
                self.tableView.isHidden = false
                self.tableView.reloadData()
            case .failure(_):
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch account settings", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        if let currentUser = User.current {
            self.user = currentUser
            self.tableView.reloadData()
        } else {
            self.fetchUserDetails()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "Account Settings"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.register(SettingsInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsInputTableViewCell.identifier)
        tableView.register(SettingsButtonTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsButtonTableViewCell.identifier)
        view.addSubview(tableView)
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(fetchUserDetails), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    private func getValueForCell(at: Int) -> String? {
        return (tableView.cellForRow(at: IndexPath(row: at, section: user?.isValidated ?? false ? 0 : 1)) as? SettingsInputTableViewCell)?.textField.text
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Cannot update settings", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func submit(_ sender: LoadingButton) {
        let email = getValueForCell(at: 0)!
        var phone = getValueForCell(at: 1)!
        let fname = getValueForCell(at: 2)!
        let lname = getValueForCell(at: 3)!
        
        if fname.isEmpty || lname.isEmpty || email.isEmpty || phone.isEmpty {
            showError(message: "Please fill out all the fields.")
            return
        }
        
        if fname.count > 50 || lname.count > 50 {
            showError(message: "Maximum name length is 50 characters.")
            return
        }
        
        if email.count > 120 {
            showError(message: "Maximum email length is 120 characters.")
            return
        }
        
        var phoneNumber = ""
        do {
            let pn = try phoneNumberKit.parse(phone, withRegion: "BM", ignoreType: true)
            phoneNumber = String(pn.nationalNumber)
        }
        catch {
            phone = "(441) " + phone
            do {
                let pn = try phoneNumberKit.parse(phone, withRegion: "BM", ignoreType: true)
                phoneNumber = String(pn.nationalNumber)
            } catch {
                showError(message: "Invalid phone number.")
                sender.hideLoading()
                return
            }
        }
        
        user?.email = email
        user?.phone = phoneNumber
        user?.fname = fname
        user?.lname = lname
        
        sender.showLoading()
        Request.shared.updateUser(user: user!) { result in
            sender.hideLoading()
            switch result {
            case .success(_):
                User.current = self.user
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                switch error {
                case .emailExists:
                    self.showError(message: "That email is already linked with another user's account.")
                case .invalidEmail:
                    self.showError(message: "Invalid email.")
                default:
                    self.showError(message: "Update failed. Please try again.")
                }
            }
        }
    }
    
    @objc private func confirmEmail(_ sender: LoadingButton) {
        sender.showLoading()
        Request.shared.resendConfirmationEmail { result in
            sender.hideLoading()
            if result.error != nil {
                self.showMessage("Can't resend confirmation email.", type: .error)
            } else {
                self.showMessage("Confirmation email sent to \(self.user!.email)!", type: .success)
            }
        }
    }
}

extension AccountSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return user?.isValidated ?? false ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user == nil ? 0 : (!user!.isValidated && section == 0 ? 1 : 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && !user!.isValidated {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "confirmEmailCell")
            let button = LoadingButton()
            button.setTitle("Resend Confirmation Email", for: .normal)
            button.setTitleColor(UIColor(named: .green), for: .normal)
            button.titleLabel?.font = Font.gotham(size: 15)
            button.addTarget(self, action: #selector(confirmEmail(_:)), for: .touchUpInside)
            cell.addSubview(button)
            button.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            return cell
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Email"
            cell.textField.keyboardType = .emailAddress
            cell.textField.autocapitalizationType = .none
            cell.textField.autocorrectionType = .no
            cell.textField.text = user?.email
            cell.textField.delegate = self
            cell.tag = 0
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Phone"
            cell.textField.keyboardType = .phonePad
            cell.textField.autocapitalizationType = .none
            cell.textField.autocorrectionType = .no
            cell.textField.text = format(phoneNumber: user!.phone)
            cell.textField.addTarget(self, action: #selector(phoneDidChange(_:)), for: .editingChanged)
            cell.textField.delegate = self
            cell.tag = 1
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "First Name"
            cell.textField.keyboardType = .default
            cell.textField.autocapitalizationType = .words
            cell.textField.autocorrectionType = .no
            cell.textField.text = user?.fname
            cell.textField.delegate = self
            cell.tag = 2
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Last Name"
            cell.textField.keyboardType = .default
            cell.textField.autocapitalizationType = .words
            cell.textField.autocorrectionType = .no
            cell.textField.text = user?.lname
            cell.textField.delegate = self
            cell.tag = 3
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 && !(user?.isValidated ?? true) ? 0 : 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && !(user?.isValidated ?? true) {
            return nil
        }
        let container = UIView()
        
        let button = LoadingButton()
        
        button.backgroundColor = UIColor(named: .green)
        button.layer.cornerRadius = 5
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
        button.titleLabel?.font = Font.gotham(size: 16)
        
        container.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(16)
            make.bottom.equalToSuperview()
            make.right.equalTo(-24)
        }
        
        return container
    }
}

extension AccountSettingsViewController: UITextFieldDelegate {
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
    
    @objc private func phoneDidChange(_ sender: UITextField) {
        if let formatted = format(phoneNumber: sender.text!) {
            sender.text = formatted
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
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

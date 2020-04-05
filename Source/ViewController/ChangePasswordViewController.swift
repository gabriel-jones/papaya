//
//  ChangePasswordViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "Change Password"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.register(SettingsInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsInputTableViewCell.identifier)
        tableView.register(SettingsButtonTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsButtonTableViewCell.identifier)
        view.addSubview(tableView)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func getValueForCell(at: Int) -> String? {
        return (tableView.cellForRow(at: IndexPath(row: at, section: 0)) as? SettingsInputTableViewCell)?.textField.text
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Cannot change password", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func submit(_ sender: LoadingButton) {
        sender.showLoading()
        
        let oldPassword = getValueForCell(at: 0)!
        let newPassword = getValueForCell(at: 1)!
        let newRepeatPassword = getValueForCell(at: 2)!
        
        if oldPassword.isEmpty || newPassword.isEmpty || newRepeatPassword.isEmpty {
            showError(message: "Please fill out all the fields.")
            return
        }
        
        if newPassword != newRepeatPassword {
            showError(message: "Your new password is repeated incorrectly.")
            return
        }
        
        Request.shared.updatePassword(oldPassword: oldPassword, newPassword: newPassword) { result in
            sender.hideLoading()
            switch result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
            case .failure(_):
                self.showMessage("Can't update password", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
        
    }
}

extension ChangePasswordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Current Password"
            cell.textField.keyboardType = .default
            cell.textField.isSecureTextEntry = true
            cell.textField.autocapitalizationType = .none
            cell.textField.keyboardAppearance = .dark
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "New Password"
            cell.textField.keyboardType = .default
            cell.textField.isSecureTextEntry = true
            cell.textField.autocapitalizationType = .none
            cell.textField.keyboardAppearance = .dark
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Repeat New Password"
            cell.textField.keyboardType = .default
            cell.textField.isSecureTextEntry = true
            cell.textField.autocapitalizationType = .none
            cell.textField.keyboardAppearance = .dark
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let container = UIView()
        
        let button = LoadingButton()
        
        button.backgroundColor = UIColor(named: .green)
        button.layer.cornerRadius = 5
        button.setTitle("Change Password", for: .normal)
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

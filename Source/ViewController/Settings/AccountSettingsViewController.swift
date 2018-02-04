//
//  AccountSettingsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import RxSwift

class AccountSettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var madeChanges = false
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
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
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func getValueForCell(at: Int) -> String? {
        return (tableView.cellForRow(at: IndexPath(row: at, section: 0)) as? SettingsInputTableViewCell)?.textField.text
    }
    
    @objc func submit(_ sender: LoadingButton) {
        sender.showLoading()
        if self.madeChanges {
            /*
            Request.shared.update(user: User.current!)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { _ in
                    
                }, onError: { error in
                    
                })
                .disposed(by: disposeBag)
             */
        }
    }
    
    @objc private func textDidChange(_ sender: JVFloatLabeledTextField) {
        madeChanges = self.checkChanges(sender)
    }
    
    func checkChanges(_ sender: JVFloatLabeledTextField) -> Bool {
        switch sender.tag {
        case 0:
            return sender.text == User.current?.email
        case 1:
            return sender.text == User.current?.phone
        case 2:
            return sender.text == User.current?.fname
        case 3:
            return sender.text == User.current?.lname
        default: return false
        }
    }
}

extension AccountSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Email"
            cell.textField.keyboardType = .emailAddress
            cell.textField.autocapitalizationType = .none
            cell.textField.text = User.current?.email
            cell.textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            cell.tag = 0
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Phone"
            cell.textField.keyboardType = .phonePad
            cell.textField.autocapitalizationType = .none
            cell.textField.text = User.current?.phone
            cell.tag = 1
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "First Name"
            cell.textField.keyboardType = .default
            cell.textField.autocapitalizationType = .none
            cell.textField.text = User.current?.fname
            cell.tag = 2
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = "Last Name"
            cell.textField.keyboardType = .default
            cell.textField.autocapitalizationType = .none
            cell.textField.text = User.current?.lname
            cell.tag = 3
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

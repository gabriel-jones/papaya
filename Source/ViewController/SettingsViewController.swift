//
//  SettingsVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/28/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let settings: [SettingField] = [
        SettingField(id: 0, image: UIImage(), name: String(), isModifier: true),
        SettingField(id: 1, image: #imageLiteral(resourceName: "Key"), name: "Password", isModifier: true),
        SettingField(id: 2, image: #imageLiteral(resourceName: "Address"), name: "Addresses", isModifier: false),
        SettingField(id: 3, image: #imageLiteral(resourceName: "Card"), name: "Payment Methods", isModifier: false),
        SettingField(id: 4, image: #imageLiteral(resourceName: "Notification"), name: "Notifications", isModifier: false),
        SettingField(id: 5, image: #imageLiteral(resourceName: "History"), name: "Order History", isModifier: false),
        SettingField(id: 6, image: #imageLiteral(resourceName: "Star-Express"), name: "Papaya Express", isModifier: false),
        SettingField(id: 7, image: #imageLiteral(resourceName: "Help"), name: "Help", isModifier: false),
        SettingField(id: 8, image: #imageLiteral(resourceName: "About"), name: "About", isModifier: false)
    ]
    
    struct SettingField {
        let id: Int
        let image: UIImage
        let name: String
        let isModifier: Bool
        
        func getViewController(_ sender: SFSafariViewControllerDelegate) -> UIViewController? {
            switch id {
            case 0:
                return AccountSettingsViewController()
            case 1:
                return ChangePasswordViewController()
            case 2:
                return AddressListViewController()
            case 3:
                return PaymentListViewController()
            case 4:
                return NotificationSettingsViewController()
            case 5:
                return OrderHistoryViewController()
            case 6:
                return ExpressViewController()
            case 7:
                let vc = SFSafariViewController(url: URL(string: C.URL.help)!)
                vc.delegate = sender
                return vc
            case 8:
                return AboutViewController()
            default: return nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationController?.navigationBar.tintColor = UIColor(named: .green)

        navigationItem.title = "Settings"
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsUserTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsUserTableViewCell.identifer)
        view.addSubview(tableView)
        
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
        closeButton.tintColor = UIColor(named: .green)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func logout(_ sender: LoadingButton) {
        let confirmAlert = UIAlertController(title: "Log out?", message: nil, preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            sender.showLoading()
            AuthenticationStore.logout { didLogout in
                sender.hideLoading()
                if didLogout {
                    self.navigationController?.isNavigationBarHidden = true
                    self.hero_replaceViewController(with: LoadingViewController())
                } else {
                    self.showMessage("Can't logout", type: .error)
                }
            }
        })
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(confirmAlert, animated: true, completion: nil)
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? settings.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = SettingsUserTableViewCell(style: .subtitle, reuseIdentifier: SettingsUserTableViewCell.identifer)
            cell.user = User.current
            return cell
        }
        
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "settingCell")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = settings[indexPath.row].name
            cell.textLabel?.font = Font.gotham(size: 16)
            cell.textLabel?.textColor = indexPath.row == 6 ? UIColorFromRGB(0x6216C2) : .darkGray
            cell.imageView?.image = settings[indexPath.row].image.tintable
            cell.imageView?.tintColor = indexPath.row == 6 ? UIColorFromRGB(0x6216C2) : .gray
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "logoutCell")
        let logoutButton = LoadingButton()
        logoutButton.setTitle("Log out", for: .normal)
        logoutButton.setTitleColor(UIColor(named: .green), for: .normal)
        logoutButton.titleLabel?.font = Font.gotham(size: 15)
        logoutButton.addTarget(self, action: #selector(logout(_:)), for: .touchUpInside)
        cell.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { $0.edges.equalToSuperview() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 && indexPath.row == 0 ? 75 : 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = settings[indexPath.row]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: setting.isModifier ? "Cancel" : "", style: .done, target: self, action: nil)
        if let vc = setting.getViewController(self) {
            if vc is SFSafariViewController {
                present(vc, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension SettingsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

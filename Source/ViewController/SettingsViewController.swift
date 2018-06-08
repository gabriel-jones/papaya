//
//  SettingsVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/28/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let settings: [SettingField] = [
        SettingField(id: 0, image: #imageLiteral(resourceName: "Settings"), name: "Account Settings"),
        SettingField(id: 1, image: #imageLiteral(resourceName: "Settings"), name: "Password"),
        SettingField(id: 2, image: #imageLiteral(resourceName: "Address"), name: "Addresses"),
        SettingField(id: 3, image: #imageLiteral(resourceName: "Notification"), name: "Notifications"),
        SettingField(id: 4, image: #imageLiteral(resourceName: "History"), name: "Order History"),
        SettingField(id: 5, image: #imageLiteral(resourceName: "Star"), name: "Papaya Express"),
        SettingField(id: 6, image: #imageLiteral(resourceName: "Help"), name: "Help"),
        SettingField(id: 7, image: #imageLiteral(resourceName: "About"), name: "About")
    ]
    
    struct SettingField {
        let id: Int
        let image: UIImage
        let name: String
        
        func getViewController(_ sender: SFSafariViewControllerDelegate) -> UIViewController? {
            switch id {
            case 0:
                return AccountSettingsViewController()
            case 1:
                return ChangePasswordViewController()
            case 2:
                return AddressListViewController()
            case 3:
                return NotificationSettingsViewController()
            case 5:
                return ExpressViewController()
            case 6:
                let vc = SFSafariViewController(url: URL(string: C.URL.help)!)
                vc.delegate = sender
                return vc
            case 7:
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
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationController?.navigationBar.tintColor = UIColor(named: .green)

        navigationItem.title = "Settings"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
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
    
    @objc func logout(_ sender: UIButton) {
        let confirmAlert = UIAlertController(title: "Log out?", message: nil, preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            AuthenticationStore.logout { didLogout in
                print(didLogout)
                if didLogout {
                    self.navigationController?.isNavigationBarHidden = true
                    self.hero_replaceViewController(with: LoadingViewController())
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
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "settingCell")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = settings[indexPath.row].name
            cell.textLabel?.font = Font.gotham(size: 16)
            cell.textLabel?.textColor = .darkGray
            cell.imageView?.image = settings[indexPath.row].image.tintable
            cell.imageView?.tintColor = .gray
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "logoutCell")
        let logoutButton = UIButton()
        logoutButton.setTitle("Log out", for: .normal)
        logoutButton.setTitleColor(UIColor(named: .green), for: .normal)
        logoutButton.titleLabel?.font = Font.gotham(size: 15)
        logoutButton.addTarget(self, action: #selector(logout(_:)), for: .touchUpInside)
        cell.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let vc = settings[indexPath.row].getViewController(self) {
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

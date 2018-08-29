//
//  NotificationSettingsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/22/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let activityIndicator = LoadingView()
    private let retryButton = UIButton()
    
    private var model = [NotificationSettingGroup]()
    private var active: URLSessionDataTask?
    
    @objc private func fetchNotificationSettings() {
        tableView.isHidden = true
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        retryButton.isHidden = true
        Request.shared.getUserNotificationSettings { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let notificationSettings):
                self.hideMessage()
                self.model = notificationSettings
                self.tableView.isHidden = false
                self.tableView.reloadData()
            case .failure(_):
                self.retryButton.isHidden = false
                self.showMessage("Can't load notification settings", type: .error, options: [
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
        self.fetchNotificationSettings()
    }

    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "Notifications"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(fetchNotificationSettings), for: .touchUpInside)
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
    
    @objc private func changeSwitch(_ sender: UISwitch) {
        let item = model.map {
            $0.settings.first(where: { $0.id == sender.tag })
        }.first(where: { $0 != nil })!!
        active?.cancel()
        active = Request.shared.updateNotifications(notificationId: item.id, value: sender.isOn) { result in
            if case .failure(_) = result {
//                let sectionIndex = self.model.index(where: { $0.rows.contains(where: { $0.id == sender.tag })})!
//                var row: Int?
//                for model in self.model {
//                    if let r = model.rows.index(where: { $0.id == sender.tag }) {
//                        row = r
//                    }
//                }
//                if let row = row, let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: sectionIndex)), let switchView = cell.accessoryView as? UISwitch {
//                    switchView.setOn(!sender.isOn, animated: false)
//                }
                self.showMessage("Can't update notification settings", type: .error)
            }
        }
    }

}

extension NotificationSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: C.ViewModel.CellIdentifier.notificationSettingSwitchCell.rawValue)
        let setting = model[indexPath.section].settings[indexPath.row]
        cell.textLabel?.text = setting.name
        cell.textLabel?.font = Font.gotham(size: 16)
        
        let settingSwitch = UISwitch()
        settingSwitch.isOn = setting.value
        settingSwitch.tag = setting.id
        settingSwitch.addTarget(self, action: #selector(changeSwitch(_:)), for: .valueChanged)
        cell.accessoryView = settingSwitch
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model[section].name
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Font.gotham(size: header.textLabel!.font.pointSize)
    }
}

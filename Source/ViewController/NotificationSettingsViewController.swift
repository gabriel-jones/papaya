//
//  NotificationSettingsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/22/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController {
    
    struct NotificationGroup {
        let name: String
        let rows: [NotificationSetting]
    }
    
    struct NotificationSetting {
        let id: Int
        let key: String
        let name: String
        var initialValue: Bool
    }
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var model = [NotificationGroup]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        model = [
            NotificationGroup(name: "Order updates", rows: [
                NotificationSetting(id: 0, key: "order_sms", name: "SMS", initialValue: true),
                NotificationSetting(id: 1, key: "order_push_notification", name: "Push notifications", initialValue: true)
            ]),
            NotificationGroup(name: "Item in stock", rows: [
                NotificationSetting(id: 2, key: "", name: "Emails", initialValue: true),
                NotificationSetting(id: 3, key: "", name: "Push notifications", initialValue: true)
            ]),
            NotificationGroup(name: "Marketing", rows: [
                NotificationSetting(id: 4, key: "marketing_emails", name: "Emails", initialValue: true),
                NotificationSetting(id: 5, key: "marketing_push_notification", name: "Push notifications", initialValue: true)
            ])
        ]
        tableView.reloadData()
    }

    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "Notifications"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func changeSwitch(_ sender: UISwitch) {
        /*let item = model.map {
            $0.rows.first(where: { $0.id == sender.tag })!
        }.first!
        Request.shared.updateNotifications(values: [item.key: sender.isOn])
            .observeOn(MainScheduler.instance)
            .subscribe(onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)*/
    }

}

extension NotificationSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: C.ViewModel.CellIdentifier.notificationSettingSwitchCell.rawValue)
        let setting = model[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = setting.name
        cell.textLabel?.font = Font.gotham(size: 16)
        
        let settingSwitch = UISwitch()
        settingSwitch.isOn = setting.initialValue
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

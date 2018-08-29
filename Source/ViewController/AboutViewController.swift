//
//  AboutViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/22/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "About"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }
    
    private func buildConstraints () {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func openURL(_ url: String) {
        let vc = SFSafariViewController(url: URL(string: url)!)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension AboutViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: C.ViewModel.CellIdentifier.aboutCell.rawValue)
        cell.textLabel?.text = ["3rd Party Libraries", "Terms of Service", "Privacy Policy"][indexPath.row]
        cell.textLabel?.font = Font.gotham(size: 16)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Version \(Config.shared.version) (Build #\(Config.shared.buildNumber))"
        label.textAlignment = .center
        label.font = Font.gotham(size: 12)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0: // Legal
            navigationController?.pushViewController(LegalViewController(), animated: true)
        case 1: // ToS
            self.openURL(C.URL.termsOfService)
        case 2: // Privacy Policy
            self.openURL(C.URL.privacyPolicy)
        default: break
        }
    }
}

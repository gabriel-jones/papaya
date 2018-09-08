//
//  LegalViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/22/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import SafariServices

class LegalViewController: UIViewController {
    
    struct Library {
        let name: String
        let url: String
    }
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var libs = [Library]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        libs = [
            Library(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit"),
            Library(name: "UIImageViewAlignedSwift", url: "https://github.com/sochalewski/UIImageViewAlignedSwift"),
            
            Library(name: "GSMessages", url: "https://github.com/wxxsw/GSMessages"),
            Library(name: "CHIPageControl/Jaloro", url: "https://github.com/ChiliLabs/CHIPageControl"),
            Library(name: "JVFloatLabeledTextField", url: "https://github.com/jverdi/JVFloatLabeledTextField"),
            Library(name: "Mandoline", url: "https://github.com/blueapron/Mandoline"),
            Library(name: "HCSStarRatingView", url: "https://github.com/hsousa/HCSStarRatingView"),
            Library(name: "UIScrollView-InfiniteScroll", url: "https://github.com/pronebird/UIScrollView-InfiniteScroll"),
            Library(name: "PhoneNumberKit", url: "https://github.com/marmelroy/PhoneNumberKit"),
            
            Library(name: "SwiftyJSON", url: "https://github.com/SwiftyJSON/SwiftyJSON"),
            Library(name: "PINRemoteImage", url: "https://github.com/pinterest/PINRemoteImage"),
            Library(name: "ReachabilitySwift", url: "https://github.com/SwiftyJSON/SwiftyJSON"),
            
            Library(name: "Hero", url: "https://github.com/lkzhao/Hero"),
            Library(name: "Presentr", url: "https://github.com/IcaliaLabs/Presentr"),
            
            Library(name: "KeychainAccess", url: "https://github.com/kishikawakatsumi/KeychainAccess"),
        ]
        tableView.reloadData()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "3rd Party Libraries"
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

extension LegalViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension LegalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: C.ViewModel.CellIdentifier.libraryCell.rawValue)
        cell.textLabel?.text = libs[indexPath.row].name
        cell.textLabel?.font = Font.gotham(size: 16)
        cell.textLabel?.textColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.openURL(libs[indexPath.row].url)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
}

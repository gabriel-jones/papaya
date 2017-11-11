//
//  SettingsVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 02/10/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import SCLAlertView

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var creditCard: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataSwitch.isOn = UserDefaults.standard.bool(forKey: "useLessData")
        self.emailLabel.text = User.current.email
        self.creditCard.text = String.init(repeating: "**** ", count: 3) + User.current.card
        self.nameLabel.text = User.current.name.0 + " " + User.current.name.1
    }
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dataSwitch: UISwitch!
    @IBAction func changedDataSettings(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "useLessData")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getAuth(_ auth: @escaping () -> ()) {
        let a = UIAlertController(title: "Please enter your password", message: nil, preferredStyle: .alert)
        
        a.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.keyboardAppearance = .dark
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        a.addAction(UIAlertAction(title: "OK", style: .default) { [weak a] (_) in
            do {
                if try keychain.get("user_password") == a!.textFields![0].text {
                    auth()
                }
            } catch {
                print("Could not read from keychain. Exiting...")
                exit(-666)
            }
        })
        a.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.setSelected(false, animated: false)
        })
        self.present(a, animated: true, completion: nil)
    }
    
    func openInfoPage(_ info: SettingsInfoVC.InfoPage) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsInfoVC") as! SettingsInfoVC
        vc.infoType = info
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func open<T: UIViewController>(vc: T.Type) {
        let v = self.storyboard?.instantiateViewController(withIdentifier: String(describing: vc)) as! T
        self.navigationController!.pushViewController(v, animated: true)
    }
    
    func openNotificationsPage() {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                open(vc: NameVC.self)
            case 1:
                open(vc: EmailVC.self)
            case 2:
                open(vc: PasswordVC.self)
            case 3:
                open(vc: AdvancedVC.self)
            default:break
            }
        case 1:
            getAuth {
                self.open(vc: PaymentVC.self)
            }
        case 2:
            switch indexPath.row {
            case 0:
                openInfoPage(.help)
            case 1:
                openInfoPage(.privacy)
            case 2:
                openInfoPage(.terms)
            case 3:
                openInfoPage(.acknowledgements)
            default:break
            }
        case 3:
            switch indexPath.row {
            case 1:
                openNotificationsPage()
            default:break
            }
        default: break
        }
    }

    func logout() {
        _ = User.current.logout()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func logout(_ sender: UIButton) {
        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        a.addButton("Logout") {
            self.logout()
        }
        a.addButton("Cancel") {}
        if Order.current.id != -1 {
            a.showNotice("An order is in progress", subTitle: "You will not receive updates on it's status if you logout.")
        } else {
            a.showNotice("Logout", subTitle: "Are you sure you want to logout?")
        }
    }
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "GothamRounded-Medium", size: 11)
        header.textLabel?.textColor = UIColor.lightGray
    }
}

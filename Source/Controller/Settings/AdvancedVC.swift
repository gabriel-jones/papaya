//
//  AdvancedVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 21/07/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SCLAlertView

class AdvancedVC: UITableViewController {
    
    //MARK: - Methods
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var storeID: UITextField!
    @IBOutlet weak var warningMessage: UILabel!

    //MARK: - Actions
    
    @IBAction func requestStoreLink(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let a = alert(actions: [
            AlertButton("OK")
        ])
        R.get("/scripts/User/get_verification_status.php", parameters: ["user_id": User.current.id]) { json, error in
            guard !error, let j = json else {
                a.showWarning("Could not link", subTitle: "There was an error. Please try again.")
                return
            }
            
            User.current.verified = j["verified"].boolValue
            if !User.current.verified {
                a.showWarning("Could not link", subTitle: "Your email must be verified to link your account to a store.")
                return
            }
            R.get("/scripts/User/link.php", parameters: ["user_id": User.current.id, "shop_id": self.storeID.text!]) { _json, _error in
                guard !error, let _j = _json else {
                    a.showWarning("Could not link", subTitle: "There was an error. Please try again.")
                    return
                }
                print(_j)
                if _j["success"].boolValue {
                    alert(actions: [
                        AlertButton("OK") {
                            if User.current.logout() {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                print("Could not logout")
                            }
                        }
                    ]).showSuccess("Packer Request Sent", subTitle: "Please contact your supervisor to authorise your account. You will now be logged out.")
                } else {
                    a.showWarning("Could not link", subTitle: "Please check the Store ID and try again. (Error Code: \(_j["code"].intValue))")
                }
            }
        }
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
    
    @IBAction func deleteAccount(_ sender: UIButton) {
        if Order.current.id != -1 {
            let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            a.addButton("OK") {}
            a.showWarning("An order is in progress", subTitle: "You cannot delete your account. Please cancel the order or call the store for help.")
            return
        }
        
        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        a.addButton("Yes, I am sure", backgroundColor: Color.red) {
            self.getAuth {
                R.get("/scripts/User/delete_account.php", parameters: ["user_id": User.current.id]) { json, error in
                    let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    guard !error, let _ = json else {
                        a.addButton("OK") {}
                        a.showError("Could not delete account", subTitle: "Your account could not be deleted. Please try again.")
                        return
                    }
                    
                    a.addButton("OK") {
                        _ = User.current.logout()
                        self.dismiss(animated: false, completion: nil)
                    }
                    a.showError("Account deleted", subTitle: "You will now be returned to the login screen.")
                }
            }
        }
        a.addButton("Cancel", backgroundColor: Color.grey.0) {}
        a.showError("Delete Account", subTitle: "Are you sure you want to delete your account? This cannot be undone.")
    }

    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return User.current.isPacker ? 0 : 3
        } else if section == 1 {
            return 1
        }
        return 0
    }
}

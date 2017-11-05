//
//  EmailVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 7/8/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SCLAlertView

class EmailVC: UITableViewController {
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return User.current.verified ? 1 : 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        self.email.text = User.current.email
        self.email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.verificationButton.isEnabled = false
        
        R.get("/scripts/User/get_verification_status.php", parameters: ["user_id": User.current.id]) { json, error in
            guard !error, let j = json else {
                return
            }
            self.verificationButton.isEnabled = true
            User.current.verified = j["verified"].boolValue
            self.tableView.reloadData()
        }
    }
    
    var madeChanges = false
    
    override func navigationShouldPopOnBackButton() -> Bool {
        self.view.endEditing(true)
        if madeChanges {
            alert(actions: [
                AlertButton("Save Changes", backgroundColor: Color.green, textColor: UIColor.white) {
                    self.save(nil)
                },
                AlertButton("Exit", backgroundColor: Color.red, textColor: UIColor.white) {
                    self.navigationController?.popViewController(animated: true)
                },
                AlertButton("Cancel")
            ]).showWarning("Exit?", subTitle: "Any unsaved changes will be lost.")
            return false
        }
        return true
    }
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var verificationButton: UIButton!
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        madeChanges = true
        saveButton.isEnabled = !sender.text!.isEmpty
    }
    
    @IBAction func resendVerification(_ sender: UIButton) {
        R.verifyEmail(User.current.email) { complete in
            DispatchQueue.main.async {
                print("Sent verification email")
                let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                a.addButton("OK") {}
                if !complete {
                    a.showWarning("Could not send email", subTitle: "Please check your connection and try again.")
                } else {
                    a.showSuccess("Email sent", subTitle: "Please check your email for the verification link.")
                }
            }
        }
    }
    
    @IBAction func save(_ sender: Any?) {
        if self.email.text! == User.current.email {
            return
        }
        
        self.view.isUserInteractionEnabled = false
        R.checkEmail(self.email.text!) { x in
            DispatchQueue.main.async {
                let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                a.addButton("OK") {}
                switch x {
                case .invalid:
                    a.showWarning("Email invalid", subTitle: "Please enter a valid email")
                    self.view.isUserInteractionEnabled = true
                    return
                case .taken:
                    a.showWarning("Email taken", subTitle: "This email is in use by another account")
                    self.view.isUserInteractionEnabled = true
                    return
                case .requestError:
                    a.showWarning("Could not change email", subTitle: "Please check your connection and try again.")
                    self.view.isUserInteractionEnabled = true
                    return
                case .valid:
                    R.get("/scripts/User/change_email.php", parameters: ["email": self.email.text!, "user_id": User.current.id]) { json, error in
                        self.view.isUserInteractionEnabled = true

                        guard !error, let j = json,j["success"].boolValue else {
                            let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                            a.addButton("OK") {}
                            a.showWarning("Could not change email", subTitle: "Please check your connection and try again.")
                            return
                        }
                        
                        self.madeChanges = false
                        User.current.verified = false
                        keychain["user_email"] = self.email.text!
                        User.current.email = self.email.text!
                        self.tableView.reloadData()
                        a.showSuccess("Email changed", subTitle: "Please check your new email for the verification link.")
                    }
                }
            }
        }
    }
}

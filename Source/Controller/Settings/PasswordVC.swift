//
//  PasswordVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 7/8/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SCLAlertView

class PasswordVC: UITableViewController {

    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func save(_ sender: UIButton?) {
        self.view.isUserInteractionEnabled = false
        
        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        a.addButton("OK") {}
        R.post("/scripts/User/change_password.php", parameters: ["old": oldPassword.text!, "new": newPassword.text!, "user_id": User.current.id]) { json, error in
            
            self.view.isUserInteractionEnabled = true
            
            guard !error, let j = json, j["success"].boolValue else {
                a.showWarning("Can't reset password", subTitle: "Please check your connection and try again.")
                return
            }
            
            a.showSuccess("Password Reset", subTitle: "Your password has been reset successfully.")
            keychain["user_password"] = self.newPassword.text!
            self.madeChanges = false
        }
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        madeChanges = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oldPassword.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        newPassword.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
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
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        R.get("/scripts/User/forgot_password.php", parameters: ["email": User.current.email]) { json, error in
            guard !error, let j = json else {
                a.addButton("OK") {}
                a.showWarning("Error", subTitle: "Could not complete operation. Please try again later")
                return
            }
            
            if(j["success"].boolValue) {
                a.addButton("OK", action: {
                    let b = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    b.addButton("OK") {
                        User.current = nil
                        GroceryList.current = GroceryList(items: [], shop_id: 0, created: Date())
                        Order.current.id = -1
                        
                        do {
                            try keychain.remove("user_email")
                            try keychain.remove("user_password")
                        } catch {
                            print("Error: could not remove keychain values. Exiting application...")
                            exit(-666)
                        }
                        
                        self.dismiss(animated: false, completion: nil)
                    }
                    b.showNotice("Notice", subTitle: "You will now be logged out.")
                })
                a.showSuccess("Change Password", subTitle: "Please check your email for the link to reset your password.")
            } else {
                a.addButton("Resend Verification Email", backgroundColor: Color.green, textColor: UIColor.white) {
                    R.verifyEmail(User.current.email) { complete in
                        DispatchQueue.main.async {
                            print("Sent verification email")
                            let b = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                            b.addButton("OK") {}
                            if !complete {
                                b.showWarning("Can't verify email", subTitle: "Please check your connection and try again.")
                            } else {
                                b.showSuccess("Email sent", subTitle: "Please check your email for the verification link.")
                            }
                        }
                    }
                }
                a.addButton("OK") {}
                a.showWarning("Can't reset password", subTitle: "Please check if your email has been verified and try again.")
            }
        }
    }

}

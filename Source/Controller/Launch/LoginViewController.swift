//
//  LoginViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 15/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

var didLogin = false


class LoginScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: LoginScrollView!
    @IBOutlet weak var email: LoginTextField!
    @IBOutlet weak var password: LoginTextField!
    @IBOutlet weak var login: LargeButton!
    
    var svos = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.main.nativeBounds.height == 1136 {
            //creatAccountToBottom.constant -= 20
            //loginToAccount.constant -= 100
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        self.view.backgroundColor = UIColor.white
        
        self.view.isUserInteractionEnabled = true
        self.scrollView.isUserInteractionEnabled = true
        
        
        email.img = #imageLiteral(resourceName: "Email White")
        email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8431372643, green: 0.8549019694, blue: 0.8588235378, alpha: 1)])
        email.setNeedsDisplay()
        email.text = try? keychain.get("user_email") ?? ""
        
        password.img = #imageLiteral(resourceName: "Lock White Filled-1")
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8431372643, green: 0.8549019694, blue: 0.8588235378, alpha: 1)])
        password.setNeedsDisplay()
        
        let t = UITapGestureRecognizer(target: self, action: #selector(tap))
        
        //t.delegate = self
        self.view.addGestureRecognizer(t)
        
        login.action = requestLogIn
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "tutorial-login") {
            /*let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            a.addButton("OK") {
                UserDefaults.standard.set(true, forKey: "tutorial-login")
                UserDefaults.standard.synchronize()
            }
            a.showSuccess("Welcome to PrePacked!", subTitle: "To get started, create an account or login with an existing account.")*/
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if didLogin {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func createAccount(_ sender: AnyObject) {
        let vc = SignupVC.instantiate(from: .login)
        self.present(vc, animated: true, completion: nil)
    }
    
    func requestLogIn() {
        self.password.error = false
        self.email.error = false
        
        if self.email.text!.isEmpty {
            self.email.error = true
        }
        
        if self.password.text!.isEmpty {
            self.password.error = true
        }
        
        if self.password.text!.isEmpty || self.email.text!.isEmpty {
            return
        }
        
        view.endEditing(true)
        
        let a = UIActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        a.center = view.center
        a.activityIndicatorViewStyle = .white
        a.startAnimating()
        
        R.login(self.email.text!, p: self.password.text!) { error in
            DispatchQueue.main.async {
                a.removeFromSuperview()
                if error == nil {
                    didLogin = true
                    self.dismiss(animated: true, completion: nil)
                } else if error == .incorrectEmail {
                    self.email.error = true
                } else if error == .incorrectPassword {
                    self.password.error = true
                } else if error == .awaitingPackerStatus {
                    //SCLAlertView().showWarning("Cannot login", subTitle: "Awaiting packer authorisation. Please contact your supervisor for assistance.")
                } else {
                    //SCLAlertView().showWarning("An Error Occurred", subTitle: "An unexpected error occured. Please check your connection and try again.")
                }
            }
        }
    }
    
    @objc func tap() {
        self.view.endEditing(true)
        scrollView.setContentOffset(svos, animated: true)
    }
    
    @IBAction func forgotPass(_ sender: AnyObject) {
        self.view.endEditing(true)
        /*
        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        a.addButton("OK", action: {})

        if self.email.text == "" {
            a.showWarning("Error", subTitle: "Please enter an email")
            return
        }
        
        R.get("/scripts/User/forgot_password.php", parameters: ["email": self.email.text!]) { json, error in
            guard !error, let j = json else {
                a.showWarning("Could not connect", subTitle: "Please check your connection and try again later.")
                return
            }
            
            if(j["success"].boolValue) {
                a.showSuccess("Change Password", subTitle: "Please check your email for the link to reset your password")
                self.password.text = ""
                self.password.error = false
                return
            }
            
            R.checkEmail(self.email.text!) { s in
                if s == .taken {
                    let b = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    b.addButton("Resend Verification Email", backgroundColor: Color.green, textColor: UIColor.white) {
                        R.verifyEmail(self.email.text!) { success in
                            if success {
                                b.showSuccess("Email Verification Sent", subTitle: "Please check your email for the link to verify your account.")
                            } else {
                                b.showError("Email Verification Failed", subTitle: "There was an error. Please try again.")
                            }
                        }
                    }
                    b.showWarning("Can't reset password", subTitle: "Please check if your email is valid and has been verified.")
                } else {
                    a.showWarning("Can't reset password", subTitle: "Please check if your email is valid and try again.")
                }
            }
        }*/
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

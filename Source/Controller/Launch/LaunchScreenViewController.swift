//
//  LaunchScreenViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 11/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.gradientBackground()
    }
    
    func error() {
        alert(actions: [AlertButton("OK", action: {
            //Allow retry
        })]).showWarning("An Error Occured", subTitle: "Please check your connection and try again.")
    }
    
    func next() {
        self.performSegue(withIdentifier: User.current.isPacker ? "goPacker" : "go", sender: self)
    }
    
    func m() {
        R.checkConnection { online in
            print(online)
            if !online {
                self.error()
                return
            }
            
            self.relogin { f in
                if f == .other {
                    self.error()
                    return
                } else if f == .none {
                    R.get("/scripts/Lists/shops.php", parameters: [:]) { json, error in
                        guard !error, let j = json else {
                            return
                        }
                        
                        for shop in j {
                            Shop.all.append(Shop(dict: shop.1))
                        }
                        
                        R.get("/scripts/User/current_order.php", parameters: ["user_id": User.current.id]) { _json, _error in
                            guard !_error, let _j = _json else {
                                return
                            }
                            Order.current.id = _j["id"].intValue
                            self.next()
                        }
                        
                    }
                } else {
                    didLogin = false
                    self.performSegue(withIdentifier: "toLogin", sender: self)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        m()
    }
    
    enum ReloginError {
        case credentials
        case new
        case other
        case none
        case packerAuth
    }
    
    func relogin(_ c: @escaping (ReloginError)->()) {
        print("Auto-login: ")
        if let p = keychain["user_password"], let e = keychain["user_email"] {
            print(e, ":", p)
            R.login(e, p: p) { error in
                print("Login Error:", error ?? "none")
                
                guard let e = error else {
                    c(.none)
                    return
                }
                
                switch e {
                case .incorrectEmail, .incorrectPassword:
                    c(.credentials)
                case .awaitingPackerStatus:
                    c(.packerAuth)
                default:
                    c(.other)
                }
            }
        } else {
            c(.new)
        }
    }
}

//
//  GetStartedVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import Hero
import CHIPageControl

class GetStartedVC: UIViewController {

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var pageIndicator: CHIPageControlJaloro!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageIndicator.elementWidth = view.frame.width / 5
        
        //pageIndicator.set(progress: page, animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        let loginVC = LoginVC.instantiate(from: .login)
        loginVC.heroModalAnimationType = .push(direction: .left)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    

}

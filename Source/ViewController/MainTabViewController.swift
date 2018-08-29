//
//  MainTabVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/9/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController, UITabBarControllerDelegate, CurrentOrderViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        tabBar.tintColor = UIColor(named: .green)

    }
    
    func openOrder(orderId: Int) {
        let vc = StatusViewController()
        vc.orderId = orderId
        
        self.present(vc, animated: true, completion: nil)
        
    }

}

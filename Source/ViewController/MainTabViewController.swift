//
//  MainTabVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/9/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        tabBar.barTintColor = UIColor(named: .green)
        tabBar.tintColor = UIColor(named: .yellow)
        tabBar.unselectedItemTintColor = .white
        tabBar.shadowImage = UIImage()
    }

}

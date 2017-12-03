//
//  MainTabVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/9/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        tabBar.barTintColor = Color.green
        tabBar.tintColor = Color.yellow
        tabBar.unselectedItemTintColor = .white
        tabBar.shadowImage = UIImage()

    }

}

class TabChildVC: UIViewController {
    
    @objc func openCart(_ sender: UIBarButtonItem) {
        tabBarController?.performSegue(withIdentifier: "openCart", sender: self)
    }
    
    @objc func updateCartBadge(_ sender: Notification) {
        navigationItem.rightBarButtonItem?.badgeValue = sender.userInfo!["newValue"] as! String
    }
    
    override func viewDidLoad() {
        let b = UIButton(frame: CGRect(x: 0, y: 0, width: #imageLiteral(resourceName: "Cart").size.width, height: #imageLiteral(resourceName: "Cart").size.height))
        b.addTarget(self, action: #selector(openCart(_:)), for: .touchUpInside)
        b.setImage(#imageLiteral(resourceName: "Cart").withRenderingMode(.alwaysTemplate), for: .normal)
        b.imageView?.tintColor = Color.green
        let cartButton = UIBarButtonItem(customView: b)
        
        cartButton.badgeBGColor = Color.red
        cartButton.badgeOriginY = -10
        
        navigationItem.rightBarButtonItem = cartButton
        navigationItem.rightBarButtonItem?.badgeValue = "0"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge(_:)), name: NSNotification.Name(rawValue: C.Notification.CartBadgeUpdate), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

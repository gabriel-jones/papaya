//
//  MainTabVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/9/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RxSwift

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        tabBar.barTintColor = UIColor(named: .green)
        tabBar.tintColor = UIColor(named: .yellow)
        tabBar.unselectedItemTintColor = .white
        tabBar.shadowImage = UIImage()

    }

}

class ViewControllerWithCart: UIViewController {
    
    @objc func openCart(_ sender: UIBarButtonItem) {
        let cart = CartViewController()
        let nav = UINavigationController(rootViewController: cart)
        nav.isHeroEnabled = true
        heroModalAnimationType = .pageIn(direction: .left)
        nav.navigationBar.tintColor = UIColor(named: .green)
        present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        let b = UIButton(frame: CGRect(x: 0, y: 0, width: #imageLiteral(resourceName: "Cart").size.width, height: #imageLiteral(resourceName: "Cart").size.height))
        b.addTarget(self, action: #selector(openCart(_:)), for: .touchUpInside)
        b.setImage(#imageLiteral(resourceName: "Cart").tintable, for: .normal)
        b.imageView?.tintColor = UIColor(named: .green)
        let cartButton = UIBarButtonItem(customView: b)
        
        cartButton.badgeBGColor = UIColor(named: .red)
        cartButton.badgeOriginY = -10
        
        navigationItem.rightBarButtonItem = cartButton
        navigationItem.rightBarButtonItem?.badgeValue = "0"
    }
}

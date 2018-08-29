//
//  ViewControllerWithCart.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/31/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

protocol CartViewControllerDelegate: class {
    func changeToSearchTab()
}

class ViewControllerWithCart: UIViewController {
    
    @objc private func openCart(_ sender: UIBarButtonItem) {
        isHeroEnabled = true
        let cart = CartViewController()
        cart.delegate = self
        
        let nav = UINavigationController(rootViewController: cart)
        nav.isHeroEnabled = true
        nav.navigationBar.tintColor = UIColor(named: .green)
        
        nav.heroModalAnimationType = .selectBy(presenting: .cover(direction: .left), dismissing: .uncover(direction: .right))
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func openSettings(_ sender: UIBarButtonItem) {
        let settings = SettingsViewController()
        let vc = UINavigationController(rootViewController: settings)
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        let cartButton = UIButton(frame: CGRect(x: 0, y: 0, width: #imageLiteral(resourceName: "Cart").size.width, height: #imageLiteral(resourceName: "Cart").size.height))
        cartButton.addTarget(self, action: #selector(openCart(_:)), for: .touchUpInside)
        cartButton.setImage(#imageLiteral(resourceName: "Cart").tintable, for: .normal)
        cartButton.imageView?.tintColor = UIColor(named: .green)
        let cartBarButton = UIBarButtonItem(customView: cartButton)
        navigationItem.rightBarButtonItem = cartBarButton
        
        if tabBarController?.selectedIndex != 1 {
            let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(openSettings(_:)))
            settingsButton.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = settingsButton
        }
    }
}

extension ViewControllerWithCart: CartViewControllerDelegate {
    func changeToSearchTab() {
        tabBarController?.selectedIndex = 1
    }
}

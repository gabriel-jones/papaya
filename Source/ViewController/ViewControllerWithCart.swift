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
    
    @objc func openCart(_ sender: UIBarButtonItem) {
        isHeroEnabled = true
        let cart = CartViewController()
        cart.delegate = self
        
        let nav = UINavigationController(rootViewController: cart)
        nav.isHeroEnabled = true
        nav.navigationBar.tintColor = UIColor(named: .green)
        
        nav.heroModalAnimationType = .selectBy(presenting: .cover(direction: .left), dismissing: .uncover(direction: .right))
        present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        let b = UIButton(frame: CGRect(x: 0, y: 0, width: #imageLiteral(resourceName: "Cart").size.width, height: #imageLiteral(resourceName: "Cart").size.height))
        b.addTarget(self, action: #selector(openCart(_:)), for: .touchUpInside)
        b.setImage(#imageLiteral(resourceName: "Cart").tintable, for: .normal)
        b.imageView?.tintColor = UIColor(named: .green)
        let cartButton = UIBarButtonItem(customView: b)
        navigationItem.rightBarButtonItem = cartButton
    }
}

extension ViewControllerWithCart: CartViewControllerDelegate {
    func changeToSearchTab() {
        tabBarController?.selectedIndex = 1
    }
}

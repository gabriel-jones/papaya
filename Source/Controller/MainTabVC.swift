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

class TabChildVC: UIViewController {
    
    @objc func openCart(_ sender: UIBarButtonItem) {
        tabBarController?.performSegue(withIdentifier: "openCart", sender: self)
    }
    
    override func viewDidLoad() {
        let b = UIButton(frame: CGRect(x: 0, y: 0, width: #imageLiteral(resourceName: "Cart").size.width, height: #imageLiteral(resourceName: "Cart").size.height))
        b.addTarget(self, action: #selector(openCart(_:)), for: .touchUpInside)
        b.setImage(#imageLiteral(resourceName: "Cart").withRenderingMode(.alwaysTemplate), for: .normal)
        b.imageView?.tintColor = UIColor(named: .green)
        let cartButton = UIBarButtonItem(customView: b)
        
        cartButton.badgeBGColor = UIColor(named: .red)
        cartButton.badgeOriginY = -10
        
        navigationItem.rightBarButtonItem = cartButton
        navigationItem.rightBarButtonItem?.badgeValue = "0"
        
        self.buildObservers()
    }
    
    let disposeBag = DisposeBag()
    
    private func buildObservers() {
        /*
        Cart.current.items
            .asObservable()
            .subscribe({ items in
                self.navigationItem.rightBarButtonItem?.badgeValue = String(describing: items.element?.count)
            })
            .disposed(by: disposeBag)*/
        
    }
    
    deinit {
        
    }
}

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

    override func viewWillAppear(_ animated: Bool) {
        let homeVC = HomeVC.instantiate(from: )
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "Home White Filled"), tag: 0)
        
        let searchVC = SearchVC.instantiate(from: .main)
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "Search White"), tag: 1)

        let browseVC = Storyboard.settings.viewController(name: "BrowseNavVC")
        listsVC.tabBarItem = UITabBarItem(title: "Browse", image: #imageLiteral(resourceName: "List"), tag: 2)

        let meVC = MeVC.instantiate(from: )
        meVC.tabBarItem = UITabBarItem(title: "Me", image: #imageLiteral(resourceName: "User White Filled"), tag: 3)

        viewControllers = [homeVC, searchVC, browseVC, meVC]
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("selected: \(viewController.title)")
    }

}

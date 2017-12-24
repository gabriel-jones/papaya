//
//  LoadingVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import Hero

class LoadingVC: UIViewController {

    @IBOutlet weak var textRight: NSLayoutConstraint!
    @IBOutlet weak var logoLeft: NSLayoutConstraint!
    @IBOutlet weak var logoText: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoLeft.constant = 79
        logoText.alpha = 0
        textRight.constant = 81
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.logoLeft.constant = 8
            self.textRight.constant = 10
            self.logoText.alpha = 1
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        load()
    }
    
    func load() {
        /*User.current.checkAuthorisation { success in
            if success {
                self.openHomeScreen()
            } else {
                self.reauthorise()
            }
        }*/
    }
    /*
    func reauthorise() {
        User.current.reauthorise { success in
            if success {
                self.openHomeScreen()
            } else {
                self.openGetStarted()
            }
        }
    }*/
    
    func openHomeScreen() {
        let vc = Storyboard.main.viewController(name: C.ViewModel.StoryboardIdentifier.homeTabBar)
        vc.isHeroEnabled = true
        vc.heroModalAnimationType = .auto
        self.hero_replaceViewController(with: vc)
    }
    
    func openGetStarted() {
        let vc = Storyboard.login.viewController(name: C.ViewModel.StoryboardIdentifier.getStartedNav)
        vc.isHeroEnabled = true
        vc.heroModalAnimationType = .fade
        self.hero_replaceViewController(with: vc)
    }

}

//
//  LoadingVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import Hero
import RxSwift

class LoadingVC: UIViewController {
    
    private let disposeBag = DisposeBag()

    private let logoView = UIView()
    private let logoName = UILabel()
    private let logoImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func buildViews() {
        view.gradientBackground()
        
        logoImage.image = #imageLiteral(resourceName: "Logo")
        logoView.addSubview(logoImage)
        
        logoName.text = "Papaya"
        logoName.font = Font.gotham(weight: .bold, size: 25)
        logoName.textColor = .white
        logoName.alpha = 0
        logoView.addSubview(logoName)
        
        logoView.heroID = "logoView"
        view.addSubview(logoView)
                
    }
    
    private func buildConstraints() {
        logoImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo((168 / 2) - (40 / 2))
            make.height.equalTo(40)
            make.width.equalTo(logoImage.snp.height)
        }
        
        logoName.snp.makeConstraints { make in
            make.top.bottom.centerY.equalToSuperview()
            make.width.equalTo(92)
            make.left.equalTo(logoImage.snp.right).offset(50)
        }
        
        logoView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(168)
        }
    }
    
    private func animateLogo() {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.logoImage.snp.updateConstraints { make in
                make.left.equalTo(8)
            }
            self.logoName.snp.updateConstraints { make in
                make.left.equalTo(self.logoImage.snp.right).offset(16)
            }
            self.logoName.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.load()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.animateLogo()
    }
    
    private func load() {
        Request.shared.getUserDetails()
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { user in
                User.current = user
                self.openHomeScreen()
            }, onError: { error in
                switch error as? RequestError {
                case .networkOffline?:
                    break
                case nil:
                    break
                default:
                    self.openGetStarted()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func openHomeScreen() {
        let home = HomeVC()
        home.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "Home"), tag: 0)
        let navHome = UINavigationController(rootViewController: home)
        navHome.isHeroEnabled = true
        
        let search = SearchViewController()
        search.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "Search"), tag: 1)
        let navSearch = UINavigationController(rootViewController: search)
        navSearch.isHeroEnabled = true

        let browse = BrowseVC()
        browse.tabBarItem = UITabBarItem(title: "Browse", image: #imageLiteral(resourceName: "Browse"), tag: 2)
        let navBrowse = UINavigationController(rootViewController: browse)
        navBrowse.isHeroEnabled = true

        let me = MeVC()
        me.tabBarItem = UITabBarItem(title: "Me", image: #imageLiteral(resourceName: "User"), tag: 3)
        let navMe = UINavigationController(rootViewController: me)
        navMe.isHeroEnabled = true
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            navHome,
            navSearch,
            navBrowse,
            navMe
        ]
        tabBarController.tabBar.tintColor = UIColor(named: .green)
        
        //tabBarController.isHeroEnabled = true
        tabBarController.heroModalAnimationType = .auto
        self.hero_replaceViewController(with: tabBarController)
    }
    
    private func openGetStarted() {
        let getStartedVC = GetStartedVC()
        let vc = UINavigationController(rootViewController: getStartedVC)
        vc.navigationBar.isHidden = true
        vc.isHeroEnabled = true
        vc.heroModalAnimationType = .fade
        self.present(vc, animated: true, completion: nil)
    }
}

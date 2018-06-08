//
//  LoadingVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    private let logoView = UIView()
    private let logoName = UILabel()
    private let logoImage = UIImageView()
    
    private var error: RequestError?
    private let group = DispatchGroup()
    private var checkout: Checkout?
    private var scheduleDays: [ScheduleDay]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateLogo()
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
        }) { _ in
            self.load()
        }
    }
    
    private func load() {
        error = nil

        group.enter()
        Request.shared.getUserDetails { [weak self] result in
            switch result {
            case .success(let user):
                User.current = user
            case .failure(let error):
                self?.error = error
            }
            self?.group.leave()
        }
        
        group.enter()
        Request.shared.getCartCount { [weak self] result in
            switch result {
            case .success(let count):
                BaseStore.cartItemCount = count
            case .failure(let error):
                self?.error = error
            }
            self?.group.leave()
        }
        
        group.enter()
        Request.shared.getCheckout { [weak self] result in
            switch result {
            case .success(let checkout):
                self?.group.enter()
                self?.checkout = checkout
                Request.shared.getSchedule(days: 7) { result in
                    switch result {
                    case .success(let schedule):
                        self?.scheduleDays = schedule
                    case .failure(let error):
                        self?.error = error
                    }
                    self?.group.leave()
                }
            case .failure(let error):
                if case .checkoutLineNotFound = error {} else {
                    self?.error = error
                }
            }
            self?.group.leave()
        }
        
        group.notify(queue: .main) {
            switch self.error {
            case .unauthorised?:
                self.openGetStarted()
            default:
                self.openHomeScreen()
            }
        }
    }
    
    private func openHomeScreen() {
        let home = HomeViewController()
        home.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "Home"), tag: 0)
        home.checkout = checkout
        home.scheduleDays = scheduleDays
        let navHome = UINavigationController(rootViewController: home)
        navHome.isHeroEnabled = true
        
        let search = SearchViewController()
        search.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "Search"), tag: 1)
        let navSearch = UINavigationController(rootViewController: search)
        navSearch.isHeroEnabled = true

        let browse = BrowseViewController()
        browse.tabBarItem = UITabBarItem(title: "Browse", image: #imageLiteral(resourceName: "Browse"), tag: 2)
        let navBrowse = UINavigationController(rootViewController: browse)
        navBrowse.isHeroEnabled = true
        
        let clubs = ClubsViewController()
        clubs.tabBarItem = UITabBarItem(title: "Clubs", image: #imageLiteral(resourceName: "Club"), tag: 2)
        let navClubs = UINavigationController(rootViewController: clubs)
        navClubs.isHeroEnabled = true

        let me = MeViewController()
        me.tabBarItem = UITabBarItem(title: "Me", image: #imageLiteral(resourceName: "User"), tag: 3)
        let navMe = UINavigationController(rootViewController: me)
        navMe.isHeroEnabled = true
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            navHome,
            navSearch,
            navBrowse,
            navClubs,
            navMe
        ]
        tabBarController.tabBar.tintColor = UIColor(named: .green)
        
        tabBarController.heroModalAnimationType = .cover(direction: .left)
        hero_replaceViewController(with: tabBarController)
    }
    
    private func openGetStarted() {
        let getStartedVC = GetStartedViewController()
        let vc = UINavigationController(rootViewController: getStartedVC)
        vc.navigationBar.isHidden = true
        vc.isHeroEnabled = true
        vc.heroModalAnimationType = .fade
        present(vc, animated: true, completion: nil)
    }
}

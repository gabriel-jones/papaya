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
    private let activityIndicator = LoadingView()
    private let offlineMessage = UILabel()
    private let retryButton = UIButton()
    
    private var error: RequestError?
    private let group = DispatchGroup()
    private var checkout: Checkout?
    private var scheduleDays: [ScheduleDay]?
    private var order: OrderStatus?

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
        
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        
        offlineMessage.text = "The internet connection appears to be offline."
        offlineMessage.textColor = .white
        offlineMessage.font = Font.gotham(size: 14)
        offlineMessage.numberOfLines = 0
        offlineMessage.isHidden = true
        offlineMessage.textAlignment = .center
        view.addSubview(offlineMessage)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.tintColor = .white
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(load), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
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
        
        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        offlineMessage.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(offlineMessage.snp.bottom).offset(16)
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
    
    private func handleErrors() {
        switch self.error {
        case nil:
            self.openHomeScreen()
        case .networkOffline?, .unknown?:
            self.setOffline(true)
        default:
            self.openGetStarted()
        }
    }
    
    @objc private func load() {
        error = nil
        setOffline(false)

        Request.shared.getUserDetails { [weak self] result in
            switch result {
            case .success(let user):
                User.current = user
                self?.loadOthers()
            case .failure(let error):
                self?.error = error
                self?.handleErrors()
            }
        }
    }
    
    private func loadOthers() {
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
        
        group.enter()
        Request.shared.getCurrentOrder { [weak self] result in
            switch result {
            case .success(let orderStatus):
                self?.order = orderStatus
            case .failure(let error):
                if case .orderNotFound = error {} else {
                    self?.error = error
                }
            }
            self?.group.leave()
        }
        
        group.notify(queue: .main) {
            self.handleErrors()
        }
    }
    
    private func setOffline(_ isOffline: Bool) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = isOffline
            self.offlineMessage.isHidden = !isOffline
            self.retryButton.isHidden = !isOffline
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
        
        let tabBarController = MainTabViewController()
        tabBarController.viewControllers = [
            navHome,
            navSearch,
            navBrowse,
            navClubs,
            navMe
        ]
        
        let currentOrderView = CurrentOrderView()
        tabBarController.view.addSubview(currentOrderView)
        
        currentOrderView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(49)
        }
        
        StatusFetcher.shared.delegate = currentOrderView
        if let order = self.order {
            StatusFetcher.shared.startFetching(id: order.id, statusOnly: true)
        }
        currentOrderView.set(order: self.order)
        currentOrderView.delegate = tabBarController
        
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

protocol CurrentOrderViewDelegate {
    func openOrder(orderId: Int)
}

class CurrentOrderView: UIView, StatusFetcherDelegate {
    public var delegate: CurrentOrderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private let topBorder = UIView()
    private let backgroundView = UIVisualEffectView()
    private let orderLabel = UILabel()
    private let statusView = UIView()
    private let statusViewLabel = UILabel()
    private let viewButton = UIButton()
    private var order: OrderStatus?
    
    public func set(order: OrderStatus?) {
        guard let order = order else {
            isHidden = true
            return
        }
        self.order = order
        isHidden = false
        orderLabel.text = "Order #\(order.id)"
        statusViewLabel.text = order.status.rawValue.capitalizingFirstLetter()
        if order.status == .declined {
            statusView.backgroundColor = UIColorFromRGB(0xEE2424)
        } else {
            statusView.backgroundColor = UIColor(named: .green)
        }
    }
    
    private func setup() {
        self.buildViews()
        self.buildConstraints()
    }
    
    func startedFetch() {

    }
    
    func stoppedFetch(with result: Result<OrderStatus>) {
        self.set(order: result.value)
    }
    
    override func layoutSubviews() {
        statusView.layer.cornerRadius = statusView.frame.height / 2
    }
    
    private func buildViews() {
        backgroundView.effect = UIBlurEffect(style: .prominent)
        addSubview(backgroundView)

        topBorder.backgroundColor = UIColorFromRGB(0xdbdbdb)
        backgroundView.contentView.addSubview(topBorder)
        
        orderLabel.font = Font.gotham(size: 17)
        orderLabel.textColor = .black
        backgroundView.contentView.addSubview(orderLabel)
        
        statusView.backgroundColor = UIColor(named: .green)
        backgroundView.contentView.addSubview(statusView)
        
        statusViewLabel.textColor = .white
        statusViewLabel.font = Font.gotham(size: 12)
        statusView.addSubview(statusViewLabel)
        
        viewButton.setTitle("View", for: .normal)
        viewButton.setTitleColor(UIColorFromRGB(0x2CC664), for: .normal)
        viewButton.setImage(#imageLiteral(resourceName: "Up Arrow").tintable, for: .normal)
        viewButton.tintColor = UIColorFromRGB(0x2CC664)
        viewButton.titleLabel?.font = Font.gotham(weight: .bold, size: 14)
        viewButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        backgroundView.contentView.addSubview(viewButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        backgroundView.contentView.addGestureRecognizer(tap)
    }
    
    @objc private func tapped() {
        if let order = self.order {
            delegate?.openOrder(orderId: order.id)
        }
    }
    
    private func buildConstraints() {
        topBorder.snp.makeConstraints { make in 
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        orderLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(24)
        }
        
        statusView.snp.makeConstraints { make in
            make.left.equalTo(orderLabel.snp.right).offset(8)
            make.centerY.equalTo(orderLabel.snp.centerY)
        }
        
        statusViewLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        viewButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(24)
        }
    }
}

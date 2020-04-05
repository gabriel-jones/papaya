//
//  ExpressViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/10/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class ExpressViewController: UIViewController {
    
    public var isModal = false
    
    private let activityIndicator = LoadingView()
    private let retryButton = UIButton()
    
    override func viewDidLoad() {
        self.buildViews()
        self.buildConstraints()
        
        self.load()
    }
    
    private func switchToViewController(_ vc: UIViewController) {
        addChildViewController(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        vc.didMove(toParentViewController: self)
    }
    
    private func showHub(_ subscription: Subscription) {
        let vc = SubscriptionHubViewController()
        vc.subscription = subscription
        vc.isExpress = true
        switchToViewController(vc)
        navigationItem.title = "Papaya Express Subscription"
    }
    
    private func showBuy() {
        let vc = ExpressBuyViewController()
        switchToViewController(vc)
    }
    
    @objc private func load() {
        activityIndicator.startAnimating()
        hideMessage()
        retryButton.isHidden = true
        Request.shared.getExpressDetails { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let subscription):
                self.showHub(subscription)
            case .failure(let error):
                if case .expressRequired = error {
                    self.showBuy()
                } else {
                    self.retryButton.isHidden = false
                    self.showMessage("Can't load", type: .error, options: [
                        .autoHide(false),
                        .hideOnTap(false)
                    ])
                }
            }
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func buildViews() {
        view.backgroundColor = .white
        
        if isModal {
            let close = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            close.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = close
        }
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(load), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    private func buildConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
}

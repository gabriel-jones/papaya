//
//  GetStartedVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import Hero
import CHIPageControl

class GetStartedVC: UIViewController {
    
    private let logoView = UIView()
    private let logoName = UILabel()
    private let logoImage = UIImageView()
    private let loginButton = UIButton()
    private let scrollView = UIScrollView()
    private let pageIndicator = CHIPageControlJaloro()
    private let getStartedButton = UIButton()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.gradientBackground()
        
        logoImage.image = #imageLiteral(resourceName: "Logo")
        logoView.addSubview(logoImage)
        logoName.text = "Papaya"
        logoName.font = Font.gotham(weight: .bold, size: 25)
        logoName.textColor = .white
        logoView.addSubview(logoName)
        logoView.heroID = "logoView"
        view.addSubview(logoView)
        
        loginButton.backgroundColor = .white
        loginButton.setTitleColor(UIColor(named: .green), for: .normal)
        loginButton.setTitle("Log in", for: .normal)
        loginButton.titleLabel?.font = Font.gotham(size: 14)
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        view.addSubview(loginButton)
        
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
        
        pageIndicator.elementWidth = view.frame.width / 5
        pageIndicator.elementHeight = 3
        pageIndicator.padding = 10
        pageIndicator.numberOfPages = 4
        pageIndicator.radius = 2
        pageIndicator.currentPageTintColor = .white
        pageIndicator.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        view.addSubview(pageIndicator)
        
        getStartedButton.backgroundColor = .white
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.setTitleColor(UIColor(named: .green), for: .normal)
        getStartedButton.titleLabel?.font = Font.gotham(weight: .bold, size: 16)
        getStartedButton.layer.cornerRadius = 10
        getStartedButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        getStartedButton.addTarget(self, action: #selector(signup(_:)), for: .touchUpInside)
        view.addSubview(getStartedButton)
    }
    
    private func buildConstraints() {
        logoImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
            make.height.equalTo(40)
            make.width.equalTo(logoImage.snp.height)
        }
        
        logoName.snp.makeConstraints { make in
            make.top.bottom.centerY.equalToSuperview()
            make.width.equalTo(92)
            make.left.equalTo(logoImage.snp.right).offset(16)
        }
        
        logoView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leadingMargin).offset(8)
            make.top.equalTo(view.snp.topMargin).offset(8)
            make.height.equalTo(50)
            make.width.equalTo(168)
        }
        
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.trailing.equalTo(view.snp.trailingMargin)
            make.centerY.equalTo(logoView.snp.centerY)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(24)
            make.leading.equalTo(view.snp.leadingMargin)
            make.trailing.equalTo(view.snp.trailingMargin)
            make.bottom.equalTo(pageIndicator.snp.top).offset(-8)
        }
        
        pageIndicator.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.trailing.equalTo(view.snp.trailingMargin)
            make.leading.equalTo(view.snp.leadingMargin)
            make.bottom.equalTo(getStartedButton.snp.top).offset(-16)
        }
        
        getStartedButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.equalTo(view.snp.leadingMargin).offset(32)
            make.trailing.equalTo(view.snp.trailingMargin).offset(-32)
            make.bottom.equalTo(view.snp.bottom).offset(-20)
        }
    }
    
    @objc func login(_ sender: UIButton) {
        let loginVC = LoginVC()
        loginVC.heroModalAnimationType = .cover(direction: .right)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc func signup(_ sender: UIButton) {
        let signupVC = SignupVC()
        signupVC.heroModalAnimationType = .cover(direction: .left)
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
}

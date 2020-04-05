//
//  ClubsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/27/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import UIImageViewAlignedSwift

class ClubCollectionViewCell: UICollectionViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.clubCell.rawValue
    
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()
    private let imageView = UIImageViewAligned()
    private let memberBadge = UIView()
    private let memberBadgeGradient = CAGradientLayer()
    private let memberLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        layer.cornerRadius = 10
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        backgroundColor = .white
        masksToBounds = false
        
        imageView.alignment = .bottomRight
        imageView.contentMode = .scaleAspectFit
        imageView.masksToBounds = true
        imageView.layer.cornerRadius = 10
        addSubview(imageView)
        
        subtitleLabel.textColor = .gray
        subtitleLabel.font = Font.gotham(weight: .bold, size: 10)
        addSubview(subtitleLabel)
        
        titleLabel.font = Font.gotham(weight: .bold, size: 23)
        addSubview(titleLabel)
        
        memberBadge.masksToBounds = true
        memberBadge.isHidden = true
        addSubview(memberBadge)
        
        memberBadgeGradient.colors = [UIColorFromRGB(0x00d44d), UIColor(named: .turquoise)].map { $0.cgColor }
        memberBadgeGradient.startPoint = CGPoint(x: 0, y: 1)
        memberBadgeGradient.endPoint = CGPoint(x: 1, y: 0)
        memberBadge.layer.insertSublayer(memberBadgeGradient, at: 1)
        
        memberLabel.text = "MEMBER"
        memberLabel.textColor = .white
        memberLabel.textAlignment = .center
        memberLabel.font = Font.gotham(weight: .bold, size: 10)
        memberBadge.addSubview(memberLabel)
    }
    
    private func buildConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
        }
        
        memberBadge.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(subtitleLabel.snp.centerY)
            make.height.equalTo(25)
        }
        
        memberLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(32)
        }
    }
    
    public func load(club: Club) {
        titleLabel.text = club.name
        subtitleLabel.text = club.specialStatus?.uppercased() ?? "RECOMMENDED FOR YOU" // Super-intelligent recommendation system
        
        if let url = club.img {
            imageView.pin_setImage(from: url)
        }
        
        if club.isMember {
            memberBadge.isHidden = false
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        memberBadgeGradient.frame = memberBadge.bounds
        
        let path = UIBezierPath(roundedRect: memberBadge.bounds, byRoundingCorners:[.topLeft, .bottomLeft], cornerRadii: CGSize(width: 7, height: 7))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        memberBadge.layer.mask = maskLayer
    }
}

class ClubsViewController: ViewControllerWithCart {
    
    private var clubs = [Club]()
    
    private var collectionView: UICollectionView!
    private let activityIndicator = LoadingView()
    private let retryButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        self.loadClubs()
    }
    
    @objc private func loadClubs() {
        self.retryButton.isHidden = true
        self.collectionView.isHidden = true
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        Request.shared.getAllClubs() { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let clubs):
                self.clubs = clubs
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
                self.hideMessage()
            case .failure(_):
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch clubs", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.navigationBar.tintColor = UIColor(named: .green)
        navigationItem.title = "Clubs"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        layout.minimumLineSpacing = 24
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ClubCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ClubCollectionViewCell.identifier)
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadClubs), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    private func buildConstraints() {
        collectionView.snp.makeConstraints { make in
            if BaseStore.order == nil {
                make.edges.equalToSuperview()
            } else {
                make.top.left.right.equalToSuperview()
                if #available(iOS 11, *) {
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(49)
                } else {
                    make.bottom.equalToSuperview().inset(99)
                }
            }
        }
        
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

extension ClubsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ClubsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clubs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClubCollectionViewCell.identifier, for: indexPath) as! ClubCollectionViewCell
        cell.load(club: clubs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ClubViewController()
        vc.club = clubs[indexPath.row]
        present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 48, height: 280)
    }
}

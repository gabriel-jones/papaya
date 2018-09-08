//
//  BrowseVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class BrowseViewController: ViewControllerWithCart {
    
    private var departments = [Category]() {
        didSet {
            for (j, cat) in departments.enumerated() {
                if cat.isSpecial {
                    departments.swapAt(0, j)
                }
            }
        }
    }
    
    private var collectionView: UICollectionView!
    private let activityIndicator = LoadingView()
    private let retryButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        self.loadCategories()
    }
    
    @objc private func loadCategories() {
        self.retryButton.isHidden = true
        self.collectionView.isHidden = true
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        Request.shared.getAllCategories() { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let categories):
                self.departments = categories
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
                self.hideMessage()
            case .failure(_):
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch departments", type: .error, options: [
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
        navigationItem.title = "Browse"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BrowseCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: BrowseCollectionViewCell.identifier)
        collectionView.register(BrowseSpecialCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: BrowseSpecialCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadCategories), for: .touchUpInside)
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
                make.bottom.equalToSuperview().inset(99)
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

extension BrowseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension BrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let department = departments[indexPath.row]
        if department.isSpecial {
            let vc = SpecialCategoryViewController()
            vc.category = department
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = CategoryViewController()
        vc.category = department
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return departments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let department = departments[indexPath.row]
        if department.isSpecial {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowseSpecialCollectionViewCell.identifier, for: indexPath) as! BrowseSpecialCollectionViewCell
            cell.load(category: department)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowseCollectionViewCell.identifier, for: indexPath) as! BrowseCollectionViewCell
        cell.load(category: department)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let department = departments[indexPath.row]
        if department.isSpecial {
            return CGSize(width: collectionView.frame.width - 32, height: 150)
        }
        let w = (collectionView.frame.width / 2) - 25
        return CGSize(width: w, height: w)
    }
}

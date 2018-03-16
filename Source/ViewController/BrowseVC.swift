//
//  BrowseVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RxSwift

class BrowseVC: ViewControllerWithCart {
    
    private var departments = [Category]()
    
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView()

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        self.loadCategories { _ in
            self.collectionView.isHidden = false
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func loadCategories(_ completion: @escaping (Bool) -> Void) {
        Request.shared.getAllCategories()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { categories in
                self.departments = categories
                self.collectionView.reloadData()
                completion(true)
            }, onError: { error in
                print(error.localizedDescription)
                completion(false)
            })
            .disposed(by: disposeBag)
    }

    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationController?.navigationBar.tintColor = UIColor(named: .green)
        navigationItem.title = "Browse"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BrowseCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: BrowseCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.isHidden = true
        view.addSubview(collectionView)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func buildConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension BrowseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CategoryVC()
        vc.category = departments[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return departments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowseCollectionViewCell.identifier, for: indexPath) as! BrowseCollectionViewCell
        let dep = departments[indexPath.row]
        cell.load(category: dep)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 25, height: 150)
    }
}

//
//  ItemGroupVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/24/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import RxSwift
import UIKit

class ItemGroupViewController: ViewControllerWithCart {
    
    public var items: Observable<[Item]>!
    public var groupTitle: String!
    
    private var loadedItems = [Item]()
    private let disposeBag = DisposeBag()
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView()
    private let sectionBar = UIView()
    private let bottomBorder = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.buildBindings()
    }
    
    private func buildViews() {
        isHeroEnabled = true
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = groupTitle
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = true
        view.addSubview(collectionView)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        sectionBar.backgroundColor = .white
        view.addSubview(sectionBar)
        
        bottomBorder.backgroundColor = .lightGray
        sectionBar.addSubview(bottomBorder)
    }
    
    private func buildConstraints() {
        sectionBar.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(sectionBar.snp.bottom)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        bottomBorder.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    private func buildBindings() {
        items
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { items in
            self.loadedItems = items
            self.activityIndicator.stopAnimating()
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
            print("Got items: \(items.count)")
        }, onError: { error in
            
        })
        .disposed(by: disposeBag)
    }
}

extension ItemGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        let item = loadedItems[indexPath.row]
        cell.load(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ItemVC()
        vc.item = loadedItems[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
            vc.imageId = cell.getImageId()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        present(nav, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 24, height: 200)
    }
}

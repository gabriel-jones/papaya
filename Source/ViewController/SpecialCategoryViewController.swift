//
//  SpecialCategoryViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/3/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import TagListView

class SpecialCategoryViewController: ViewControllerWithCart {
    
    public var category: Category?
    
    private var items = PaginatedResults<SpecialItem>(isLast: false, results: [SpecialItem]())
    private var page = 1
    private let group = DispatchGroup()

    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView()
    private let retryButton = UIButton()
    
    @objc private func loadCategory() {
        guard let category = category else {
            return
        }
        /*
        Request.shared.getClub(clubId: category.specialClubId!) { result in
            switch result {
            case .success(let club):
                
            case .failure(let error):
                
            }
        }*/
        
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        retryButton.isHidden = true
        collectionView.isHidden = true
        Request.shared.getSpecialItems(category: category, page: page) { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let items):
                self.items = items
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
                self.collectionView.isUserInteractionEnabled = true
                self.hideMessage()
            case .failure(let error):
                print(error.localizedDescription)
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch department", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.loadCategory()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.title = category?.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsSelection = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.isUserInteractionEnabled = false
        collectionView.register(ItemSpecialCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemSpecialCollectionViewCell.identifier)
        view.addSubview(collectionView)
        
        collectionView.addInfiniteScroll { [unowned self] collectionView in
            print("load next page")
        }
        
        collectionView.setShouldShowInfiniteScrollHandler { [unowned self] _ -> Bool in
            return !self.items.isLast
        }
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadCategory), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    private func buildConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
}

extension SpecialCategoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SpecialCategoryViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
    }
}

extension SpecialCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !items.isLast && items.results.isEmpty {
            return 6
        }
        return items.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemSpecialCollectionViewCell.identifier, for: indexPath) as! ItemSpecialCollectionViewCell
        cell.delegate = self
        if !items.isLast && items.results.isEmpty {
            cell.setIsTemplate(true)
        } else {
            cell.load(item: items.results[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*
        let vc = ItemViewController()
        vc.item = items.results[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemSpecialCollectionViewCell {
            vc.imageId = cell.getImageId()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .auto, dismissing: .uncover(direction: .down))
        present(nav, animated: true, completion: nil)
        */
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 24, height: 300)
    }
}

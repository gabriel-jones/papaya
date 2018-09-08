//
//  ItemGroupVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/24/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

// This sucks, sorry
enum ItemGroupRequestType {
    case common
    case recent
    case liked
    case of(category: Category)
    case featured(from: Category)
    case similar(to: Item)
    case cartSuggestions
    case todaysSpecials
    case recommended
}

class ItemGroupViewController: ViewControllerWithCart {
    
    public var groupTitle: String!
    public var items: ItemGroupRequestType!
    
    private var page = 1
    
    private var loadedItems: PaginatedResults<Item> = PaginatedResults(isLast: false, results: [Item]())
    
    private var collectionView: UICollectionView!
    private let sectionBar = UIView()
    private let bottomBorder = UIView()
    private let retryButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.initialLoad()
    }
    
    private func executeRequest(_ completion: @escaping ((Result<PaginatedResults<Item>>) -> Void)) {
        switch self.items! {
        case .common:
            Request.shared.getCommonItems(page: page, completion: completion)
        case .recent:
            Request.shared.getRecentItems(page: page, completion: completion)
        case .liked:
            Request.shared.getLikedItems(page: page, completion: completion)
        case .of(let category):
            Request.shared.getItems(category: category, page: page, completion: completion)
        case .similar(let item):
            Request.shared.getSimilarItems(toItem: item, page: page, completion: completion)
        case .featured(let category):
            Request.shared.getFeaturedItems(forCategory: category, page: page, completion: completion)
        case .cartSuggestions:
            Request.shared.getCartSuggestions(page: page, completion: completion)
        case .todaysSpecials:
            Request.shared.getTodaysSpecials(page: page, completion: completion)
        case .recommended:
            Request.shared.getRecommendedItems(page: page, completion: completion)
        }
    }
    
    private func buildViews() {
        isHeroEnabled = true
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = groupTitle
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.isUserInteractionEnabled = false
        view.addSubview(collectionView)
        
        collectionView.addInfiniteScroll { [unowned self] collectionView in
            self.loadItems()
        }
        
        collectionView.setShouldShowInfiniteScrollHandler { [unowned self] _ -> Bool in
            return !self.loadedItems.isLast
        }
        
        sectionBar.backgroundColor = .white
        view.addSubview(sectionBar)
        
        bottomBorder.backgroundColor = .lightGray
        sectionBar.addSubview(bottomBorder)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(initialLoad), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    private func load(_ completion: @escaping ((PaginatedResults<Item>?, Error?) -> Void)) {
        retryButton.isHidden = true
        collectionView.isHidden = false
        self.executeRequest { result in
            switch result {
            case .success(let paginatedResults):
                self.hideMessage()
                completion(paginatedResults, nil)
            case .failure(let error):
                self.showMessage("Can't fetch groceries", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
                completion(nil, error)
            }
        }
    }
    
    @objc private func initialLoad() {
        self.load { paginatedResults, error in
            guard let paginatedResults = paginatedResults, error == nil else {
                self.collectionView.isHidden = true
                self.retryButton.isHidden = false
                return
            }
            self.loadedItems.combine(with: paginatedResults)
            self.collectionView.reloadData()
            self.collectionView.isUserInteractionEnabled = true
            self.page += 1
        }
    }
    
    private func loadItems() {
        self.load { paginatedResults, error in
            guard let paginatedResults = paginatedResults else {
                return
            }
            self.collectionView.performBatchUpdates({
                let (start, end) = (self.loadedItems.results.count, self.loadedItems.results.count + paginatedResults.results.count)
                let indexPaths = (start..<end).map { IndexPath(row: $0, section: 0)}
                self.loadedItems.combine(with: paginatedResults)
                self.collectionView.insertItems(at: indexPaths)
            }, completion: { finished in
                self.page += 1
                self.collectionView.finishInfiniteScroll()
            })
        }
    }
    
    private func buildConstraints() {
        sectionBar.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            if BaseStore.order == nil {
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(sectionBar.snp.bottom)
            } else {
                make.left.right.equalToSuperview()
                make.top.equalTo(sectionBar.snp.bottom)
                make.bottom.equalToSuperview().inset(99)
            }
        }
        
        bottomBorder.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
}

extension ItemGroupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ItemGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !loadedItems.isLast && loadedItems.results.isEmpty {
            return 6
        }
        return loadedItems.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        if !loadedItems.isLast && loadedItems.results.isEmpty {
            cell.loadTemplate()
        } else {
            cell.load(item: loadedItems.results[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ItemViewController()
        vc.item = loadedItems.results[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
            vc.imageId = cell.getImageId()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .auto, dismissing: .uncover(direction: .down))
        present(nav, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 24, height: 200)
    }
}

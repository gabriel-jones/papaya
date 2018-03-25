//
//  SearchVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RxSwift

class SearchViewController: ViewControllerWithCart {
    
    private lazy var searchBar = UISearchBar()
    private var backButton: UIBarButtonItem?
    private let popularTableView = UITableView(frame: .zero, style: .grouped)
    private let recommendTableView = UITableView(frame: .zero, style: .grouped)
    private var collectionView: UICollectionView!
    
    private let popularModel = SearchPopularModel()
    private let recommendModel = SearchRecommendModel()
    private let itemsModel = SearchItemsModel()
    
    private var isLoadingPopular = false
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.buildModels()
        
        isLoadingPopular = true
        Request.shared.popularSearches()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { searches in
                self.isLoadingPopular = false
                self.popularModel.searches = searches
                self.popularTableView.reloadData()
            }, onError: { error in
                
            })
            .disposed(by: disposeBag)
    }
    
    private func buildModels() {
        popularModel.delegate = self
        recommendModel.delegate = self
        itemsModel.delegate = self
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        popularTableView.backgroundColor = .clear
        popularTableView.delegate = popularModel
        popularTableView.dataSource = popularModel
        popularTableView.register(SearchTableViewCell.classForCoder(), forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.addSubview(popularTableView)
        
        recommendTableView.backgroundColor = .clear
        recommendTableView.isHidden = true
        recommendTableView.delegate = recommendModel
        recommendTableView.dataSource = recommendModel
        recommendTableView.register(SearchTableViewCell.classForCoder(), forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.addSubview(recommendTableView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        collectionView.delegate = itemsModel
        collectionView.dataSource = itemsModel
        collectionView.alwaysBounceVertical = true
        collectionView.register(ItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        collectionView.infiniteScrollTriggerOffset = 200
        view.addSubview(collectionView)
        
        collectionView.addInfiniteScroll { collectionView in
            collectionView.performBatchUpdates({
                // update collection view
            }, completion: { finished in
                // finish infinite scroll animations
                collectionView.finishInfiniteScroll()
            });
        }
        
        collectionView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            // Only show up to 5 pages then prevent the infinite scroll
            return currentPage < 5
        }
        
        searchBar.placeholder = "Search for an item..."
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor(named: .green)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Left Arrow").tintable, style: .done, target: self, action: #selector(back(_:)))
        backButton?.tintColor = UIColor(named: .green)
    }
    
    private func buildConstraints() {
        popularTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        recommendTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func changeToSearchDetail() {
        navigationItem.leftBarButtonItem = backButton
        collectionView.isHidden = true
        popularTableView.isHidden = true
        recommendTableView.isHidden = false
    }
    
    private func changeToSearchMain() {
        navigationItem.leftBarButtonItem = nil
        collectionView.isHidden = true
        popularTableView.isHidden = false
        recommendTableView.isHidden = true
    }
    
    private func changeToSearchItems(search: String) {
        navigationItem.leftBarButtonItem = backButton
        collectionView.isHidden = false
        popularTableView.isHidden = true
        recommendTableView.isHidden = true
        searchBar.text = search
        Request.shared.search(query: search)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { searchItems in
                print("got back: \(searchItems.count)")
                self.itemsModel.items = searchItems
                self.collectionView.reloadData()
            }, onError: { error in
                
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func back(_ sender: UIBarButtonItem) {
        self.changeToSearchMain()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.changeToSearchItems(search: searchBar.text!)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.changeToSearchDetail()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.changeToSearchMain()
    }
}

extension SearchViewController: SearchModelDelegate {
    func selectPopular(keyword: String) {
        self.changeToSearchItems(search: keyword)
    }
    
    func selectRecommended(keyword: String) {
        self.changeToSearchItems(search: keyword)
    }
    
    func open(item: Item, imageId: String?) {
        let vc = ItemVC.instantiate(from: .main)
        vc.item = item
        vc.imageId = imageId
        heroModalAnimationType = .cover(direction: .up)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        present(nav, animated: true, completion: nil)
    }
}

protocol SearchModelDelegate: class {
    func selectPopular(keyword: String)
    func selectRecommended(keyword: String)
    func open(item: Item, imageId: String?)
}

class SearchModel: NSObject {
    public var delegate: SearchModelDelegate?
}

class SearchPopularModel: SearchModel, UITableViewDelegate, UITableViewDataSource {
    
    public var searches = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches.isEmpty ? 16 : searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
        if searches.isEmpty {
            cell.loadTemplate()
        } else {
            cell.load(search: searches[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searches.isEmpty { return nil }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.selectPopular(keyword: searches[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Popular"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Font.gotham(size: header.textLabel!.font.pointSize)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

class SearchRecommendModel: SearchModel, UITableViewDelegate, UITableViewDataSource {
    
    public var recommended = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommended.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
        cell.load(search: recommended[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.selectRecommended(keyword: recommended[indexPath.row]) // TODO:
    }
}

class SearchItemsModel: SearchModel, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var items = [Item]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.isEmpty ? 8 : items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        if items.isEmpty {
            cell.loadTemplate()
        } else {
            cell.load(item: items[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 24, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        var imageId: String?
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
            imageId = cell.getImageId()
        }
        delegate?.open(item: item, imageId: imageId)
    }
    
}

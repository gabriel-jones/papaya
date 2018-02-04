//
//  SearchVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class SearchViewController: ViewControllerWithCart {
    
    private lazy var searchBar = UISearchBar()
    private var backButton: UIBarButtonItem?
    private let popularTableView = UITableView(frame: .zero, style: .grouped)
    private let recommendTableView = UITableView(frame: .zero, style: .grouped)
    private var collectionView: UICollectionView!
    
    private let popularModel = SearchPopularModel()
    private let recommendModel = SearchRecommendModel()
    private let itemsModel = SearchItemsModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        popularTableView.backgroundColor = .clear
        popularTableView.delegate = popularModel
        popularTableView.dataSource = popularModel
        popularTableView.register(UITableViewCell.self, forCellReuseIdentifier: C.ViewModel.CellIdentifier.searchPopularCell.rawValue)
        view.addSubview(popularTableView)
        
        recommendTableView.backgroundColor = .clear
        recommendTableView.isHidden = true
        recommendTableView.delegate = recommendModel
        recommendTableView.dataSource = recommendModel
        recommendTableView.register(UITableViewCell.self, forCellReuseIdentifier: C.ViewModel.CellIdentifier.searchRecommendCell.rawValue)
        view.addSubview(recommendTableView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        collectionView.delegate = itemsModel
        collectionView.dataSource = itemsModel
        view.addSubview(collectionView)
        
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
    }
    
    private func changeToSearchMain() {
        navigationItem.leftBarButtonItem = nil
    }
    
    private func changeToSearchItems() {
        
    }
    
    @objc private func back(_ sender: UIBarButtonItem) {
        self.changeToSearchMain()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.changeToSearchItems()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.changeToSearchDetail()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.changeToSearchMain()
    }
}

protocol SearchModelDelegate {
    func selectPopular(keyword: String)
    func selectRecommended(keyword: String)
}

class SearchModel: NSObject {
    public var delegate: SearchModelDelegate?
}

class SearchPopularModel: SearchModel, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.searchPopularCell.rawValue, for: indexPath)
        cell.textLabel?.text = "search thing"
        cell.textLabel?.font = Font.gotham(size: cell.textLabel!.font.pointSize)
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = #imageLiteral(resourceName: "Search").tintable
        cell.imageView?.tintColor = UIColor.darkGray
        cell.separatorInset.left = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectPopular(keyword: "") // TODO:
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Popular"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Font.gotham(size: header.textLabel!.font.pointSize)
    }
}

class SearchRecommendModel: SearchModel, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.searchRecommendCell.rawValue, for: indexPath)
        cell.textLabel?.text = "search thing"
        cell.textLabel?.font = Font.gotham(size: cell.textLabel!.font.pointSize)
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = #imageLiteral(resourceName: "Search").tintable
        cell.imageView?.tintColor = UIColor.darkGray
        cell.separatorInset.left = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectRecommended(keyword: "") // TODO:
    }
}

class SearchItemsModel: SearchModel, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        
        return cell
    }
}

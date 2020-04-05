//
//  SimilarItemsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/30/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

protocol SimilarItemsViewControllerDelegate {
    func didChoose(item: Item)
}

class SimilarItemsViewController: UIViewController {
    
    public var itemToCompare: Item!
    public var delegate: SimilarItemsViewControllerDelegate?
    
    private var items = PaginatedResults<Item>(isLast: false, results: [Item]())

    private var collectionView: UICollectionView!
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.loadSimilarForItem()
    }
    
    func loadSimilarForItem() {
        Request.shared.getSimilarItems(toItem: itemToCompare) { result in
            switch result {
            case .success(let paginatedResults):
                self.items = paginatedResults
                self.collectionView.reloadData()
            case .failure(_):
                self.showMessage("Can't fetch similar items", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    func loadSimilarForSearch(_ search: String) {
        Request.shared.search(query: search) { result in
            switch result {
            case .success(let items):
                self.items = items
                self.collectionView.reloadData()
            case .failure(_):
                self.showMessage("Can't fetch search results", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Possible Replacements"
        searchController.searchBar.searchBarStyle = .minimal
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SearchEmptyCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: SearchEmptyCollectionViewCell.identifier)
        collectionView.register(ItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        view.addSubview(collectionView)
    }
    
    private func buildConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.dismiss(animated: false, completion: nil)
    }
}

extension SimilarItemsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            self.loadSimilarForItem()
        }
        searchController.dismiss(animated: true, completion: nil)
        self.loadSimilarForSearch(searchBar.text!)
    }
}

extension SimilarItemsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if items.isLast && items.results.isEmpty {
            return 1
        } else if items.results.isEmpty {
            return 8
        }
        return items.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if items.isLast && items.results.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchEmptyCollectionViewCell.identifier, for: indexPath) as! SearchEmptyCollectionViewCell
            cell.query = self.searchController.searchBar.text!
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        if items.results.isEmpty {
            cell.loadTemplate()
        } else {
            cell.load(item: items.results[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if items.isLast && items.results.isEmpty {
            return CGSize(width: collectionView.frame.width, height: 200)
        }
        return CGSize(width: (collectionView.frame.width / 2) - 24, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didChoose(item: items.results[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

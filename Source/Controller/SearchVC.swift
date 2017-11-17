//
//  SearchVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class SearchVC: TabChildVC {
    
    //MARK: - Properties
    var searchController: UISearchController!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: - Outlets
    @IBOutlet weak var filterToolbar: UIToolbar!

    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterButton = UIButton(type: .custom)
        filterButton.setTitle("Filter", for: .normal)
        filterButton.setImage(#imageLiteral(resourceName: "Filter").withRenderingMode(.alwaysTemplate), for: .normal)
        filterButton.tintColor = Color.green
        filterButton.setTitleColor(Color.green, for: .normal)
        filterButton.titleLabel?.font = Font.gotham(size: 15)
        
        let sortButton = UIButton(type: .custom)
        sortButton.setTitle("Sort", for: .normal)
        sortButton.setImage(#imageLiteral(resourceName: "Sort").withRenderingMode(.alwaysTemplate), for: .normal)
        sortButton.tintColor = Color.green
        sortButton.setTitleColor(Color.green, for: .normal)
        sortButton.titleLabel?.font = Font.gotham(size: 15)
        
        let filter = UIBarButtonItem(customView: filterButton)
        let sort = UIBarButtonItem(customView: sortButton)
        
        filterToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            filter,
            sort
        ]
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: filterToolbar.frame.height-0.5, width: filterToolbar.frame.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        bottomBorder.zPosition = 100
        filterToolbar.layer.addSublayer(bottomBorder)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.tintColor = Color.grey.3
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchController.searchBar)
        
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem?.setBackgroundVerticalPositionAdjustment(5, for: .default)
    }
}

extension SearchVC: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update search results")
    }
}

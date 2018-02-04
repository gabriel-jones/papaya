//
//  SimilarItemsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/30/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import RxSwift

protocol SimilarItemsViewControllerDelegate {
    func didChoose(item: Item)
}

class SimilarItemsViewController: UIViewController {
    
    public var itemToCompare: Item!
    public var delegate: SimilarItemsViewControllerDelegate?
    
    private var similar = [Item]()
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView()
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.loadSimilarForItem()
    }
    
    func loadSimilarForItem() {
        Request.shared.getAllItemsTemp()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] items in
                self.similar = items
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }, onError: { error in
                
            })
            .disposed(by: disposeBag)
    }
    
    func loadSimilarForSearch(_ search: String) {
        Request.shared.getAllItemsTemp()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] items in
                self.similar = items
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                }, onError: { error in
                    
            })
            .disposed(by: disposeBag)
    }
    
    private func buildViews() {
        view.backgroundColor = .white
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Possible Replacements"
        searchController.searchBar.searchBarStyle = .minimal
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        
        tableView.showsVerticalScrollIndicator = true
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: C.ViewModel.CellIdentifier.similarItemCell.rawValue)
        view.addSubview(tableView)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        tableView.addSubview(activityIndicator)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(50)
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
        print("search: " + searchBar.text!)
    }
}

extension SimilarItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.similarItemCell.rawValue, for: indexPath)
        let item = similar[indexPath.row]
        cell.textLabel?.text = item.name
        cell.textLabel?.font = Font.gotham(size: 15)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = item.price.currencyFormat
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = Font.gotham(size: 13)
        cell.imageView?.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        cell.imageView?.tintColor = .gray
        cell.imageView?.backgroundColor = UIColor(named: .backgroundGrey)
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.contentMode = .center
        cell.imageView?.pin_setImage(from: item.img) { result in
            if result.error == nil {
                cell.imageView?.backgroundColor = .clear
                cell.imageView?.layer.cornerRadius = 0
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        }
        cell.separatorInset = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didChoose(item: similar[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

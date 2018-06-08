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
    private let retryButton = UIButton()

    private let popularModel = SearchPopularModel()
    private let recommendModel = SearchRecommendModel()
    private let itemsModel = SearchItemsModel()
    
    private var isLoadingPopular = false
    private var recommended = [String]()
    private var query = String()
    
    private var searchRequest: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.buildModels()
        
        isLoadingPopular = true
        
        Request.shared.popularSearches { result in
            switch result {
            case .success(let searches):
                self.isLoadingPopular = false
                self.popularModel.searches = searches
                self.popularTableView.reloadSections(IndexSet(integer: 0), with: .fade)
            case .failure(let error):
                print(error.localizedDescription)
                self.showMessage("Can't fetch searches", type: .error)
            }
        }
        
        Request.shared.autocompletion { result in
            switch result {
            case .success(let searches):
                self.recommended = searches
            case .failure(let error):
                print(error.localizedDescription)
                self.showMessage("Can't fetch searches", type: .error)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        searchBar.resignFirstResponder()
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
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SearchEmptyCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: SearchEmptyCollectionViewCell.identifier)
        collectionView.register(ItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        view.addSubview(collectionView)
        
        /*
        collectionView.addInfiniteScroll { [unowned self] collectionView in
            self.search { result in
                switch result {
                case .success(let paginatedResults):
                    self.collectionView.performBatchUpdates({
                        let (start, end) = (self.loadedItems.results.count, self.loadedItems.results.count + paginatedResults.results.count)
                        let indexPaths = (start..<end).map { IndexPath(row: $0, section: 0)}
                        self.loadedItems.combine(with: paginatedResults)
                        collectionView.insertItems(at: indexPaths)
                    }, completion: { finished in
                        self.page += 1
                        collectionView.finishInfiniteScroll()
                    })
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        collectionView.setShouldShowInfiniteScrollHandler { [unowned self] _ -> Bool in
            return !self.loadedItems.isLast
        }*/
        
        
        searchBar.placeholder = "Search for an item..."
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor(named: .green)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Left Arrow").tintable, style: .done, target: self, action: #selector(back(_:)))
        backButton?.tintColor = UIColor(named: .green)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadItems), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
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
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    private func changeBackButton(add: Bool) {
        self.navigationItem.leftBarButtonItem?.customView?.transform = add ? CGAffineTransform.identity : CGAffineTransform(translationX: -50, y: 0)
        self.navigationItem.leftBarButtonItem = add ? self.backButton : nil
    }
    
    private func changeToSearchDetail() {
        retryButton.isHidden = true
        hideMessage()
        changeBackButton(add: true)
        collectionView.isHidden = true
        popularTableView.isHidden = true
        recommendTableView.isHidden = false
    }
    
    private func changeToSearchMain() {
        retryButton.isHidden = true
        hideMessage()
        changeBackButton(add: false)
        collectionView.isHidden = true
        popularTableView.isHidden = false
        recommendTableView.isHidden = true
        view.endEditing(true)
        searchBar.resignFirstResponder()
        popularTableView.frame.origin.x = -view.frame.width
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.frame.origin.x = self.view.frame.width
            self.popularTableView.frame.origin.x = 0
        }, completion: { _ in
            self.collectionView.frame.origin.x = 0
        })
    }
    
    private func changeToSearchItems(search: String) {
        searchRequest?.cancel()
        changeBackButton(add: true)
        collectionView.isHidden = false
        popularTableView.isHidden = true
        recommendTableView.isHidden = true
        searchBar.text = search
        view.endEditing(true)
        searchBar.resignFirstResponder()
        collectionView.frame.origin.x = view.frame.width
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.frame.origin.x = 0
            self.popularTableView.frame.origin.x = -self.view.frame.width
            self.recommendTableView.frame.origin.x = -self.view.frame.width
        }, completion: { _ in
            self.popularTableView.frame.origin.x = 0
            self.recommendTableView.frame.origin.x = 0
        })
        self.query = search
        self.loadItems()
    }
    
    @objc private func loadItems() {
        collectionView.isHidden = false
        collectionView.isUserInteractionEnabled = false
        itemsModel.query = self.query
        retryButton.isHidden = true
        searchRequest = Request.shared.search(query: self.query, page: 1) { result in
            switch result {
            case .success(let paginatedItems):
                self.hideMessage()
                self.collectionView.isUserInteractionEnabled = true
                self.itemsModel.items = paginatedItems
                self.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
                self.retryButton.isHidden = false
                self.collectionView.isHidden = true
                self.itemsModel.items = PaginatedResults(isLast: false, results: [Item]())
                self.collectionView.reloadData()
                self.showMessage("Can't fetch search results", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    @objc private func back(_ sender: UIBarButtonItem) {
        self.searchBar.text = ""
        self.changeToSearchMain()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.changeToSearchItems(search: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.changeToSearchDetail()
        recommendModel.recommended = recommendedFor(searchTerm: searchText)
        recommendTableView.reloadData()
    }
    
    public func recommendedFor(searchTerm: String) -> [String] {
        return Array(recommended.filter {
            $0.range(of: searchTerm, options: .caseInsensitive) != nil
        }.sorted {
            let range1 = $0.range(of: searchTerm, options: .caseInsensitive)
            let range2 = $1.range(of: searchTerm, options: .caseInsensitive)
            
            return range1!.lowerBound < range2!.lowerBound
        }.prefix(8))
    }
}

extension SearchViewController: SearchModelDelegate {
    func selectPopular(keyword: String) {
        self.changeToSearchItems(search: keyword)
    }
    
    func selectRecommended(keyword: String) {
        self.changeToSearchItems(search: keyword)
    }
    
    func openItem(item: Item, imageId: String?) {
        let vc = ItemViewController()
        vc.item = item
        vc.imageId = imageId
        heroModalAnimationType = .cover(direction: .up)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .auto, dismissing: .uncover(direction: .down))
        present(nav, animated: true, completion: nil)
    }
}

protocol SearchModelDelegate: class {
    func selectPopular(keyword: String)
    func selectRecommended(keyword: String)
    func openItem(item: Item, imageId: String?)
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
        delegate?.selectRecommended(keyword: recommended[indexPath.row])
    }
}

class SearchItemsModel: SearchModel, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var items = PaginatedResults<Item>(isLast: false, results: [Item]())
    public var query = String()
    
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
            print(query)
            cell.query = query
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
        let item = items.results[indexPath.row]
        var imageId: String?
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
            imageId = cell.getImageId()
        }
        delegate?.openItem(item: item, imageId: imageId)
    }
    
}

class SearchEmptyCollectionViewCell: UICollectionViewCell {
    public static let identifier: String = C.ViewModel.CellIdentifier.emptyCell.rawValue
    
    private let label = UILabel()
    
    public var query: String = String() {
        didSet {
            label.text = "No results found for \"\(self.query)\"."
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildViews() {
        label.font = Font.gotham(size: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
    }
    
    private func buildConstraints() {
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(16)
            make.left.right.equalToSuperview()
        }
    }
}

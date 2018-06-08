//
//  AisleVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/12/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

struct CategorySection {
    let category: Category
    var items: [Item]
    
    init(category: Category) {
        self.category = category
        self.items = []
    }
}

class CategoryViewController: ViewControllerWithCart {
    
    public var category: Category?
    
    private var sections = [CategorySection]()
    private var featuredItems = [Item]()

    private let tableView = UITableView()
    private let sectionBar = UIView()
    private let bottomBorder = UIView()
    private var sectionsCollectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView()
    private let retryButton = UIButton()
    private let topWhite = UIView()

    @objc private func loadCategory() {
        guard let cat = category else {
            return
        }
        
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        retryButton.isHidden = true
        tableView.isHidden = true
        self.getFeaturedItems()
        Request.shared.getSubcategories(category: cat) { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let subcategories):
                self.sections = subcategories.map {
                    self.getItems(cat: $0)
                    return CategorySection(category: $0)
                }
                self.tableView.isHidden = false
                self.sectionsCollectionView.reloadData()
                self.tableView.reloadData()
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
    
    private func getFeaturedItems() {
        Request.shared.getFeaturedItems(forCategory: category!) { result in
            switch result {
            case .success(let paginatedResults):
                self.featuredItems = paginatedResults.results
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: paginatedResults.results)
                    cell.reload()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getItems(cat: Category) {
        Request.shared.getItems(category: cat) { result in
            switch result {
            case .success(let paginatedResult):
                if let index = self.sections.index(where: { $0.category.id == cat.id }) {
                    self.sections[index].items = paginatedResult.results
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: index+1, section: 0)) as? GroupTableViewCell {
                        cell.model?.set(new: paginatedResult.results)
                        cell.reload()
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
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

        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: GroupTableViewCell.identifier)
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        sectionBar.backgroundColor = .white
        
        topWhite.frame = CGRect(x: 0, y: -500, width: view.frame.width, height: 500)
        topWhite.backgroundColor = .white
        sectionBar.addSubview(topWhite)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 200, height: 32)
        sectionsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        sectionsCollectionView.delegate = self
        sectionsCollectionView.dataSource = self
        sectionsCollectionView.backgroundColor = .white
        sectionsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        sectionsCollectionView.showsHorizontalScrollIndicator = false
        sectionsCollectionView.alwaysBounceHorizontal = true
        sectionsCollectionView.register(CategorySectionCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: CategorySectionCollectionViewCell.identifier)
        sectionsCollectionView.backgroundColor = .clear
        sectionsCollectionView.canCancelContentTouches = true
        sectionBar.addSubview(sectionsCollectionView)
        
        bottomBorder.backgroundColor = .lightGray
        sectionBar.addSubview(bottomBorder)
        
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
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sectionsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomBorder.snp.makeConstraints { make in
            make.height.equalTo(0.33)
            make.bottom.left.right.equalToSuperview()
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

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
        cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
        if indexPath.row == 0 {
            cell.set(title: "Featured")
            cell.model = ItemGroupModel(items: featuredItems)
            cell.model?.identifier = 0
        } else {
            let cat = sections[indexPath.row-1]
            cell.set(title: cat.category.name)
            cell.model = ItemGroupModel(items: cat.items)
            cell.model?.identifier = cat.category.id
        }
        cell.delegate = self
        cell.model?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionBar
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension CategoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CategoryViewController: ViewAllDelegate {
    func viewAll(identifier: Int?) {
        let vc = ItemGroupViewController()
        if identifier == 0 {
            vc.items = .featured(from: self.category!)
            vc.groupTitle = "Featured \(self.category!.name)"
        } else if let selected = sections.first(where: { $0.category.id == identifier }) {
            vc.items = .of(category: selected.category)
            vc.groupTitle = selected.category.name
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController: CategorySectionDelegate {
    func didOpenSection(section: CategorySection) {
        self.viewAll(identifier: section.category.id)
    }
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategorySectionCollectionViewCell.identifier, for: indexPath) as! CategorySectionCollectionViewCell
        cell.load(section: sections[indexPath.row])
        cell.delegate = self
        return cell
    }
}

protocol CategorySectionDelegate {
    func didOpenSection(section: CategorySection)
}

class CategorySectionCollectionViewCell: UICollectionViewCell {
    public static let identifier: String = C.ViewModel.CellIdentifier.aisleSectionBarCell.rawValue
    
    public var delegate: CategorySectionDelegate?
    private var section: CategorySection!
    
    private let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildViews() {
        backgroundColor = UIColor(named: .backgroundGrey)
        layer.cornerRadius = frame.height / 2
        
        button.setTitleColor(UIColor(named: .green), for: .normal)
        button.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = Font.gotham(size: 14)
        addSubview(button)
    }
    
    private func buildConstraints() {
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
    }
    
    @objc private func tapButton(_ sender: UIButton) {
        delegate?.didOpenSection(section: self.section)
    }
    
    public func load(section: CategorySection) {
        self.section = section
        button.setTitle(section.category.name, for: .normal)
    }
}



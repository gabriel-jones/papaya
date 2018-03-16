//
//  AisleVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/12/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RxSwift

struct CategorySection {
    let category: Category
    var items: [Item]
    
    init(category: Category) {
        self.category = category
        self.items = []
    }
}

class CategoryVC: ViewControllerWithCart {
    
    public var category: Category?
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    private let sectionBar = UIView()
    private let bottomBorder = UIView()
    private var sectionsCollectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView()

    var sections = [CategorySection]()
    
    private func loadCategory(_ completion: @escaping (Bool) -> Void) {
        guard let cat = category else {
            completion(false)
            return
        }
        Request.shared.getSubcategories(category: cat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { subcategories in
                self.sections = subcategories.map {
                    self.getItems(cat: $0)
                    return CategorySection(category: $0)
                }
                self.sectionsCollectionView.reloadData()
                self.tableView.reloadData()
                completion(true)
            }, onError: { [unowned self] error in
                print(error.localizedDescription)
                completion(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func getItems(cat: Category) {
        print("Getting items for category: \(cat.name)")
        Request.shared.getItems(category: cat)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] items in
                print("Fetched items: \(items.count)")
                if let index = self.sections.index(where: { $0.category.id == cat.id }) {
                    print("Index: \(index)")
                    self.sections[index].items = items
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: index+1, section: 0)) as? GroupTableViewCell {
                        cell.model?.set(new: items)
                        cell.reload()
                    }
                }
            }, onError: { [unowned self] error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        self.loadCategory { _ in
            self.tableView.isHidden = false
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = category?.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: GroupTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.isHidden = true
        view.addSubview(tableView)
        
        sectionBar.backgroundColor = .white
        
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
        sectionsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: C.ViewModel.CellIdentifier.aisleSectionBarCell.rawValue)
        sectionsCollectionView.backgroundColor = .clear
        sectionBar.addSubview(sectionsCollectionView)
        
        bottomBorder.backgroundColor = .lightGray
        sectionBar.addSubview(bottomBorder)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        
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
    }
    
    @objc private func openSection(_ sender: UIButton) {
        self.viewAll(identifier: sender.tag)
    }
}

extension CategoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
        var cat: CategorySection?
        if indexPath.row != 0 {
            cat = sections[indexPath.row-1]
        }
        cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
        cell.set(title: indexPath.row == 0 ? "Featured" : cat?.category.name ?? "")
        cell.delegate = self
        if let id = cat?.category.id, let itemGroup = self.sections.first(where: { $0.category.id == id })?.items {
            cell.model = ItemGroupModel(items: itemGroup)
            cell.model?.delegate = self
            cell.model?.identifier = id
        }
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

extension CategoryVC: ViewAllDelegate {
    func viewAll(identifier: Int?) {
        if let selected = sections.first(where: { $0.category.id == identifier }) {
            let vc = ItemGroupViewController()
            vc.items = Request.shared.getAllItemsTemp()
            vc.groupTitle = selected.category.name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CategoryVC: GroupDelegateAction {
    func open(item: Item, imageId: String) {
        let vc = ItemVC()
        vc.item = item
        vc.imageId = imageId
        isHeroEnabled = true
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        present(nav, animated: true, completion: nil)
    }
}

extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.ViewModel.CellIdentifier.aisleSectionBarCell.rawValue, for: indexPath)
        cell.backgroundColor = UIColor(named: .backgroundGrey)
        cell.layer.cornerRadius = cell.frame.height / 2
        
        let button = UIButton()
        button.setTitle(sections[indexPath.row].category.name, for: .normal)
        button.setTitleColor(UIColor(named: .green), for: .normal)
        button.tag = sections[indexPath.row].category.id
        button.addTarget(self, action: #selector(openSection(_:)), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = Font.gotham(size: 14)
        cell.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        return cell
    }
}

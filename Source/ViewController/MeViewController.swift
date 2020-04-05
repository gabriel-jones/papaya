//
//  MeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class MeViewController: ViewControllerWithCart {
    
    private var commonItems = [Item]()
    private var recentItems = [Item]()
    private var favouriteItems = [Item]()
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        Request.shared.getLikedItems { result in
            switch result {
            case .success(let paginatedResult):
                self.favouriteItems = paginatedResult.results
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: paginatedResult.results)
                    cell.reload()
                }
            case .failure(_):
                self.showMessage("Can't fetch groceries", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
        
        Request.shared.getCommonItems { result in
            switch result {
            case .success(let paginatedResult):
                self.commonItems = paginatedResult.results
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: paginatedResult.results)
                    cell.reload()
                }
            case .failure(_):
                self.showMessage("Can't fetch groceries", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
        
        Request.shared.getRecentItems { result in
            switch result {
            case .success(let paginatedResult):
                self.commonItems = paginatedResult.results
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: paginatedResult.results)
                    cell.reload()
                }
            case .failure(_):
                self.showMessage("Can't fetch groceries", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    private func buildViews() {
        isHeroEnabled = true
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        navigationItem.title = "Me"
        navigationController?.navigationBar.tintColor = UIColor(named: .green)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: C.ViewModel.CellIdentifier.listGroupCell.rawValue)
        view.addSubview(tableView)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            if BaseStore.order == nil {
                make.edges.equalToSuperview()
            } else {
                make.top.left.right.equalToSuperview()
                if #available(iOS 11, *) {
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(49)
                } else {
                    make.bottom.equalToSuperview().inset(99)
                }
            }
        }
    }
}

extension MeViewController: GroupDelegateAction {
    func open(item: Item, imageId: String) {
        let vc = ItemViewController()
        vc.item = item
        vc.imageId = imageId
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .auto, dismissing: .uncover(direction: .down))
        present(nav, animated: true, completion: nil)
    }
}

extension MeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.listGroupCell.rawValue, for: indexPath) as! GroupTableViewCell
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.set(title: "Liked")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel(items: self.favouriteItems)
        case 1:
            cell.set(title: "Commonly ordered")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel(items: self.favouriteItems)
        case 2:
            cell.set(title: "Recently ordered")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel(items: self.favouriteItems)
        default: break
        }
        cell.model?.identifier = indexPath.row
        cell.model?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

extension MeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MeViewController: ViewAllDelegate {
    func viewAll(identifier: Int?) {
        if let identifier = identifier {
            let vc = ItemGroupViewController()
            vc.groupTitle = ["Liked", "Commonly ordered", "Recently ordered"][identifier]
            vc.items = [.common, .recent, .liked][identifier]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

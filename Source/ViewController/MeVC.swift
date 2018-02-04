//
//  MeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RxSwift

class MeVC: ViewControllerWithCart {
    
    private var lists = [List]()
    private var favouriteItems = [Item]()
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        Request.shared.getAllLists()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] lists in
                self.lists = lists
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: lists)
                    cell.reload()
                }
            }, onError: { [unowned self] error in
                switch error as? RequestError {
                case .networkOffline?:
                    print("offline")
                default:
                    print("Generic error")
                }
            })
            .disposed(by: disposeBag)
        
        Request.shared.getLikedItems()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] items in
                self.favouriteItems = items
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: items)
                    cell.reload()
                }
            }, onError: { [unowned self] error in
                switch error as? RequestError {
                case .networkOffline?:
                    print("offline")
                default:
                    print("Generic error")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func buildViews() {
        isHeroEnabled = true
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
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
        
        let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(openSettings(_:)))
        settingsButton.tintColor = UIColor(named: .green)
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func openSettings(_ sender: UIBarButtonItem) {
        let settingsVC = SettingsVC()
        let vc = UINavigationController(rootViewController: settingsVC)
        self.present(vc, animated: true, completion: nil)
    }
}

extension MeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.listGroupCell.rawValue, for: indexPath) as! GroupTableViewCell
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.set(title: "Lists")
            cell.register(class: ListCollectionViewCell.classForCoder(), identifier: ListCollectionViewCell.identifier)
            cell.model = ListGroupModel(lists: self.lists)
        case 1:
            cell.set(title: "Liked Items")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel(items: self.favouriteItems)
        default: break
        }
        cell.model?.identifier = indexPath.row
        cell.model?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return [175, 250][indexPath.row]
    }
}

extension MeVC: ViewAllDelegate, GroupDelegateAction {
    func viewAll(identifier: Int?) {
        switch identifier ?? -1 {
        case 0:
            break
        case 1:
            let vc = ItemGroupViewController()
            vc.items = Request.shared.getAllItemsTemp()
            vc.groupTitle = "Liked"
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    func open(list: List, imageIds: [String]) {
        let vc = ListDetailViewController()
        vc.list = list
        vc.imageIds = imageIds
        present(vc, animated: true, completion: nil)
    }
    
    func open(item: Item, imageId: String) {
        let vc = ItemVC.instantiate(from: .main)
        vc.item = item
        vc.imageId = imageId
        heroModalAnimationType = .zoomSlide(direction: .up)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        present(nav, animated: true, completion: nil)
    }
}

protocol ViewAllDelegate: class {
    func viewAll(identifier: Int?)
}

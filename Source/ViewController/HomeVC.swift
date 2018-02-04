//
//  HomeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class HomeVC: ViewControllerWithCart {
    
    private var items = [Item]()
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buildViews()
        self.buildConstraints()
        
        Request.shared.getAllItemsTemp()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] items in
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
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

        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: C.ViewModel.CellIdentifier.itemGroupCell.rawValue)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let hr = Calendar.current.component(.hour, from: Date())
        
        var greet = ""
        var end = ""
        switch hr {
        case 0..<5:
            greet = "Up Late"
            end = "?"
        case 5..<12:
            greet = "Good Morning"
        case 12..<17:
            greet = "Good Afternoon"
        case 17..<24:
            greet = "Good Evening"
        default: break
        }
        
        navigationItem.title = greet
        
        if let user = User.current {
            navigationItem.title = navigationItem.title! + ", \(user.fname)" + end
        } else {
            navigationItem.title = navigationItem.title! + end
        }
        
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
        cell.delegate = self
        
        switch indexPath.row {
        case 0:
            cell.set(title: "Today's Specials")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel()
            cell.model?.identifier = nil
        case 1:
            cell.set(title: "Recommended for You")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel()
            cell.model?.identifier = nil
        default: break
        }
        
        cell.model?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

extension HomeVC: ViewAllDelegate {
    func viewAll(identifier: Int?) {
        print(identifier)
    }
    
}

extension HomeVC: GroupDelegateAction {
    func open(item: Item, imageId: String) {
        let vc = ItemVC.instantiate(from: .main)
        vc.item = item
        vc.imageId = imageId
        heroModalAnimationType = .cover(direction: .up)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        present(nav, animated: true, completion: nil)
    }
}


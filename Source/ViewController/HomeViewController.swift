//
//  HomeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeViewController: ViewControllerWithCart {
    
    private var items = [Item]()
    public var scheduleDays: [ScheduleDay]?
    public var checkout: Checkout?
    
    private let tableView = UITableView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buildViews()
        self.buildConstraints()
        
        Request.shared.getAllItemsTemp { result in
            switch result {
            case .success(let paginatedResults):
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: paginatedResults.results)
                    cell.reload()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.showMessage("Can't fetch items", type: .error)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if let checkout = checkout, let scheduleDays = scheduleDays {
//            isHeroEnabled = true
//            let cart = CartViewController()
//            cart.delegate = self
//            cart.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: cart, action: nil)
//            let navCart = UINavigationController()
//            navCart.isHeroEnabled = true
//            navCart.navigationBar.tintColor = UIColor(named: .green)
//            navCart.heroModalAnimationType = .selectBy(presenting: .cover(direction: .left), dismissing: .uncover(direction: .right))
//            let scheduler = CheckoutSchedulerViewController()
//            scheduler.checkout = checkout
//            scheduler.schedule = scheduleDays
//            scheduler.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: scheduler, action: nil)
//            var vcs: [UIViewController] = [cart, scheduler]
//            if checkout.orderDate != nil {
//                scheduler.selectedDate = checkout.orderDate!
//                let checkoutVC = CheckoutViewController()
//                checkoutVC.checkout = checkout
//                checkoutVC.schedule = scheduleDays
//                checkoutVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: checkoutVC, action: nil)
//                vcs.append(checkoutVC)
//            }
//
//            navCart.viewControllers = vcs
//            view.window?.rootViewController?.present(navCart, animated: true) {
//                self.checkout = nil
//                self.scheduleDays = nil
//            }
//        }
    }
    
    private func buildViews() {
        isHeroEnabled = true
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

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

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
        cell.delegate = self
        cell.model?.identifier = indexPath.row

        switch indexPath.row {
        case 0:
            cell.set(title: "Today's Specials")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel(items: items)
        case 1:
            cell.set(title: "Recommended for You")
            cell.register(class: ItemCollectionViewCell.classForCoder(), identifier: ItemCollectionViewCell.identifier)
            cell.model = ItemGroupModel(items: items)
        default: break
        }
        
        cell.model?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension HomeViewController: ViewAllDelegate {
    func viewAll(identifier: Int?) {
        
    }
    
}

protocol ViewAllDelegate: class {
    func viewAll(identifier: Int?)
}

extension UIViewController: GroupDelegateAction {
    func open(item: Item, imageId: String) {
        let vc = ItemViewController()
        vc.item = item
        vc.imageId = imageId
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .auto, dismissing: .uncover(direction: .down))
        present(nav, animated: true, completion: nil)
    }
    
    func open(list: List, imageIds: [String]) {
        let vc = ListDetailViewController()
        vc.list = list
        //vc.imageIds = imageIds
        present(vc, animated: true, completion: nil)
    }
}

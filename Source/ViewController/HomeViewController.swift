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
    
    public var scheduleDays: [ScheduleDay]?
    public var checkout: Checkout?
    
    private let tableView = UITableView()
    
    var isCartPopulated: Bool {
        get {
            return BaseStore.cartItemCount ?? 0 != 0
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buildViews()
        self.buildConstraints()
        
        Request.shared.getTodaysSpecials { result in
            switch result {
            case .success(let paginatedResults):
                if let cell = self.tableView.cellForRow(at: IndexPath(row: self.isCartPopulated ? 1 : 0, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: paginatedResults.results)
                    cell.reload()
                }
            case .failure(_):
                self.showMessage("Can't fetch groceries", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
        
        Request.shared.getRecommendedItems { result in
            switch result {
            case .success(let paginatedResults):
                if let cell = self.tableView.cellForRow(at: IndexPath(row: self.isCartPopulated ? 2 : 1, section: 0)) as? GroupTableViewCell {
                    cell.model?.set(new: paginatedResults.results)
                    cell.reload()
                }
            case .failure(_):
                self.showMessage("Can't fetch groceries", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
        
        if isCartPopulated {
            Request.shared.getCartSuggestions { result in
                switch result {
                case .success(let paginatedResults):
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
                        cell.model?.set(new: paginatedResults.results)
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
        navigationController?.navigationBar.tintColor = UIColor(named: .green)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

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
            //TODO: if order status view then shift up to be above it
        }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCartPopulated ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
        cell.delegate = self
        
        var rowData = [
            ("Today's Specials", ItemCollectionViewCell.classForCoder(), ItemCollectionViewCell.identifier),
            ("Recommended for You", ItemCollectionViewCell.classForCoder(), ItemCollectionViewCell.identifier)
        ]
        
        if isCartPopulated {
            rowData.insert(("Based on your Cart", ItemCollectionViewCell.classForCoder(), ItemCollectionViewCell.identifier), at: 0)
        }
        
        cell.set(title: rowData[indexPath.row].0)
        cell.register(class: rowData[indexPath.row].1, identifier: rowData[indexPath.row].2)
        cell.model = ItemGroupModel(items: [])
        cell.model?.delegate = self
        cell.model?.identifier = indexPath.row
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
        let vc = ItemGroupViewController()
        if isCartPopulated && identifier == 0 { // Based on your cart
            vc.groupTitle = "Based on your Cart"
            vc.items = .cartSuggestions
        } else if (isCartPopulated && identifier == 1) || identifier == 0 { // Specials
            vc.groupTitle = "Today's Specials"
            vc.items = .todaysSpecials
        } else if (isCartPopulated && identifier == 2) || identifier == 1 { // Recommended for you
            vc.groupTitle = "Recommended for You"
            vc.items = .recommended
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: GroupDelegateAction {
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

protocol ViewAllDelegate: class {
    func viewAll(identifier: Int?)
}

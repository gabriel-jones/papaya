//
//  CheckoutViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/6/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import Presentr

class CheckoutViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let toolbar = UIView()
    private let toolbarBorder = UIView()
    private let checkoutButton = LoadingButton()
    private let orderType = UISegmentedControl()
    
    public var checkout: Checkout!
    public var schedule: [ScheduleDay]!
    
    private let modalBottomTransition: Presentr = {
        let type = PresentationType.custom(width: .full, height: .half, center: .bottomCenter)
        let tr = Presentr(presentationType: type)
        tr.transitionType = .coverVertical
        tr.roundCorners = true
        return tr
    }()
    private let modalCenterTransition: Presentr = {
        let tr = Presentr(presentationType: .popup)
        tr.transitionType = .coverVertical
        tr.roundCorners = true
        return tr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "Review"
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CheckoutMapTableViewCell.classForCoder(), forCellReuseIdentifier: CheckoutMapTableViewCell.identifier)
        tableView.register(CheckoutCartTableViewCell.classForCoder(), forCellReuseIdentifier: CheckoutCartTableViewCell.identifier)
        view.addSubview(tableView)
        
        // Toolbar
        toolbar.backgroundColor = UIColor(named: .backgroundGrey)
        view.addSubview(toolbar)
        
        // Toolbar border
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 0.5)
        toolbar.addSubview(toolbarBorder)
        
        // Add to cart
        checkoutButton.backgroundColor = UIColor(named: .green)
        checkoutButton.layer.cornerRadius = 5
        checkoutButton.setTitle("Place order", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = Font.gotham(weight: .bold, size: 17)
        checkoutButton.addTarget(self, action: #selector(placeOrder(_:)), for: .touchUpInside)
        toolbar.addSubview(checkoutButton)
        
        orderType.backgroundColor = .white
        orderType.selectedSegmentIndex = 0
        orderType.insertSegment(withTitle: "Delivery", at: 0, animated: false)
        orderType.insertSegment(withTitle: "Pickup", at: 1, animated: false)
        orderType.tintColor = UIColor(named: .green)
        orderType.setTitleTextAttributes([NSAttributedStringKey.font: Font.gotham(size: 15)], for: .normal)
        orderType.addTarget(self, action: #selector(changeOrderType(_:)), for: .valueChanged)
        orderType.selectedSegmentIndex = checkout.isDelivery ? 0 : 1
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(toolbar.snp.top)
        }
        
        toolbar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(65)
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    @objc private func placeOrder(_ sender: LoadingButton) {
        
    }
    
    @objc private func changeOrderType(_ sender: UISegmentedControl) {
        let isDelivery = sender.selectedSegmentIndex == 0
        checkout.isDelivery = isDelivery
        if sender.selectedSegmentIndex == 0 {
            tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .top)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .top)
        }
        print("change type: \(checkout.isDelivery)")
        Request.shared.updateCheckout(isDelivery: isDelivery) { result in
            switch result {
            case .success(_):
                self.checkout.isDelivery = isDelivery
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}

extension CheckoutViewController: CheckoutMapDelegate, AddressListModal {
    func changeAddress() {
        let vc = AddressListViewController()
        vc.isModal = true
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.tintColor = UIColor(named: .green)
        present(nav, animated: true, completion: nil)
    }
    
    func chose(address: Address) {
        Request.shared.updateCheckout(address: address) { result in
            switch result {
            case .success(_):
                self.checkout.address = address
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CheckoutViewController: SchedulerDelegate {
    func didUpdateCheckout(new: Checkout) {
        self.checkout = new
        tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
    }
}

extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [0: checkout.isDelivery ? 2 : 1, 1: 1, 2: 2, 3: 4][section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                var str = formatter.string(from: checkout.orderDate!)
                formatter.dateFormat = " 'at' ha - "
                str += formatter.string(from: checkout.orderDate!).lowercased()
                let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: checkout.orderDate!)!
                formatter.dateFormat = "ha"
                str += formatter.string(from: nextHour).lowercased()
                
                let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.deliveryTimeCell.rawValue)
                cell.textLabel?.text = str
                cell.textLabel?.font = Font.gotham(size: 15)
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "Edit"
                cell.detailTextLabel?.font = Font.gotham(size: 13)
                cell.detailTextLabel?.textColor = .gray
                cell.imageView?.image = #imageLiteral(resourceName: "Notification").tintable
                cell.imageView?.tintColor = .gray
                cell.separatorInset = .zero
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutMapTableViewCell.identifier, for: indexPath) as! CheckoutMapTableViewCell
                if let address = checkout.address {
                    cell.load(address: address)
                } else {
                    // handle
                }
                cell.delegate = self
                return cell
            default: break
            }
        case 1:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.deliveryTimeCell.rawValue)
            cell.textLabel?.text = "Cart"
            cell.textLabel?.font = Font.gotham(size: 15)
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = "\(checkout.cart?.items.count ?? 0) items"
            cell.detailTextLabel?.font = Font.gotham(size: 13)
            cell.detailTextLabel?.textColor = .gray
            cell.imageView?.image = #imageLiteral(resourceName: "Cart Full").tintable
            cell.imageView?.tintColor = .gray
            cell.separatorInset = .zero
            return cell
        case 2:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.checkoutTotalCell.rawValue)
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            switch indexPath.row {
            case 0: // payment method
                let attr = NSMutableAttributedString(string: "Payment Method: Card")
                attr.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, 15))
                cell.textLabel?.attributedText = attr
                cell.textLabel?.font = Font.gotham(size: 15)
                let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                arrow.image = #imageLiteral(resourceName: "Right Arrow").tintable
                arrow.tintColor = .gray
                arrow.transform = arrow.transform.rotated(by: .pi / 2)
                cell.accessoryView = arrow
            case 1: // payment detail
                cell.imageView?.image = #imageLiteral(resourceName: "Card").tintable
                cell.imageView?.tintColor = .gray
                cell.textLabel?.text = "**** **** **** 1234"
                cell.textLabel?.font = Font.gotham(size: 15)
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "Edit"
                cell.separatorInset = .zero
            default: break
            }
            return cell
        case 3:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.checkoutTotalCell.rawValue)
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0...3:
                cell.textLabel?.text = ["Cart Subtotal", "Service Fee", "Tip", "Total"][indexPath.row]
                cell.textLabel?.textColor = indexPath.row == 3 ? .black : .gray
                cell.textLabel?.font = Font.gotham(size: 14)
                cell.detailTextLabel?.text = "$99.99"
                cell.imageView?.image = indexPath.row == 3 ? nil : UIImage()
            default: break
            }
            return cell
        default: break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 50
            } else if indexPath.row == 1 {
                return 125
            }
        } else if indexPath.section == 1 {
            return 50
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            let vc = CheckoutSchedulerViewController()
            vc.isModal = true
            vc.schedule = self.schedule
            vc.checkout = self.checkout
            vc.modalDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.tintColor = UIColor(named: .green)
            customPresentViewController(modalBottomTransition, viewController: nav, animated: true, completion: nil)
        }
        else if indexPath.section == 1 {
            guard let cart = checkout.cart else {
                return
            }
            let vc = CartMinimalViewController()
            vc.cart = cart
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.tintColor = UIColor(named: .green)
            customPresentViewController(modalCenterTransition, viewController: nav, animated: true, completion: nil)
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                /*
                 let vc = CheckoutEditPaymentType()
                 vc.delegate = self
                 customPresentViewController(modalBottomTransition, viewController: vc, animated: true, completion: nil)
                 */
            } else if indexPath.row == 1 {
                // edit payment selected
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            return nil
        }
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(orderType)
        orderType.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        return container
    }
}


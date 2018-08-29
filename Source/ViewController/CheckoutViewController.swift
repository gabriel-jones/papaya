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
    private let toolbarContentView = UIView()
    private let toolbarBorder = UIView()
    private let checkoutButton = LoadingButton()
    private let orderType = UISegmentedControl()
    private let activityIndicator = LoadingView()
    private let retryButton = UIButton()
    
    public var checkout: Checkout!
    public var schedule: [ScheduleDay]!
    
    private var updatingCheckoutType: URLSessionDataTask?
    private var purchaseExpress = true
    private var purchasePriority = false

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
        
        self.loadCheckout()
    }
    
    @objc private func loadCheckout() {
        self.retryButton.isHidden = true
        self.tableView.isHidden = true
        checkoutButton.isEnabled = false
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        Request.shared.getCheckout { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let checkout):
                self.checkout = checkout
                self.tableView.isHidden = false
                self.tableView.reloadData()
                self.hideMessage()
                self.checkoutButton.isEnabled = true
            case .failure(_):
                self.retryButton.isHidden = false
                self.showMessage("Can't load checkout", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
        let index = navigationController!.viewControllers.index(where: { $0 is CheckoutViewController })! - 1
        (navigationController?.viewControllers[index] as! CheckoutSchedulerViewController).checkout = self.checkout
        return true
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "Review"
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(CheckoutMapTableViewCell.classForCoder(), forCellReuseIdentifier: CheckoutMapTableViewCell.identifier)
        tableView.register(CheckoutCartTableViewCell.classForCoder(), forCellReuseIdentifier: CheckoutCartTableViewCell.identifier)
        tableView.isHidden = true
        view.addSubview(tableView)
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadCheckout), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
        
        // Toolbar
        toolbar.backgroundColor = UIColor(named: .backgroundGrey)
        view.addSubview(toolbar)
        
        toolbar.addSubview(toolbarContentView)
        
        // Toolbar border
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 0.5)
        toolbarContentView.addSubview(toolbarBorder)
        
        // Add to cart
        checkoutButton.backgroundColor = UIColor(named: .green)
        checkoutButton.layer.cornerRadius = 5
        checkoutButton.setTitle("Place order", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = Font.gotham(weight: .bold, size: 17)
        checkoutButton.addTarget(self, action: #selector(placeOrder(_:)), for: .touchUpInside)
        checkoutButton.isEnabled = false
        toolbarContentView.addSubview(checkoutButton)
        
        orderType.backgroundColor = .white
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
        }
        
        toolbarContentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.height.equalTo(49)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    @objc private func placeOrder(_ sender: LoadingButton) {
        if checkout.address == nil && checkout.isDelivery {
            let alert = UIAlertController(title: "Address required for delivery", message: "Please select or create an address to deliver your order to.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.changeAddress()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        if checkout.paymentMethod == nil {
            let alert = UIAlertController(title: "Payment method required", message: "Please select or create a payment method to charge your order to.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let vc = PaymentListViewController()
                vc.isModal = true
                vc.delegate = self
                let nav = UINavigationController(rootViewController: vc)
                nav.navigationBar.tintColor = UIColor(named: .green)
                self.present(nav, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        sender.showLoading()
        Request.shared.buyCheckout(purchasePriority: purchasePriority, purchaseExpress: purchaseExpress) { result in
            sender.hideLoading()
            switch result {
            case .success(let orderId):
                StatusFetcher.shared.startFetching(id: orderId)
                let root = self.view.window!.rootViewController
                root?.dismiss(animated: true) {
                    let statusVC = StatusViewController()
                    root?.present(statusVC, animated: true, completion: nil)
                }
            case .failure(let error):
                if error == .emailNotValidated {
                    let alert = UIAlertController(title: "Email not confirmed", message: "An email has been sent to \(User.current!.email) to confirm your account. Once this has been completed you can place your order.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if error == .tooManyOrders {
                    let alert = UIAlertController(title: "Order already in progress", message: "Please wait for your previous order to finish before starting another one. Your checkout settings will be saved until then.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Could not place order", message: "Please contact support@papaya.bm for assistance. Error: \(error.localizedDescription). ", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    @objc private func changeOrderType(_ sender: UISegmentedControl) {
        let isDelivery = sender.selectedSegmentIndex == 0
        checkout.isDelivery = isDelivery
        if sender.selectedSegmentIndex == 0 {
            tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .top)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .top)
        }

        updatingCheckoutType?.cancel()
        updatingCheckoutType = Request.shared.updateCheckout(isDelivery: isDelivery) { result in
            switch result {
            case .success(_):
                self.checkout.isDelivery = isDelivery
            case .failure(_):
                self.showMessage("Can't update delivery settings", type: .error, options: [
                    .autoHide(true),
                    .hideOnTap(true)
                ])
            }
        }
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        if !sender.isOn {
            if sender.tag == 0 {
                purchasePriority = false
                purchaseExpress = true
            } else if sender.tag == 1 {
                purchaseExpress = false
            }
        } else {
            if sender.tag == 0 {
                purchaseExpress = false
                purchasePriority = true
            } else if sender.tag == 1 {
                purchasePriority = false
                purchaseExpress = true
            }
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) {
            if let switchView = cell.accessoryView as? UISwitch {
                switchView.setOn(purchasePriority, animated: true)
            }
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 4)) {
            if let switchView = cell.accessoryView as? UISwitch {
                switchView.setOn(purchaseExpress, animated: true)
            }
        }
        tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
}

extension CheckoutViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CheckoutViewController: CheckoutMapDelegate, AddressListModal, PaymentListModal {
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
            case .failure(_):
                self.showMessage("Can't update address", type: .error, options: [
                    .autoHide(true),
                    .hideOnTap(true)
                ])
            }
        }
    }
    
    func chose(paymentMethod: PaymentMethod) {
        Request.shared.updateCheckout(paymentMethod: paymentMethod) { result in
            switch result {
            case .success(_):
                self.checkout.paymentMethod = paymentMethod
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
            case .failure(_):
                self.showMessage("Can't update payment method", type: .error, options: [
                    .autoHide(true),
                    .hideOnTap(true)
                ])
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
        return 4 + (User.current!.isExpress ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [0: checkout.isDelivery ? 2 : 1, 1: 1, 2: 1, 3: 4 + (purchasePriority ? 1 : 0), 4: 2][section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                var str = ""
                if checkout.isAsap {
                    str = "ASAP"
                } else {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEEE"
                    str = formatter.string(from: checkout.startDate!)
                    formatter.dateFormat = " 'at' ha - "
                    str += formatter.string(from: checkout.startDate!).lowercased()
                    let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: checkout.startDate!)!
                    formatter.dateFormat = "ha"
                    str += formatter.string(from: nextHour).lowercased()
                }
                
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
                    cell.loadEmpty()
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
            cell.detailTextLabel?.text = "\(checkout.cart?.items.count ?? 0) groceries"
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
                cell.textLabel?.text = checkout.paymentMethod?.formattedCardNumber ?? "No payment method selected"
                cell.textLabel?.font = Font.gotham(size: 15)
                cell.detailTextLabel?.text = "Change"
                cell.imageView?.image = checkout.paymentMethod?.image ?? #imageLiteral(resourceName: "Card").tintable
                cell.imageView?.tintColor = .gray
                cell.accessoryType = .disclosureIndicator
            default: break
            }
            return cell
        case 3:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.checkoutTotalCell.rawValue)
            cell.textLabel?.font = Font.gotham(size: 14)
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            cell.selectionStyle = .none
            
            let deliveryFee = 10.0
            let serviceFee = 10.0
            let priorityFee = 5.0
            let total = checkout.cart!.total + (purchasePriority ? priorityFee : 0) + (checkout.isDelivery ? deliveryFee : 0) + serviceFee
            var model = [
                ("Cart Subtotal", checkout.cart!.total.currencyFormat),
                ("Service Fee", checkout.serviceFee.currencyFormat),
                ("Total", total.currencyFormat)
            ]
            if checkout.isDelivery {
                model.insert(("Delivery Fee", deliveryFee.currencyFormat), at: 1)
            }
            if purchasePriority {
                model.insert(("Priority Fee", priorityFee.currencyFormat), at: 2)
            }
            switch indexPath.row {
            case 0..<model.count:
                cell.textLabel?.text = model[indexPath.row].0
                cell.textLabel?.textColor = indexPath.row == model.count-1 ? .black : .gray
                cell.detailTextLabel?.text = model[indexPath.row].1
                cell.detailTextLabel?.textColor = indexPath.row == model.count-1 ? .black : .gray
                cell.imageView?.image = indexPath.row == model.count-1 ? nil : UIImage()
            default: break
            }
            return cell
        case 4:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "moreChargesCell")
            cell.textLabel?.text = indexPath.row == 0 ? "Prioritise order" : "Purchase Express for 1 Year"
            cell.detailTextLabel?.text = indexPath.row == 0 ? "$5" : "$12 / month"
            cell.textLabel?.font = Font.gotham(size: 14)
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            cell.detailTextLabel?.textColor = .gray
            let switchView = UISwitch()
            switchView.isOn = indexPath.row == 0 ? purchasePriority : purchaseExpress
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
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
            /*
            let vc = CheckoutSchedulerViewController()
            vc.isModal = true
            vc.schedule = self.schedule
            vc.checkout = self.checkout
            vc.modalDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.tintColor = UIColor(named: .green)
            customPresentViewController(modalBottomTransition, viewController: nav, animated: true, completion: nil)
             */
            navigationController?.popViewController(animated: true)
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
            let vc = PaymentListViewController()
            vc.isModal = true
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.tintColor = UIColor(named: .green)
            present(nav, animated: true, completion: nil)
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


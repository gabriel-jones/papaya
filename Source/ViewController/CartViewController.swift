//
//  CartVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

extension UIImage {
    public var tintable: UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
}

class CartViewController: UIViewController {
    
    private var cart: Cart?
    private var schedule: ScheduleDay?
    public var delegate: CartViewControllerDelegate?
    private let group = DispatchGroup()
    private var isInitialLoad: Bool = true

    private var closeButton: UIBarButtonItem!
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let toolbar = UIView()
    private let toolbarContentView = UIView()
    private let toolbarBorder = UIView()
    private let checkoutButton = LoadingButton()
    private let checkoutPrice = UIView()
    private let checkoutPriceLabel = UILabel()
    private let activityIndicator = LoadingView()
    private let refreshControl = UIRefreshControl()
    private let retryButton = UIButton()

    @objc private func refreshTable() {
        self.loadCart {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func loadCart(_ completion: (() -> Void)? = nil) {
        retryButton.isHidden = true
        Request.shared.getCart { result in
            switch result {
            case .success(let cart):
                self.hideMessage()
                
                if cart.total > 0 {
                    self.checkoutButton.isEnabled = true
                    self.checkoutButton.alpha = 1.0
                }
                
                self.tableView.isUserInteractionEnabled = true
                
                self.cart = cart
                
                if !self.isInitialLoad {
                    self.update()
                }
            case .failure(_):
                self.checkoutButton.hideLoading()
                self.checkoutButton.alpha = 0.5
                self.checkoutButton.isEnabled = false
                
                self.retryButton.isHidden = false
                self.tableView.isUserInteractionEnabled = false
                
                self.showMessage("Cannot fetch cart", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
            self.activityIndicator.stopAnimating()
            self.checkoutButton.hideLoading()
            completion?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.fullLoad()
    }
    
    @objc func fullLoad() {
        DispatchQueue.main.async {
            self.checkoutButton.showLoading()
            self.activityIndicator.startAnimating()
            self.tableView.isHidden = true
        }
        group.enter()
        self.loadCart {
            self.group.leave()
        }
        
        group.enter()
        Request.shared.getSchedule(days: 1) { result in
            switch result {
            case .success(let days):
                guard let day = days.first else {
                    return
                }
                self.schedule = day
            case .failure(_): break
            }
            self.group.leave()
        }
        
        group.notify(queue: .main) {
            self.isInitialLoad = false
            self.tableView.isHidden = false
            self.update()
        }
    }
    
    private func update() {
        checkoutPrice.isHidden = false
        checkoutPriceLabel.text = cart?.total.currencyFormat
        tableView.reloadData()
    }
    
    private func buildViews() {
        isHeroEnabled = true
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
        closeButton.tintColor = UIColor(named: .green)
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.title = "Cart"
        
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.backgroundColor = .clear
        tableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: EmptyTableViewCell.identifier)
        tableView.register(CartItemTableViewCell.classForCoder(), forCellReuseIdentifier: CartItemTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.alwaysBounceVertical = true
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
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
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = Font.gotham(weight: .bold, size: 17)
        checkoutButton.addTarget(self, action: #selector(checkout(_:)), for: .touchUpInside)
        checkoutButton.alpha = 0.5
        checkoutButton.isEnabled = false
        toolbarContentView.addSubview(checkoutButton)
        
        checkoutPrice.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        checkoutPrice.layer.cornerRadius = 5
        checkoutPrice.isHidden = true
        checkoutButton.addSubview(checkoutPrice)
        
        checkoutPriceLabel.textColor = .white
        checkoutPriceLabel.textAlignment = .center
        checkoutPriceLabel.font = Font.gotham(size: 14)
        checkoutPrice.addSubview(checkoutPriceLabel)
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(fullLoad), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    @objc private func checkout(_ sender: LoadingButton) {
        sender.showLoading()
        Request.shared.getSchedule { result in
            switch result {
            case .success(let days):
                print(days)
                Request.shared.createCheckout { result in
                    sender.hideLoading()
                    switch result {
                    case .success(let checkout):
                        let vc = CheckoutSchedulerViewController()
                        vc.checkout = checkout
                        vc.schedule = days
                        if let date = checkout.startDate {
                            vc.selectedDate = date
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .failure(_):
                        self.showError(message: "Can't checkout. Please check your connection and try again.")
                    }
                }
            case .failure(_):
                sender.hideLoading()
                self.showError(message: "Can't checkout. Please check your connection and try again.")
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "An error occured.", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func buildConstraints() {
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
            make.height.equalTo(1)
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.height.equalTo(49)
        }
        
        tableView.snp.makeConstraints { make in
            make.bottom.equalTo(toolbar.snp.top)
            make.left.right.top.equalToSuperview()
        }
        
        checkoutPrice.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        checkoutPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.bottom.equalTo(-4)
            make.left.equalTo(8)
            make.right.equalTo(-8)
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
    
    @objc func close(_ sender: UIBarButtonItem?) {
        heroModalAnimationType = .pageOut(direction: .right)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension CartViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CartViewController: CartItemTableViewCellDelegate {
    func changeQuantity(new: Int, selectedItem: CartItem) {
        let index = cart!.items.index(where: { $0.id == selectedItem.id })!
        cart?.items[index].quantity = new
        self.update()
    }
    
    func delete(selectedItem: CartItem) {
        let index = cart!.items.index(where: { $0.id == selectedItem.id })!
        cart?.items.remove(at: index)
        self.update()
    }
    
    func addInstructions(selectedItem: CartItem) {
        let vc = InstructionsViewController()
        vc.item = selectedItem
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}

extension CartViewController: InstructionsViewControllerDelegate {
    func didMakeChanges(toCartItem: CartItem) {
        if let index = self.cart?.items.index(where: { $0.id == toCartItem.id }) {
            self.cart?.items[index] = toCartItem
            self.tableView.reloadData()
        }
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cart?.items.isEmpty ?? false {
            tableView.separatorColor = .clear
            return 1
        }
        tableView.separatorColor = nil
        return cart?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && cart?.items.isEmpty ?? true {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as! EmptyTableViewCell
            cell.delegate = self
            cell.emptyImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -20 / 180)
            cell.buttonText = "Add some items"
            cell.emptyText = "Your cart is empty!"
            cell.img = #imageLiteral(resourceName: "Cart")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemTableViewCell.identifier, for: indexPath) as! CartItemTableViewCell
        cell.selectionStyle = .none
        cell.load(cartItem: cart!.items[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ItemViewController()
        vc.cartDelegate = self
        vc.item = cart!.items[indexPath.row].item
        vc.imageId = (tableView.cellForRow(at: indexPath) as? CartItemTableViewCell)?.getImageId()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .auto, dismissing: .uncover(direction: .down))
        present(nav, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == 0 && cart?.items.isEmpty ?? true) ? 300 : 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return cart?.items.isEmpty ?? true ? UIView() : nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cart = self.cart, let schedule = self.schedule else {
            return nil
        }
        let header = CartHeaderView()
        header.load(cart: cart, schedule: schedule)
        return header
    }
}

extension CartViewController: CartItemDelegate {
    func didUpdateCart() {
        self.fullLoad()
    }
}

extension CartViewController: EmptyTableViewCellDelegate {
    func tappedButton() {
        self.delegate?.changeToSearchTab()
        self.close(nil)
    }
}

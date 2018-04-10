//
//  CartVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

extension UIImage {
    public var tintable: UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
}

class CartViewController: UIViewController {
    
    private var cart: Cart?
    
    private var closeButton: UIBarButtonItem!
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let toolbar = UIView()
    private let toolbarBorder = UIView()
    private let checkoutButton = LoadingButton()
    private let checkoutPrice = UIView()
    private let checkoutPriceLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    private let refreshControl = UIRefreshControl()
    
    @objc private func refreshTable() {
        self.loadCart()
    }
    
    private func loadCart(_ completion: ((Bool) -> Void)? = nil) {
        Request.shared.getCart { result in
            switch result {
            case .success(let cart):
                self.cart = cart
                self.update()
                completion?(true)
            case .failure(let error):
                completion?(false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.fullLoad()
    }
    
    func fullLoad() {
        DispatchQueue.main.async {
            self.checkoutButton.showLoading()
            self.activityIndicator.startAnimating()
            self.tableView.isHidden = true
        }
        self.loadCart { _ in
            self.tableView.isHidden = false
            self.activityIndicator.stopAnimating()
            self.checkoutButton.hideLoading()
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
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // Toolbar
        toolbar.backgroundColor = UIColor(named: .backgroundGrey)
        view.addSubview(toolbar)
        
        // Toolbar border
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 0.5)
        toolbar.addSubview(toolbarBorder)
        
        // Add to cart
        checkoutButton.backgroundColor = UIColor(named: .green)
        checkoutButton.layer.cornerRadius = 5
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = Font.gotham(weight: .bold, size: 17)
        checkoutButton.addTarget(self, action: #selector(checkout(_:)), for: .touchUpInside)
        toolbar.addSubview(checkoutButton)
        
        checkoutPrice.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        checkoutPrice.layer.cornerRadius = 5
        checkoutPrice.isHidden = true
        checkoutButton.addSubview(checkoutPrice)
        
        checkoutPriceLabel.textColor = .white
        checkoutPriceLabel.textAlignment = .center
        checkoutPriceLabel.font = Font.gotham(size: 14)
        checkoutPrice.addSubview(checkoutPriceLabel)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func checkout(_ sender: LoadingButton) {
        sender.showLoading()
        Request.shared.getSchedule { result in
            switch result {
            case .success(let days):
                Request.shared.createCheckout { result in
                    sender.hideLoading()
                    switch result {
                    case .success(let checkout):
                        let vc = CheckoutSchedulerViewController()
                        vc.checkout = checkout
                        vc.schedule = days
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                sender.hideLoading()
                print(error.localizedDescription)
            }
        }
    }
    
    private func buildConstraints() {
        toolbar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(65)
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
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
    }
    
    @objc func close(_ sender: UIBarButtonItem?) {
        heroModalAnimationType = .pageOut(direction: .right)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension CartViewController: CartItemTableViewCellDelegate {
    func changeQuantity(new: Int, selectedItem: CartItem) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            if let items = self.cart?.items, let index = items.index(where: { $0.id == selectedItem.id }), let row = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CartItemTableViewCell {
                if new == row.stepper.value {
                    row.stepper.showLoading()
                    
                    Request.shared.updateCartQuantity(item: selectedItem.item, quantity: new) { result in
                        row.stepper.hideLoading()
                        switch result {
                        case .success(_):
                            print("success")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func delete(selectedItem: CartItem) {/*
        Request.shared.deleteCartItem(cartItem: selectedItem) {
            
        }*/
    }
    
    func addInstructions(selectedItem: CartItem) {
        let vc = InstructionsViewController()
        vc.item = selectedItem
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}

extension CartViewController: InstructionsViewControllerDelegate {
    func didMakeChanges() {
        self.fullLoad()
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
        vc.item = cart!.items[indexPath.row-1].item
        vc.imageId = (tableView.cellForRow(at: indexPath) as? CartItemTableViewCell)?.getImageId()
        heroModalAnimationType = .cover(direction: .up)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
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
        guard let _cart = self.cart else {
            return nil
        }
        let header = CartHeaderView()
        header.load(cart: _cart)
        return header
    }
}

extension CartViewController: EmptyTableViewCellDelegate {
    func tappedButton() {
        self.close(nil)
    }
}

/*
 class _CartVC: UIViewController {
 
 @IBOutlet weak var tableView: UITableView!
 
 @IBAction func close(_ sender: Any) {
 dismiss(animated: false, completion: nil)
 }
 
 override func viewDidLoad() {
 super.viewDidLoad()
 }
 }
 
 extension _CartVC: CartItemDelegate {
 func quantity(item: CartItem, new: Int) {
 Cart.current.changeQuantity(for: item, new: new)
 tableView.reloadData()
 }
 
 func delete(item: CartItem) {
 Cart.current.remove(item: item)
 tableView.reloadData()
 }
 
 func addInstructions(item: CartItem) {
 print("Add INstructions")
 }
 }
 
 extension _CartVC: UITableViewDelegate, UITableViewDataSource {
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 if Cart.current.items.value.isEmpty {
 tableView.separatorStyle = .none
 return 1
 }
 tableView.separatorStyle = .singleLine
 return Cart.current.items.value.count
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 if Cart.current.items.value.isEmpty {
 let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.cartEmptyCell.rawValue, for: indexPath) as! CartEmptyCell
 cell.action = {
 self.close(cell)
 }
 return cell
 }
 
 let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.cartItemCell.rawValue, for: indexPath) as! CartItemCell
 cell.delegate = self
 cell.load(item: Cart.current.items[indexPath.row])
 return cell
 }
 
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 if Cart.current.items.isEmpty {
 return
 }
 
 print("open item detail")
 }
 }
 
 protocol CartItemDelegate {
 func delete(item: CartItem)
 func quantity(item: CartItem, new: Int)
 func addInstructions(item: CartItem)
 }
 
 class CartEmptyCell: UITableViewCell {
 var action: (() -> ())? = nil
 
 @IBAction func shopNow(_ sender: Any) {
 action?()
 }
 }
 
 class CartItemCell: UITableViewCell {
 
 var delegate: CartItemDelegate?
 private var _item: CartItem?
 
 @IBOutlet weak var itemImage: UIImageView!
 @IBOutlet weak var name: UILabel!
 
 @IBOutlet weak var quantity: UILabel!
 @IBOutlet weak var price: UILabel!
 @IBOutlet weak var editDetailsButton: UIButton!
 
 @IBOutlet weak var deleteButton: UIButton!
 
 @IBAction func reduceQuantity(_ sender: Any) {
 if let item = _item {
 delegate?.quantity(item: item, new: max(1, item.quantity - 1))
 }
 }
 
 @IBAction func increaseQuantity(_ sender: Any) {
 if let item = _item {
 delegate?.quantity(item: item, new: item.quantity + 1)
 }
 }
 
 @IBAction func editDetails(_ sender: Any) {
 if let item = _item {
 delegate?.addInstructions(item: item)
 }
 }
 
 @IBAction func deleteItem(_ sender: Any) {
 if let item = _item {
 delegate?.delete(item: item)
 }
 }
 
 func load(item: CartItem) {
 _item = item
 name.text = _item?.item.name
 price.text = _item?.item.price.currencyFormat
 itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture Grey"))
 itemImage.pin_setImage(from: URL(string: C.URL.main + "/img/items/\(_item!.item.id).png")!)
 quantity.text = String(describing: _item?.quantity)
 }
 
 override func awakeFromNib() {
 editDetailsButton.setImage(#imageLiteral(resourceName: "Note").withRenderingMode(.alwaysTemplate), for: .normal)
 deleteButton.setImage(#imageLiteral(resourceName: "Delete").withRenderingMode(.alwaysTemplate), for: .normal)
 }
 
 }
 */

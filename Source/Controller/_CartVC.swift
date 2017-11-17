//
//  CartVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class _CartVC: UIViewController {
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension _CartVC: CartItemDelegate {
    func quantity(item: CartItem) {
        print("change quantity: \(item.item.name)")
    }
    
    func delete(item: CartItem) {
        print("delete cart item: \(item.item.name)")
    }
    
    func openDetail(for item: CartItem) {
        print("Open Item Detail")
    }
}

extension _CartVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.current.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.cartItemCell, for: indexPath) as! CartItemCell
        cell.delegate = self
        cell.load(item: Cart.current.items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("open detail for item")
    }
}

protocol CartItemDelegate {
    func delete(item: CartItem)
    func quantity(item: CartItem)
    func openDetail(`for` item: CartItem)
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
        _item!.quantity = max(1, _item!.quantity - 1)
        delegate?.quantity(item: _item!)
    }
    
    @IBAction func increaseQuantity(_ sender: Any) {
        _item!.quantity += 1
        delegate?.quantity(item: _item!)
    }
    
    @IBAction func editDetails(_ sender: Any) {
        print("Add Instructions")
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        delegate?.delete(item: _item!)
    }
    
    func load(item: CartItem) {
        _item = item
        name.text = _item?.item.name
        price.text = _item?.item.price.currency_format
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture Grey"))
        itemImage.pin_setImage(from: URL(string: C.URL.main + "/img/items/\(_item!.item.id).png")!)
        quantity.text = String(describing: _item?.quantity)
    }
    
    override func awakeFromNib() {
        editDetailsButton.setImage(#imageLiteral(resourceName: "Edit").withRenderingMode(.alwaysTemplate), for: .normal)
        deleteButton.setImage(#imageLiteral(resourceName: "Delete").withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
}

//
//  CartVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class _CartVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
/*
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

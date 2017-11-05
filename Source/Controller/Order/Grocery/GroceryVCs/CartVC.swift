//
//  GroceryCartVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 04/01/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class CartVC: GroceryVC {
    
    //MARK: - Properties
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: LargeButton!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        nextButton.action = {
            if !GroceryList.current.items.isEmpty {
                self.delegate.next()
            }
        }
        
        tableView.delaysContentTouches = false
        tableView.canCancelContentTouches = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.update()
    }
    
    //MARK: - Methods
    func update() {
        tableView.reloadData()
        updateTotal()
    }
    
    func updateTotal() {
        delegate.updateTotals()
        self.total.text = GroceryList.current.total.currency_format
        self.itemCount.text = "\(GroceryList.current.items.count) item\(GroceryList.current.items.count != 1 ? "s" : "")"
    }
}

//MARK: - UITableView
extension CartVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        GroceryList.current.items = unique(GroceryList.current.items)
        self.updateTotal()
        return GroceryList.current.items.isEmpty ? 1 : GroceryList.current.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if GroceryList.current.items.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nothingCell", for: indexPath) as! NothingCartCell
            cell.addItems.action = {
                if self.delegate.switchVC(to: 0) {
                    self.delegate.didNavigate()
                }
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CartCell
        let d = GroceryList.current.items[indexPath.row]
        
        cell.id = d.0.id
        cell.count = d.1
        cell.name.text = d.0.name
        let a = NSMutableAttributedString(string: "\(d.0.price.currency_format)  |  \(d.0.category.capitalizingFirstLetter())")
        a.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.green, range: NSMakeRange(0, d.0.price.currency_format.length))
        cell.subtitle.attributedText = a
        
        cell.minusButton.action = {
            if cell.count == 1 {
                cell.toggleDelete(true)
            } else {
                cell.count -= 1
                GroceryList.current.items[indexPath.row].1 = cell.count
                self.updateTotal()
            }
        }
        
        cell.plusButton.action = {
            cell.count += 1
            GroceryList.current.items[indexPath.row].1 = cell.count
            self.updateTotal()
        }
        
        cell.deleteButton.action = {
            GroceryList.current.items.remove(at: indexPath.row)
            self.update()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let c = tableView.cellForRow(at: indexPath), let cell = c as? CartCell else {
            return
        }
        cell.toggleDelete()
    }
}

//MARK: - UITableViewCell
class NothingCartCell: UITableViewCell {
    @IBOutlet weak var addItems: LargeButton!
}

class CartCell: UITableViewCell {
    //MARK: - Properties
    var id = 0
    var showingDelete = false
    
    //MARK: - Methods
    func toggleDelete(_ show: Bool? = nil) {
        var t = showingDelete
        if show != nil {
            t = !show!
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.frame.origin.x = t ? 0 : -116
            self.deleteButton.frame.origin.x = t ? self.frame.width : self.frame.width - 100
        }) { _ in
            self.showingDelete = !t
        }
    }
    
    override func awakeFromNib() {
        self.maskBoundView.layer.masksToBounds = true
    }
    
    //MARK:  - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var maskBoundView: UIView!
    
    @IBOutlet weak var quantity: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var plusButton: LargeButton!
    @IBOutlet weak var minusButton: LargeButton!
    
    @IBOutlet weak var deleteButton: LargeButton!
    
    var count = 1 {
        didSet {
            if count < 1 { count = 1 }
            self.quantity.text = "\(count)"
        }
    }
}

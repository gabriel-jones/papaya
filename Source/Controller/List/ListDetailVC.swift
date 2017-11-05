//
//  ListDetailVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 15/09/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import XLActionController

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

class ListDetailVC: UIViewController {
    //Properties
    var list: List!
    
    var categories: [String] {
        get {
            return list.list.items.map { $0.0.category }.unique
        }
    }
    
    func items(in category: String) -> [(Item, Int)] {
        return list.list.items.filter { $0.0.category == category }
    }
    
    func item(in indexPath: IndexPath) -> (Item, Int) {
        return items(in: categories[indexPath.section])[indexPath.row]
    }
    
    //Outlets
    @IBOutlet weak var listName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    //Actions
    
    //Methods
    override func viewDidLoad() {
        listName.text = list.name
    }
    
    func deleteList() {
        print("delete list!")
    }
}

extension ListDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items(in: categories[section]).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == categories.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath) as! DeleteListCell
            cell.onDelete = {
                self.deleteList()
            }
            return cell
        }
        
        let item = self.item(in: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListItemCell
        cell.name.text = item.0.name
        cell.quantity.text = "Quantity: \(item.1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select: \(indexPath)")
        print("select item: \(item(in: indexPath).0.name)")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
}

class ListItemCell: UITableViewCell {
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
}

class DeleteListCell: UITableViewCell {
    var onDelete: (() -> ())? = nil
    @IBAction func deleteList(_ sender: Any) {
        onDelete?()
    }
}

//
//  FilterVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 04/01/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit


class FilterVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: ShoppingPageDelegate!
    
    //MARK: - Outlets
    @IBOutlet weak var close: LargeButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var table: UITableView!
    
    
    //MARK: - Properties
    var categories: [String] = []
    var shops: [String] = []
    var current: (Int, Int) = (0,0)
    
    //MARK: - Methods
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if !self.contentView.point(inside: t.location(in: self.contentView), with: event) {
                self.closeVC(nil)
            }
        }
    }
    
    func closeVC(_ new: IndexPath?) {
        self.delegate.updateFilter(new: new)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.categories = ["All"]
        self.categories += delegate.getCategories()
        
        self.shops = ["All"]
        self.shops += delegate.getShops()
        
        self.current = delegate.getCurrent()
        
        close.action = {
            self.closeVC(nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.shops.count == 1 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 && !(self.shops.count == 1) ? "SHOP" : "CATEGORY"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.closeVC(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 && !(self.shops.count == 1) ? self.shops.count : self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 && !(self.shops.count == 1) {
            let d = self.shops[indexPath.row]
            c.accessoryType = indexPath.row == current.0 ? .checkmark : .none
            c.textLabel?.text = d
        } else {
            let d = self.categories[indexPath.row].capitalizingFirstLetter()
            c.accessoryType = indexPath.row == current.1 ? .checkmark : .none
            c.textLabel?.text = d
        }
        return c
    }
    
}

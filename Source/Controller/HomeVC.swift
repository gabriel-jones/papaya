//
//  HomeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SnapKit

class HomeVC: TabChildVC {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var itemModel = ItemModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: C.ViewModel.Nib.itemGroupCell, bundle: nil), forCellReuseIdentifier: C.ViewModel.CellIdentifier.itemGroupCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc func viewAll(_ sender: UIButton) {
        print("view all for button: \(sender)")
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
            cell.backgroundColor = .clear
            let label = UILabel(frame: cell.frame)
            label.textAlignment = .center
            label.text = "Good Morning, Gabriel"
            label.font = Font.gotham(size: 15)
            label.textColor = Color.grey.3
            cell.addSubview(label)
            return cell
        }
        
        let titles = ["Today's Specials", "Recommended for You"]
        print("reloading")
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.itemGroupCell, for: indexPath) as! ItemGroupTableViewCell
        cell.setTitle(to: titles[indexPath.row-1])
        cell.itemModel = itemModel
        cell.viewAllItems = { sectionId in
            print("View All items")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heights: [CGFloat] = [35, 250, 250]
        return heights[indexPath.row]
    }
}

protocol ItemDelegateAction {
    func open(item: Item)
}

extension HomeVC: ItemDelegateAction {
    func open(item: Item) {
        print("open item")
    }
}

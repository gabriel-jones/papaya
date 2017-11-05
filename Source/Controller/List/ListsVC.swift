//
//  ListsVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 15/09/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import XLActionController

class List: PPObj {
    var name: String!
    var list: GroceryList!
    
    init(j: JSON) {
        self.name = j["name"].stringValue
        self.list = GroceryList(j: j)
        super.init(id: j["id"].intValue)
    }
    
    func json() -> JSON {
        return [
            "id": self.id,
            "name": self.name,
            "list": self.list.json()!.stringValue
        ]
    }
}

protocol ListProtocol {
    func didDeleteList(_ list: List)
    func didEditList()
    func didChooseList(_ list: List)
}

class ListsVC: BaseVC {
    
    //Properties
    
    var lists = [
        List(j: JSON([
            "name": "Mondays",
            "shop_id": 5,
            "items": [
                [
                    "id": 1,
                    "name": "Apple",
                    "shop_id": 5,
                    "price": 15.99,
                    "stock": 12,
                    "category": "produce",
                    "isLiked": false,
                    "hasImage": "1",
                    "quantity": 2
                ],
                [
                    "id": 2,
                    "name": "Banana",
                    "shop_id": 5,
                    "price": 15.99,
                    "stock": 11,
                    "category": "produce",
                    "isLiked": true,
                    "hasImage": "1",
                    "quantity": 5
                ]
            ]
        ]))
    ]
    
    //[List]()
    
    //IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    //IBActions
    @IBAction func close(_ sender: UIButton) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func addList(_ sender: Any) {
        let alert = UIAlertController(title: "Add List", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "From Image", style: .default) { _ in
            
        })
    }
    
    //Methods
    override func viewDidLoad() {
        //getLists()
        let textField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textField.font = UIFont(name: "GothamRounded-Medium", size: 18)
    }
    
    func getLists(_ completion: (() -> ())? = nil) {
        let a = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        a.center = view.center
        view.addSubview(a)
        a.startAnimating()

        tableView.isHidden = true
        
        let parameters = [
            "user_id": User.current.id,
            "mode": "",
            "p": 1,
            "q": self.searchBar.text!
        ] as [String : Any]
        R.get("/scripts/Lists/lists.php", parameters: parameters) { json, error in
            a.removeFromSuperview()
            
            guard !error, let json = json else {
                return
            }
            
            self.lists = json.map { List(j: $0.1) }
            self.tableView.reloadData()
            
            completion?()
        }
    }
}

extension ListsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListCell
        let list = lists[indexPath.row]
        cell.title.text = list.name
        cell.subtitle.text = "\(list.list.items.count) items"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ListDetailVC.instantiate(from: .lists)
        vc.list = lists[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ListsVC: ListProtocol {
    func didDeleteList(_ list: List) {
        
    }
    
    func didEditList() {
        
    }
    
    func didChooseList(_ list: List) {
        
    }
}

extension ListsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

class ListCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}

//
//  InventoryVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 17/09/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

protocol InventoryVCDelegate {
    func openOverlay(_ vc: UIViewController, animated: Bool)
    func closeOverlay()
    func getCategories() -> [String]
}

class InventoryVC: UIViewController, UISearchBarDelegate, UIScrollViewDelegate, InventoryVCDelegate {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed" {
            (segue.destination as! ShoppingVC).inv_delegate = self
        }
    }
    
    var v = UIView()
    
    func openOverlay(_ vc: UIViewController, animated: Bool) {
        v.frame = self.view.frame
        v.alpha = 0.6
        v.backgroundColor = .black
        self.view.addSubview(v)
        
        present(vc, animated: animated, completion: nil)
    }
    
    func closeOverlay() {
        print("closing overlay")
        self.v.removeFromSuperview()
    }
    
    func getCategories() -> [String] {
        var c: [String] = []
        for s in Shop.all {
            c += s.categories
        }
        return Array(Set(c)).sorted()
    }
    
    @IBAction func close(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

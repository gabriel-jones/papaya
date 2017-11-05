//
//  Grocery.swift
//  PrePacked
//
//  Created by Gabriel Jones on 04/01/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

func unique(_ items: Array<(Item,Int)>) -> Array<(Item,Int)> {
    //var buffer = [(Item,Int)]()
    var unique = [(Item,Int)]()
    for i in items {
        if let index = unique.index(where: {$0.0.id == i.0.id}) { //not a unique element
            let u = unique[index]
            unique.append((u.0, u.1+i.1 > u.0.stock ? u.0.stock : u.1+i.1))
            unique.remove(at: index)
        } else {
            unique.append(i)
        }
    }
    
    return unique
}

protocol GroceryDelegate: class {
    func switchVC(to index: Int) -> Bool
    func addItemToCart(_ item: Item, _ quantity: Int)
    func didNavigate()
    func next()
    func delegateAddOverlay(_ vc: UIViewController, animated: Bool)
    func delegateRemoveOverlay()
    
    func getSearchText() -> String
    func clearSearch()
    func endEditing()
    func updateTotals()
}

class GroceryVC: BaseVC {
    weak var delegate: GroceryDelegate!
}

protocol ItemDetailDelegate {
    func addItem(i: Item, n: Int)
    func didClose()
    func didCloseWith(item: Item?)
    func changeLiked(i: Item, liked: Bool)
    func getImage(id: Int) -> UIImage?
}

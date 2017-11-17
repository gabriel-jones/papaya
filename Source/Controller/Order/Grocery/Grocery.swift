//
//  Grocery.swift
//  PrePacked
//
//  Created by Gabriel Jones on 04/01/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

func unique(_ items: [CartItem]) -> [CartItem] {
    //var buffer = [(Item,Int)]()
    var unique = [CartItem]()
    for i in items {
        if let index = unique.index(where: {$0.item.id == i.item.id}) { //not a unique element
            let u = unique[index]
            unique.append(CartItem(item: u.item, quantity:  u.quantity+i.quantity > u.item.stock ? u.item.stock : u.quantity+i.quantity))
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

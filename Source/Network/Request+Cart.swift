//
//  Request+Cart.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension Request {
    func getCart() -> Observable<Cart> {
        if let request = URLRequest.get(path: "/cart") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap(json2Cart)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func addItem(to cart: Cart, item: Item, quantity: Int) -> Observable<JSON> {
        let body = [
            "item_id": item.id,
            "quantity": quantity
        ]
        if let request = URLRequest.post(path: "/cart/item/add", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func updateQuantity(with cartItem: CartItem) -> Observable<JSON> {
        let body = [
            "item_id": cartItem.id,
            "quantity": cartItem.quantity
        ]
        if let request = URLRequest.put(path: "/cart/item/update/quantity", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func update(cartItem: CartItem) -> Observable<JSON> {
        let body = cartItem.rawdict
        if let request = URLRequest.put(path: "/cart/item/update", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func delete(cartItem: CartItem) -> Observable<JSON> {
        let urlParameters = [
            "item_id": String(cartItem.id)
        ]
        if let request = URLRequest.delete(path: "/cart/item/update/quantity", body: [:], urlParameters: urlParameters) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
}

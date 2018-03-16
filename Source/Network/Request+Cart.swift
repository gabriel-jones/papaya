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
        guard let request = URLRequest.get(path: "/cart") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
            .flatMap(parse.json2Cart)
    }
    
    func addItemToCart(item: Item, quantity: Int) -> Observable<JSON> {
        let body = [
            "item_id": item.id,
            "quantity": quantity
        ]
        guard let request = URLRequest.post(path: "/cart/item/add", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
    
    func updateQuantity(with itemId: Int, new quantity: Int) -> Observable<JSON> {
        let body = [
            "item_id": itemId,
            "quantity": quantity
        ]
        print(body)
        guard let request = URLRequest.put(path: "/cart/item/update/quantity", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
    
    func update(cartItem: CartItem) -> Observable<JSON> {
        let body = cartItem.rawdict
        guard let request = URLRequest.put(path: "/cart/item/update", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
    
    func delete(cartItem: CartItem) -> Observable<JSON> {
        let urlParameters = [
            "item_id": String(cartItem.id)
        ]
        guard let request = URLRequest.delete(path: "/cart/item/delete", body: [:], urlParameters: urlParameters) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
}

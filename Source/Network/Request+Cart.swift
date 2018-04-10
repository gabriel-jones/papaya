//
//  Request+Cart.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    
    @discardableResult
    public func getCart(completion: (CompletionHandler<Cart>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/cart") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Cart, completion: completion)
    }
    
    @discardableResult
    public func addToCart(item: Item, quantity: Int, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "item_id": item.id,
            "quantity": quantity
        ]
        guard let request = URLRequest.post(path: "/cart/item/add", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateCartQuantity(item: Item, quantity: Int, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "item_id": item.id,
            "quantity": quantity
        ]
        guard let request = URLRequest.put(path: "/cart/item/update/quantity", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateCartItem(cartItem: CartItem, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = cartItem.rawdict
        guard let request = URLRequest.put(path: "/cart/item/update", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func deleteCartItem(cartItem: CartItem, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let urlParameters = [
            "item_id": String(cartItem.id)
        ]
        guard let request = URLRequest.delete(path: "/cart/item/delete", body: [:], urlParameters: urlParameters) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
}

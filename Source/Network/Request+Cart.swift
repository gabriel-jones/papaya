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
    public func getCartCount(completion: (CompletionHandler<Int>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/cart/count") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2ItemCount, completion: completion)
    }
    
    @discardableResult
    public func getCart(completion: (CompletionHandler<Cart>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/cart") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Cart, completion: completion)
    }
    
    @discardableResult
    public func addToCart(item: Item, quantity: Int, completion: (CompletionHandler<CartItem>)? = nil) -> URLSessionDataTask? {
        let body = [
            "item_id": item.id,
            "quantity": quantity
        ]
        guard let request = URLRequest.post(path: "/cart/item/add", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2CartItem, completion: completion)
    }
    
    @discardableResult
    public func getCartItem(item: Item, completion: (CompletionHandler<CartItem>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/cart/item/get/\(item.id)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2CartItem, completion: completion)
    }
    
    @discardableResult
    public func updateCartQuantity(item: Item, quantity: Int, completion: (CompletionHandler<CartItem>)? = nil) -> URLSessionDataTask? {
        let body = [
            "item_id": item.id,
            "quantity": quantity
        ]
        guard let request = URLRequest.put(path: "/cart/item/update/quantity", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2CartItem, completion: completion)
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
    public func deleteCartItem(item: Item, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let urlParameters = [
            "item_id": String(item.id)
        ]
        guard let request = URLRequest.delete(path: "/cart/item/delete", body: [:], urlParameters: urlParameters) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func deleteAllItemsFromCart(completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.delete(path: "/cart/remove_all_items") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
}

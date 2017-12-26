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
    func getCart(completion: @escaping (Result<Cart>) -> ()) throws -> URLSessionDataTask {
        do {
            guard let request = URLRequest.get(path: "/cart")
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<Cart> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
                    .flatMap(json2Cart)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func addItem(to cart: Cart, item: Item, quantity: Int, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = [
                "item_id": item.id,
                "quantity": quantity
            ]
            guard let request = URLRequest.post(path: "/cart/item/add", body: body)
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func updateQuantity(with cartItem: CartItem, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = [
                "item_id": cartItem.id,
                "quantity": cartItem.quantity
            ]
            guard let request = URLRequest.patch(path: "/cart/item/update/quantity", body: body)
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func update(cartItem: CartItem, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = cartItem.rawdict
            guard let request = URLRequest.patch(path: "/cart/item/update", body: body)
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func delete(cartItem: CartItem, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            guard let request = URLRequest.delete(path: "/cart/item/delete", body: [:], urlParameters: ["item_id": "\(cartItem.id)"])
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
}

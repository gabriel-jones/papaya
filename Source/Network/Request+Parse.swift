//
//  Request+Parse.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension Request {    
    internal class Parse {
        func jsonDict2Object<T: BaseObject>(from json: JSON, to type: T.Type) -> Observable<T> {
            if let object = T(dict: json) {
                return Observable.just(object)
            }
            return Observable.error(RequestError.failedToParseJson)
        }
        
        func jsonArray2Array<T: BaseObject>(from json: JSON, to type: T.Type) -> Observable<[T]> {
            if let json = json.array {
                var array = [T]()
                for element in json {
                    if let object = T(dict: element) {
                        array.append(object)
                    } else {
                        return Observable.error(RequestError.failedToParseJson)
                    }
                }
                return Observable.just(array)
            }
            return Observable.error(RequestError.failedToParseJson)
        }
        
        func json2User(from json: JSON) -> Observable<User> {
            return jsonDict2Object(from: json["user"], to: User.self)
        }
        
        func json2Addresses(from json: JSON) -> Observable<[Address]> {
            return jsonArray2Array(from: json["addresses"], to: Address.self)
        }
        
        func json2Address(from json: JSON) -> Observable<Address> {
            return jsonDict2Object(from: json["address"], to: Address.self)
        }
        
        func json2List(from json: JSON) -> Observable<List> {
            return jsonDict2Object(from: json["list"], to: List.self)
        }
        
        func json2Lists(from json: JSON) -> Observable<[List]> {
            return jsonArray2Array(from: json["lists"], to: List.self)
        }
        
        func json2Cart(from json: JSON) -> Observable<Cart> {
            return jsonDict2Object(from: json["cart"], to: Cart.self)
        }
        
        func json2Token(from json: JSON) -> Observable<String?> {
            return Observable.just(json["auth_token"].string)
        }
        
        func json2Items(from json: JSON) -> Observable<[Item]> {
            return jsonArray2Array(from: json["items"], to: Item.self)
        }
        
        func json2Category(from json: JSON) -> Observable<Category> {
            return jsonDict2Object(from: json["category"], to: Category.self)
        }
        
        func json2Categories(from json: JSON) -> Observable<[Category]> {
            return jsonArray2Array(from: json["categories"], to: Category.self)
        }
        
        func json2Subcategories(from json: JSON) -> Observable<[Category]> {
            return jsonArray2Array(from: json["subcategories"], to: Category.self)
        }

    }
}


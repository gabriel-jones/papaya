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

func response2Data(selector: Response) throws -> Observable<Data> {
    guard let data = selector.data else {
        return Observable.error(RequestError.unknown)
    }
    return Variable(data).asObservable()
}

func data2Json(selector: Data) throws -> Observable<JSON> {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: selector, options: [])
        let json = JSON(jsonObject)
        guard let code = json["code"].int else {
            return Observable.error(RequestError.unknown)
        }
        
        let error = RequestError(rawValue: code)
        if error != .success {
            return Observable.error(error ?? .unknown)
        }
        
        return Variable(json).asObservable()
    } catch {
        return Observable.error(RequestError.failedToParseJson)
    }
}

func json2Type<T: BaseObject>(from json: JSON, to type: T.Type) -> T? {
    if let object = T(dict: json) {
        return object
    }
    return nil
}

func jsonDict2Object<T: BaseObject>(from json: JSON, to type: T.Type) -> Observable<T> {
    if let object = T(dict: json) {
        return Observable.just(object)
    }
    return Observable.error(RequestError.failedToParseJson)
}

func jsonArray2Array<T: BaseObject>(from json: JSON, to type: T.Type) -> Observable<[T]> {
    return Observable<[T]>.create { observer in
        if let json = json.array {
            var array = [T]()
            for element in json {
                if let object = T(dict: element) {
                    array.append(object)
                } else {
                    observer.onError(RequestError.failedToParseJson)
                    break
                }
            }
            observer.onNext(array)
        } else {
            observer.onError(RequestError.failedToParseJson)
        }
        
        return Disposables.create()
    }
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
    return Variable(json["auth_token"].string).asObservable()
}

func json2Items(from json: JSON) -> Observable<[Item]> {
    
    
    return jsonArray2Array(from: json["items"], to: Item.self)
}

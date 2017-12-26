//
//  Request+Parse.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

func response2Data(from response: Response) -> Result<Data> {
    guard let data = response.data else {
        return .failure(RequestError.unknown)
    }
    return .success(data)
}

func data2Json(from data: Data) -> Result<JSON> {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let json = JSON(jsonObject)
        guard let code = json["code"].int else {
            return Result(error: RequestError.unknown)
        }
        
        let error = RequestError(rawValue: code)
        if error != .success {
            return Result(error: error)
        }
        
        return Result(value: json)
    } catch {
        return Result(error: RequestError.failedToParseJsonToObject)
    }
}

func jsonDict2Object<T: BaseObject>(from json: JSON, to type: T.Type) -> Result<T> {
    if let object = T(dict: json) {
        return Result(value: object)
    }
    return Result(error: RequestError.failedToParseJsonToObject)
}

func jsonArray2Array<T: BaseObject>(from json: JSON, to type: T.Type) -> Result<[T]> {
    guard let json = json.array else {
        return Result(error: RequestError.failedToParseJsonToArray)
    }
    
    var array = [T]()
    for element in json {
        if let object = T(dict: element) {
            array.append(object)
        } else {
            return Result(error: RequestError.failedToParseJsonToObject)
        }
    }
    
    return Result(value: array)
}

func json2User(from json: JSON) -> Result<User> {
    return jsonDict2Object(from: json["user"], to: User.self)
}

func json2Addresses(from json: JSON) -> Result<[Address]> {
    return jsonArray2Array(from: json["addresses"], to: Address.self)
}

func json2Address(from json: JSON) -> Result<Address> {
    return jsonDict2Object(from: json["address"], to: Address.self)
}

func json2List(from json: JSON) -> Result<List> {
    return jsonDict2Object(from: json["list"], to: List.self)
}

func json2Lists(from json: JSON) -> Result<[List]> {
    return jsonArray2Array(from: json["lists"], to: List.self)
}

func json2Cart(from json: JSON) -> Result<Cart> {
    return jsonDict2Object(from: json["cart"], to: Cart.self)
}

func json2Token(from json: JSON) -> Result<String> {
    return Result(fromOptional: json["auth_token"].string, error: RequestError.failedToParseJsonToObject)
}

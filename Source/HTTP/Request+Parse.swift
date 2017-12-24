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
    if !(200..<300 ~= response.statusCode) {
        return .failure(HTTPResponseCode(response.statusCode))
    }
    return .success(response.data)
}

func data2Json(from data: Data) -> Result<JSON> {
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return Result(value: JSON(json))
    } catch {
        return Result(error: error)
    }
}

func json2Object<T>(from json: JSON, type: T.Type) -> Result<T> {
    guard let objectBuilder = ObjectBuilder<T>() else {
        return Result(error: RequestError.failedToParseJsonToObject)
    }
    
    if !objectBuilder.validate(json: json) {
        return Result(error: RequestError.failedToParseJsonToObject)
    }
    
    if let object = objectBuilder.parse(json: json) {
        return Result(value: object)
    } else {
        return Result(error: RequestError.failedToParseJsonToObject)
    }
}

func json2User(from json: JSON) -> Result<User> {
    return json2Object(from: json, type: User.self)
}

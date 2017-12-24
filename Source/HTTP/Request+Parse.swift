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

func json2Object<T: BaseObject>(from json: JSON, to type: T.Type) -> Result<T> {
    if let object = T(dict: json) {
        return Result(value: object)
    }
    return Result(error: RequestError.failedToParseJsonToObject)
}

func json2User(from json: JSON) -> Result<User> {
    return json2Object(from: json, to: User.self)
}

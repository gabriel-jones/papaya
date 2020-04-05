//
//  Request+Parse.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {    
    internal class Parse {
        func response2Data(from response: Response) -> Result<Data> {
            guard let data = response.data else {
                return .failure(.unknown)
            }
            return .success(data)
        }
        
        func data2Json(from data: Data) -> Result<JSON> {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                let json = JSON(jsonObject)

                guard let code = json["code"].int else {
                    return Result(error: .unknown)
                }
                
                let error = RequestError(rawValue: code)
                if error != .succ {
                    return Result(error: error)
                }
                
                return Result(value: json)
            } catch {
                return Result(error: .failedToParseJson)
            }
        }

        func jsonDict2Object<T: BaseObject>(from json: JSON, to type: T.Type) -> Result<T> {
            return Result(fromOptional: T(dict: json), error: .failedToParseJson)
        }
        
        func jsonArray2Array<T: BaseObject>(from json: JSON, to type: T.Type) -> Result<[T]> {
            if let json = json.array {
                var array = [T]()
                for element in json {
                    if let object = T(dict: element) {
                        array.append(object)
                    } else {
                        return Result(error: .failedToParseJson)
                    }
                }
                return Result(value: array)
            }
            return Result(error: .failedToParseJson)
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
            return Result(fromOptional: json["auth_token"].string, error: .failedToParseJson)
        }
        
        func json2Items(from json: JSON) -> Result<[Item]> {
            return jsonArray2Array(from: json["items"], to: Item.self)
        }
        
        func json2Category(from json: JSON) -> Result<Category> {
            return jsonDict2Object(from: json["category"], to: Category.self)
        }
        
        func json2Categories(from json: JSON) -> Result<[Category]> {
            return jsonArray2Array(from: json["categories"], to: Category.self)
        }
        
        func json2Subcategories(from json: JSON) -> Result<[Category]> {
            return jsonArray2Array(from: json["subcategories"], to: Category.self)
        }
        
        func json2Searches(from json: JSON) -> Result<[String]> {
            return Result(fromOptional: json["searches"].array?.map { $0.stringValue }, error: .failedToParseJson)
        }
        
        func json2Checkout(from json: JSON) -> Result<Checkout> {
            return jsonDict2Object(from: json["checkout"], to: Checkout.self)
        }
        
        func json2ScheduleDays(from json: JSON) -> Result<[ScheduleDay]> {
            return jsonArray2Array(from: json["dates"], to: ScheduleDay.self)
        }
        
        func json2CartItem(from json: JSON) -> Result<CartItem> {
            return jsonDict2Object(from: json["cart_item"], to: CartItem.self)
        }
        
        func json2ItemCount(from json: JSON) -> Result<Int> {
            return Result(fromOptional: json["item_count"].int, error: .failedToParseJson)
        }
        
        func json2NotificationSettingGroup(from json: JSON) -> Result<[NotificationSettingGroup]> {
            return jsonArray2Array(from: json["notification_settings"], to: NotificationSettingGroup.self)
        }
        
        func json2Clubs(from json: JSON) -> Result<[Club]> {
            return jsonArray2Array(from: json["clubs"], to: Club.self)
        }
        
        func json2Object<T: BaseObject>(from json: JSON, key: String) -> Result<T> {
            return jsonDict2Object(from: json[key], to: T.self)
        }
        
        func json2Paginated<T: BaseObject>(from json: JSON, arrJson: JSON, with: T.Type) -> Result<PaginatedResults<T>> {
            let arr = jsonArray2Array(from: arrJson, to: T.self)
            let isLast = json["is_last"].boolValue
            let page = PaginatedResults(isLast: isLast, results: arr.value!)
            return Result(value: page)
        }
        
        func json2PaginatedItems(from json: JSON) -> Result<PaginatedResults<Item>> {
            return json2Paginated(from: json, arrJson: json["items"], with: Item.self)
        }
        
        func json2PaginatedSpecialItems(from json: JSON) -> Result<PaginatedResults<SpecialItem>> {
            return json2Paginated(from: json, arrJson: json["items"], with: SpecialItem.self)
        }
        
        func json2Order(from json: JSON) -> Result<Order> {
            return jsonDict2Object(from: json["order"], to: Order.self)
        }
        
        func json2OrderId(from json: JSON) -> Result<Int> {
            return Result(fromOptional: json["order_id"].int, error: .failedToParseJson)
        }
        
        func json2OrderStatus(from json: JSON) -> Result<OrderStatus> {
            return jsonDict2Object(from: json["order"], to: OrderStatus.self)
        }
        
        func json2PaymentMethods(from json: JSON) -> Result<Array<PaymentMethod>> {
            return jsonArray2Array(from: json["payments"], to: PaymentMethod.self)
        }
        
        func json2PaymentMethod(from json: JSON) -> Result<PaymentMethod> {
            return jsonDict2Object(from: json["payment"], to: PaymentMethod.self)
        }
        
        func json2PaymentMethodOptional(from json: JSON) -> Result<PaymentMethod?> {
            return Result(value: PaymentMethod(dict: json["payment"]))
        }
        
        func json2Subscription(from json: JSON) -> Result<Subscription> {
            return jsonDict2Object(from: json["subscription"], to: Subscription.self)
        }
        
        func json2OrderHistory(from json: JSON) -> Result<PaginatedResults<OrderHistory>> {
            return json2Paginated(from: json, arrJson: json["orders"], with: OrderHistory.self)
        }
    }
}

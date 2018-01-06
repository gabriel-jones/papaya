//
//  Request+List.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension Request {
    func getAllLists() -> Observable<[List]> {
        if let request = URLRequest.get(path: "/list/all") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap(json2Lists)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func get(list id: Int) -> Observable<List> {
        if let request = URLRequest.get(path: "/list/get/\(id)") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap(json2List)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func add(list name: String, items: [ListItem]) -> Observable<JSON> {
        let body: [String:Any] = [
            "name": name,
            "items": items.map { $0.rawdict }
        ]
        if let request = URLRequest.post(path: "/list/add", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func addItem(to list: List, item: ListItem) -> Observable<JSON> {
        let body = item.rawdict
        if let request = URLRequest.post(path: "/list/get/\(list.id)/item/add", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    /*
    @discardableResult
    func updateItem(for list: List, item: ListItem, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = item.rawdict
            
            guard let request = URLRequest.put(path: "/list/get/\(list.id)/item/update", body: body)
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
    }*/
    
    func updateItem(for list: List, item: ListItem) -> Observable<JSON> {
        let body = item.rawdict
        if let request = URLRequest.put(path: "/list/get/\(list.id)/item/update", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func deleteItem(from list: List, item: ListItem) -> Observable<JSON> {
        let urlParameters = [
            "item_id": String(item.id)
        ]
        if let request = URLRequest.delete(path: "/list/add", body: [:], urlParameters: urlParameters) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func update(list: List) -> Observable<JSON> {
        let body = [
            "name": list.name
        ]
        if let request = URLRequest.put(path: "/list/get/\(list.id)/update", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func delete(list: List) -> Observable<JSON> {
        if let request = URLRequest.delete(path: "/list/get/\(list.id)/delete") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
}

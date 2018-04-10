//
//  Request+List.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
extension Request {
    func getAllLists() -> Observable<[List]> {
        guard let request = URLRequest.get(path: "/list/all") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
            .flatMap(parse.json2Lists)
    }
    
    func get(list id: Int) -> Observable<List> {
        guard let request = URLRequest.get(path: "/list/get/\(id)") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
            .flatMap(parse.json2List)
    }
    
    func add(list name: String, items: [ListItem]) -> Observable<JSON> {
        let body: [String:Any] = [
            "name": name,
            "items": items.map { $0.rawdict }
        ]
        guard let request = URLRequest.post(path: "/list/add", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
    
    func addItem(to list: List, item: ListItem) -> Observable<JSON> {
        let body = item.rawdict
        guard let request = URLRequest.post(path: "/list/get/\(list.id)/item/add", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
    
    func updateItem(for list: List, item: ListItem) -> Observable<JSON> {
        let body = item.rawdict
        guard let request = URLRequest.put(path: "/list/get/\(list.id)/item/update", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
    
    func deleteItem(from list: List, item: ListItem) -> Observable<JSON> {
        let urlParameters = [
            "item_id": String(item.id)
        ]
        
        guard let request = URLRequest.delete(path: "/list/add", body: [:], urlParameters: urlParameters) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
    
    func update(list: List) -> Observable<JSON> {
        let body = [
            "name": list.name
        ]
        guard let request = URLRequest.put(path: "/list/get/\(list.id)/update", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
            .observeOn(MainScheduler.instance)
    }
    
    func delete(list: List) -> Observable<JSON> {
        guard let request = URLRequest.delete(path: "/list/get/\(list.id)/delete") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
    }
}
*/

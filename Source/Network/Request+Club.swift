//
//  Request+Club.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/1/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation

extension Request {
    
    @discardableResult
    public func getAllClubs(completion: (CompletionHandler<[Club]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/club/all") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Clubs, completion: completion)
    }
    /*
    @discardableResult
    public func getClub(clubId: Int, completion: (CompletionHandler<Club>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/club/get/\(clubId)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Club, completion: completion)
    }*/
}

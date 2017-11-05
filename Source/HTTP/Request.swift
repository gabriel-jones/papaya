//
//  Request.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class R {
    enum EmailCheck {
        case invalid
        case taken
        case valid
        case requestError
    }
    
    static func finishOrder(id: Int, image: UIImage, items: [PackItem], _ completion: ((JSON?, Bool)->())? = nil) {
        let params = JSON([
            "order_id": id,
            "items": items.map({ $0.toArray() })
            ])
        R.Image.uploadImage("/scripts/Packer/finish_packing.php", parameters: params, image: image, completion: completion)
    }
    
    static func clearRequests() {
        print("clear requests")
        for t in requests {
            if t.state == .running {
                t.cancel()
            }
            if t.state != .canceling {
                requests.remove(at: requests.index(of: t)!)
            }
        }
    }
    
    static var requests: [URLSessionDataTask] = []
    
    static func verifyEmail(_ email: String, comp: @escaping (Bool) -> ()) {
        R.get("/scripts/User/verify_email.php", parameters: ["email": email]) { json, error in
            if let j = json {
                comp(j["success"].boolValue)
            } else {
                comp(false)
            }
        }
    }
    
    static func checkEmail(_ email: String, comp: @escaping ((EmailCheck)->())) {
        let u = C.URL.main + "/scripts/User/email_taken.php?email=\(email.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)"
        var r = URLRequest(url: URL(string: u)!)
        r.httpMethod = "GET"
        
        let t = URLSession.shared.dataTask(with: r) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    comp(.requestError)
                } else {
                    let d = String(data: data!)
                    print(d)
                    if d == "invalid" {
                        comp(.invalid)
                    } else if d == "false" {
                        comp(.valid)
                    } else if d == "true" {
                        comp(.taken)
                    } else {
                        comp(.requestError)
                    }
                }
            }
        }
        t.resume()
        requests.append(t)
    }
    
    static func addAuthorization(request: inout URLRequest) {
        do {
            if let p = try keychain.get("user_password"), let e = try keychain.get("user_email") {
                request.addValue("Basic " + (e + ":" + p).toBase64(), forHTTPHeaderField: "Authorization")
            }
        } catch {
            print("Could not get variable from keychain. Exiting...")
            exit(-666)
        }
    }
    
    static func get(_ url: String, parameters: [String: Any] = [:], _ completion: ((JSON?, Bool)->())? = nil) {
        var u = C.URL.main + url
        if !parameters.isEmpty {
            u += "?"
            for p in parameters {
                u += "\(p.0)=\(String(describing: p.1).addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)&"
            }
            u.remove(at: u.characters.index(before: u.endIndex))
        }
        let url = URL(string: u)
        var r = URLRequest(url: url!)
        addAuthorization(request: &r)
        r.httpMethod = "GET"
        print("Get: \(String(describing: url))")
        let t = URLSession.shared.dataTask(with: r) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.allHeaderFields)
                }
                if let c = completion {
                    var j: JSON? = nil
                    if let d = data {
                        j = JSON(data: d)
                    }
                    c(j, error != nil)
                }
            }
        }
        t.resume()
        requests.append(t)
    }
    
    static func post(_ url: String, parameters: [String:Any], data: Data? = nil, _ completion: ((JSON?, Bool)->())? = nil) {
        print("starting post")
        let u = C.URL.main + url
        let url = URL(string: u)
        var r = URLRequest(url: url!)
        addAuthorization(request: &r)
        r.httpMethod = "POST"
        
        if let d = data {
            let body = NSMutableData()
            let boundary = "Boundary-\(UUID().uuidString)"
            r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"data\"\r\n\r\n")
            var s = ""
            for (k,v) in parameters {
                s += "\(k)=\(v)&"
            }
            body.appendString("\(s)\r\n")
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"img\"; filename=\"img.png\"\r\n")
            body.appendString("Content-Type: image/png\r\n\r\n")
            body.append(d)
            body.appendString("\r\n")
            body.appendString("--\(boundary)--\r\n")
            r.httpBody = body as Data
        } else {
            let j = JSON(parameters).rawString()!.data(using: String.Encoding.utf8, allowLossyConversion: false)
            r.httpBody = j
        }
        print("starting post request...")
        let t = URLSession.shared.dataTask(with: r) { data, response, error in
            DispatchQueue.main.async {
                print("got back from post")
                if let c = completion {
                    var j: JSON? = nil
                    if let d = data {
                        j = JSON(data: d)
                    }
                    c(j, error != nil)
                }
            }
        }
        t.resume()
        requests.append(t)
    }
    
    enum LoginError: Error {
        case incorrectEmail
        case incorrectPassword
        case invalidPayment
        case ambiguous
        case awaitingPackerStatus
    }
    
    static func login(_ e: String, p: String, c: @escaping ((LoginError?)->Void)) {
        keychain["user_email"] = e
        keychain["user_password"] = p
        
        let body = [
            "e": e,
            "p": p
        ]
        
        let url = URL(string: "\(C.URL.main)/scripts/User/login.php")
        var r = URLRequest(url: url!)
        r.httpMethod = "POST"
        
        let s = JSON(rawValue: body)!.rawString()!.replacingOccurrences(of: "\n", with: "")
        
        r.httpBody = s.data(using: String.Encoding.utf8)
        let t = URLSession.shared.dataTask(with: r) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    let _response = (response as! HTTPURLResponse)
                    let code = _response.statusCode
                    print(code)
                    print(_response)
                    if code == 403 {
                        c(.incorrectEmail)
                    } else if code == 401 {
                        c(.incorrectPassword)
                    } else if code == 418 {
                        c(.awaitingPackerStatus)
                    } else {
                        let j = JSON(data!)
                        print(j)
                        if j.null == nil {
                            User.current = User(dict: j)
                            c(nil)
                        } else {
                            c(.ambiguous)
                        }
                    }
                } else {
                    print(error!.localizedDescription)
                    c(.ambiguous)
                }
            }
        }
        t.resume()
        requests.append(t)
    }
    
    static func register(email: String, password: String, fname: String, lname: String, cc: String, cvv: String, exp: String, address: String, houseNumber: String, location: Location, premium: Bool, c: @escaping ((LoginError?)->Void)) {
        let _b : [String:Any] = [
            "password": password,
            "email": email,
            "fname": fname,
            "lname": lname,
            "cc": cc,
            "cvv": cvv,
            "exp": exp,
            "address": address,
            "houseno": houseNumber,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "premium": premium
        ]
        keychain["user_email"] = email
        keychain["user_password"] = password
        
        let url = URL(string: "\(C.URL.main)/scripts/User/signup.php")
        var r = URLRequest(url: url!)
        r.httpMethod = "POST"
        
        let s = JSON(rawValue: _b)!.rawString()!.replacingOccurrences(of: "\n", with: "")
        print(s)
        r.httpBody = s.data(using: String.Encoding.utf8)
        
        let t = URLSession.shared.dataTask(with: r) { data, response, error in
            DispatchQueue.main.async {
                let _response = (response as! HTTPURLResponse)
                if _response.statusCode == 403 {
                    c(.incorrectEmail)
                } else if _response.statusCode == 402 {
                    c(.invalidPayment)
                } else if error == nil && data != nil {
                    c(nil)
                } else {
                    c(.ambiguous)
                }
            }
        }
        t.resume()
        self.requests.append(t)
    }
    
    static func checkConnection(c: @escaping ((Bool)->Void)) {
        print("checking connection")
        R.get("/scripts/connection.php", parameters: [:]) { json, error in
            print("response: \(json, error)")
            guard !error, let j = json else {
                c(false)
                return
            }
            
            c(j["status"].stringValue == "online")
        }
    }
    
    static var itemImages: [Int:UIImage] = [:]
    static var itemImageDownloads = [Int]()
}

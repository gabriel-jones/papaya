//
//  Request+Image.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

extension R {
    static func loadImageAsync(img url: URL, itemId: Int, c: @escaping (UIImage?)->(Void)) {
        guard !itemImageDownloads.contains(itemId) else {
            c(nil)
            return
        }
        
        itemImageDownloads.append(itemId)
        
        loadImg(img: url) { i in
            itemImageDownloads.remove(at: itemImageDownloads.index(of: itemId)!)
            c(i)
        }
    }
    
    static func loadImg(img url: URL, c: @escaping (UIImage?)->(Void)) {
        var download = URLRequest(url: url)
        addAuthorization(request: &download)
        URLSession.shared.dataTask(with: download) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    c(nil)
                    return
                }
                
                if let d = data, let img = UIImage(data: d) {
                    c(img)
                } else {
                    c(nil)
                }
            }
        }.resume()
    }
    
    class Image {
        private static func generateBoundaryString() -> String {
            return "Boundary-\(NSUUID().uuidString)"
        }
        
        private static func createBodyWithParameters(parameters: JSON?, filePathKey: String?, imageDataKey: Data, boundary: String) -> NSMutableData {
            let body = NSMutableData()
            if let p = parameters {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"JSON\"\r\n\r\n")
                body.appendString("\(p.rawString()!)\r\n")
            }
            let filename = "img.png"
            let mimetype = "image/png"
            
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageDataKey)
            body.appendString("\r\n")
            body.appendString("--\(boundary)--\r\n")
            return body
        }
        
        static func uploadImage(_ urlString: String, parameters: JSON, image: UIImage, completion: ((JSON?, Bool) -> ())? = nil) {
            var request = URLRequest(url: URL(string: C.URL.main + urlString)!)
            request.httpMethod = "POST"
            R.addAuthorization(request: &request)
            
            let boundary = self.generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let imgData = UIImagePNGRepresentation(image)
            let bodyData = createBodyWithParameters(parameters: parameters, filePathKey: "file", imageDataKey: imgData!, boundary: boundary)
            request.httpBody = bodyData as Data
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let c = completion {
                        var j: JSON? = nil
                        if let d = data {
                            j = JSON(data: d)
                        }
                        c(j, error != nil)
                    }
                }
                }.resume()
        }
    }
}

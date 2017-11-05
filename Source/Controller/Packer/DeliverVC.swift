//
//  DeliverVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 14/08/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps
import AVFoundation

class DeliverOrder: PPObj {
    var location: Location
    var address = ""
    
    init(dict: JSON) {
        let coords = dict["location"].stringValue.components(separatedBy: ";")
        self.location = Location(lat: Double(coords[0])!, long: Double(coords[1])!)
        super.init(id: dict["order_id"].intValue)
    }
}

class DeliverVC: UIViewController {
    
    //MARK: - Properties
    
    var order_ids: [Int]! = [13, 7, 12] //TODO: remove
    var orders = [DeliverOrder]()
    var shop_location: Location!
    
    var locationManager = CLLocationManager()
    
    var deliveryPath = GMSPath()
    var deliveryRoute = GMSPolyline()
    
    var currentPath = GMSPath()
    var currentRoute = GMSPolyline()
    
    var markers = [GMSMarker]()
    
    var currentDelivery = 0
    
    var greyIcon: UIImageView!
    var redIcon: UIImageView!
    
    let synth = AVSpeechSynthesizer()
    var utt = AVSpeechUtterance()
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    //MARK: - Actions
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View Methods
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        greyIcon = UIImageView(image: #imageLiteral(resourceName: "Marker Grey Filled"))
        greyIcon.contentMode = .scaleAspectFit
        greyIcon.frame.size = CGSize(width: greyIcon.image!.size.width/4, height: greyIcon.image!.size.height/4)
        
        redIcon = UIImageView(image: #imageLiteral(resourceName: "Marker Red Filled"))
        redIcon.contentMode = .scaleAspectFit
        redIcon.frame.size = CGSize(width: redIcon.image!.size.width/3, height: redIcon.image!.size.height/3)
        
        self.fetchData {
            
        }
    }
    
    //MARK: - Methods
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func fetchData(_ completion: (() -> ())? = nil) {
        R.post("/scripts/Packer/driver_get_order_details.php", parameters: ["orders": self.order_ids]) { json, error in
            guard !error, let j = json else {
                return
            }
            
            self.orders = []
            for order in j["orders"].arrayValue {
                self.orders.append(DeliverOrder(dict: order))
            }
            
            let coords = j["shop_location"].stringValue.components(separatedBy: ";")
            self.shop_location = Location(lat: Double(coords[0])!, long: Double(coords[1])!)
            
            let waypoints = self.orders.map {$0.location}
            self.getRoute(self.shop_location, waypoints, self.shop_location) { json in
                guard let j = json else {
                    return
                }
                let pathStr = j["overview_polyline"]["points"].string
                let waypointOrder = j["waypoint_order"].array
                
                
                
                guard let str = pathStr, let wo = waypointOrder, !wo.isEmpty  else {
                    return
                }
                
                let wayOrder = wo.map { $0.intValue }
                
                for (index, o) in wayOrder.enumerated() {
                    self.orders[o].address = j["legs"][index]["end_address"].stringValue
                }
                
                //Draw overview track
                self.deliveryPath = GMSPath(fromEncodedPath: str)!
                self.deliveryRoute.path = self.deliveryPath
                self.deliveryRoute.strokeColor = Color.red
                self.deliveryRoute.strokeWidth = 2.0
                self.deliveryRoute.map = self.mapView
                
                //Set all markers for points
                self.markers = []
                for location in self.orders.map({$0.location}) {
                    let marker = GMSMarker(position: location)
                    marker.iconView = self.greyIcon
                    marker.map = self.mapView
                    self.markers.append(marker)
                }
                
                //Update bounds
                var bounds = GMSCoordinateBounds()
                for index in 1...self.deliveryPath.count() {
                    bounds = bounds.includingCoordinate(self.deliveryPath.coordinate(at: index))
                }
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds))
                
                //Get first dropoff location
                self.currentDelivery = wayOrder.first!
                
                let _ = self.orders[self.currentDelivery]
                let marker = self.markers[self.currentDelivery]
                marker.iconView = self.redIcon
                
            }
        }
    }
    
    func speak(_ string: String) {
        self.utt = AVSpeechUtterance(string: string)
        self.utt.rate = 0.3
        self.synth.speak(self.utt)
    }
    
    func getRoute(_ start: Location, _ through: [Location], _ end: Location, _ completion: @escaping (JSON?) -> ()) {
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)&mode=driving&waypoints=optimize:true%7C\((orders.map { "\($0.location.latitude)" + "," + "\($0.location.longitude)" }).joined(separator: "%7C"))")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print(error!.localizedDescription)
                    completion(nil)
                    return
                }
                
                let json = JSON(data: data!)
                completion(json["routes"][0])
            }
        }.resume()
    }
    
    func geocode(_ location: Location, _ completion: @escaping (JSON?) -> ()) {
        let url = URL(string: "http://maps.googleapis.com/maps/api/geocode/json?latlng=\(String(location.latitude) + "," + String(location.longitude))")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print(error!.localizedDescription)
                    completion(nil)
                    return
                }
                
                let json = JSON(data: data!)
                completion(json["results"])
            }
        }.resume()
    }
    
}

extension DeliverVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

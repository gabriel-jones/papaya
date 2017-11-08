//
//  ChooseShopViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 12/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import GoogleMaps

class ChooseShopViewController: UIViewController, UIGestureRecognizerDelegate, GMSMapViewDelegate, MapDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var orderInProgressButton: UIButton!
    
    //MARK: - Properties
    
    //MARK: - View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //orderInProgressButton.gradientBackground()
        
        if Order.current.id != -1 {
            self.showStatus()
        }
        
        self.mapView.camera = GMSCameraPosition.camera(withLatitude: 32.309657, longitude: -64.750270, zoom: 12.0)
        self.mapView.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        for s in Shop.all {
            let marker = GMSMarker()
            marker.position = s.location
            marker.map = mapView
            marker.userData = s.id
            
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 65))
            let img = UIImageView(image: #imageLiteral(resourceName: "Marker Red Filled"))
            img.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            img.center.x = v.center.x
            
            img.clipsToBounds = false
            img.layer.shadowColor = UIColor.black.cgColor
            img.layer.shadowOpacity = 0.3
            img.layer.shadowOffset = CGSize.zero
            img.layer.shadowRadius = 2
            v.addSubview(img)
            
            let label = UILabel(frame: CGRect(x: 0, y: 35, width: 100, height: 30))
            label.text = s.name
            label.font = UIFont(name: "GothamRounded-Medium", size: 12.0)
            label.textColor = Color.red
            label.textAlignment = .center
            label.numberOfLines = 2
            label.layer.shadowOffset = CGSize.zero
            label.layer.shadowOpacity = 0.3
            label.layer.shadowRadius = 1
            v.addSubview(label)
            UIGraphicsBeginImageContextWithOptions(v.bounds.size, false, UIScreen.main.scale)
            v.layer.render(in: UIGraphicsGetCurrentContext()!)
            let icon = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            marker.title = s.name
            marker.icon = icon
            marker.groundAnchor = CGPoint(x: 0.5, y: 35/60)
        }
        
        mapView.animate(with: GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude:32.385084, longitude: -64.914562), coordinate: CLLocationCoordinate2D(latitude: 32.262155, longitude: -64.616677))))
        
    }
    
    func imageFrom(v: UIView) -> UIImage {
        v.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    var tappedMarker = GMSMarker()
    var infoWindow = Bundle.main.loadNibNamed("ShopInfoView", owner: self, options: nil)![0] as! ShopInfoView
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        infoWindow.removeFromSuperview()
        tappedMarker = marker

        infoWindow = Bundle.main.loadNibNamed("ShopInfoView", owner: self, options: nil)![0] as! ShopInfoView
        let shop = Shop.from(id: marker.userData as! Int)!
        infoWindow.name.text = shop.name
        infoWindow.hours.text = shop.address
        
        var img: UIImage!
        switch shop.id {
        case 5:
            img = #imageLiteral(resourceName: "Miles Market")
        case 2:
            img = #imageLiteral(resourceName: "Supermart")
        case 3:
            img = #imageLiteral(resourceName: "Arnold's")
        case 4:
            img = #imageLiteral(resourceName: "A1")
        default:
            img = #imageLiteral(resourceName: "Picture Grey")
        }
        infoWindow.image.image = img
        
        infoWindow.clipsToBounds = true
        infoWindow.center = mapView.projection.point(for: marker.position)
        infoWindow.center.y -= 35
        infoWindow.delegate = self
        self.view.addSubview(infoWindow)
        
        mapView.animate(to: GMSCameraPosition.camera(withTarget: marker.position, zoom: 14.0))
        mapView.selectedMarker = marker
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if tappedMarker.userData != nil {
            infoWindow.center = mapView.projection.point(for: tappedMarker.position)
            infoWindow.center.y -= 35
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !UserDefaults.standard.bool(forKey: "tutorial-chooseshop") {
            UserDefaults.standard.set(true, forKey: "tutorial-chooseshop")
            UserDefaults.standard.synchronize()
        }
        
        if orderInProgress {
            self.showStatus()
        }
        
        activityIndicator.activityIndicatorViewStyle = .white
        activityIndicator.startAnimating()
        /*
        if Order.current.id != -1 {
            orderInProgressButton.isHidden = false
            
        } else {
            orderInProgressButton.isHidden = true
        }*/
        
        if keychain["user_email"] == nil && keychain["user_password"] == nil {
            print("Logging out...")
            self.dismiss(animated: false, completion: nil)
        }
        
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        
    }
    
    @IBAction func orderInProgressClick(_ sender: Any) {
        showStatus()
    }
    
    //MARK: - Transitions
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func showStatus() {
        print("show status")
        self.tappedMarker = GMSMarker()
        self.infoWindow.removeFromSuperview()
        self.mapView.selectedMarker = nil
        
        print("show vc")
        let vc = StatusVC.instantiate(from: .status)
        print("animate")
        self.present(vc, animated: !orderInProgress, completion: nil)
    }
    
    //MARK: - Map Methods
    
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
        activityIndicator.startAnimating()
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        activityIndicator.stopAnimating()
    }
    
    func next() {
        let id = tappedMarker.userData as! Int
        
        if Order.current.id != -1 {
            return
        }
        
        GroceryList.current = GroceryList(items: [], shop_id: id, created: Date())
        GroceryList.current.delivery.location = User.current.defaultLocation
        GroceryList.current.delivery.address = User.current.defaultAddress
        
        let vc = GroceryContainerVC.instantiate(from: .order)
        self.navigationController?.pushViewController(vc, animated: true)
        
        self.tappedMarker = GMSMarker()
        self.infoWindow.removeFromSuperview()
        self.mapView.selectedMarker = nil
    }
}

protocol MapDelegate {
    func next()
}

class ShopInfoView: UIView {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var meinButton: LargeButton!
    var delegate: MapDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if Order.current.id != -1 {
            self.meinButton.backgroundColor = Color.red
            self.buttonLabel.text = "Order in Progress"
            self.meinButton.isEnabled = false
            self.meinButton.alpha = 0.8
        }
        meinButton.action = delegate.next
    }
    
    var isOpened = false
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.blurView.frame.origin.y = self.isOpened ? 99.5 : 44.0
            self.meinButton.alpha = self.isOpened ? 0.0 : 1.0
            
        }, completion: nil)
        isOpened = !isOpened
    }
}

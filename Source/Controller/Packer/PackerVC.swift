//
//  PackerVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 31/07/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps
import SCLAlertView

class PackerOrder: PPObj {
    var itemCount = 0
    var packerName: String?
    
    init(json: JSON) {
        itemCount = json["count"].intValue
        packerName = json["packer_name"].string
        super.init(id: json["id"].intValue)
    }
}

class PackerVC: UIViewController {
    
    @IBOutlet weak var onlineButton: LargeButton!
    @IBOutlet weak var onlineButtonLabel: UILabel!
    
    @IBAction func settings(_ sender: Any) {
        let vc = UIStoryboard(name: "settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsNavVC") as! UINavigationController
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    var online = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var orders: [PackerOrder] = []
    
    override func viewWillAppear(_ animated: Bool) {
        if User.current == nil {
            self.navigationController?.dismiss(animated: false, completion: nil)
        }
        
        self.loadingIndicator.draw()
        
        self.loading(is: true)
        R.get("/scripts/Packer/get_status.php") { json, error in
            guard let j = json, !error else {
                self.loading(is: false)
                return
            }
            
            if let _t = j["current_orders"].string, let t = Int(_t) {
                self.progressNext(with: t)
            }
            
            self.online = j["online"].boolValue
            self.updateUI()
            self.refreshData() {
                self.loading(is: false)
            }
        }
        
    }
    
    var refreshControl: UIRefreshControl!
    
    @objc func refresh(_ sender: Any) {
        refreshData {
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshData(c: @escaping () -> () = {}) {
        self.loading(is: true)
        R.get("/scripts/Packer/get_all_orders.php", parameters: [:]) { json, error in
            self.loading(is: false)
            self.collectionView.alpha = self.online ? 1 : 0
            guard !error, let j = json else {
                print("error")
                return
            }
            
            self.orders = []
            for order in j.arrayValue {
                self.orders.append(PackerOrder(json: order))
            }
            self.collectionView.reloadData()
            c()
        }
    }
    
    func updateUI() {
        self.collectionView.reloadData()
        self.onlineContainer.isUserInteractionEnabled = !online
        self.collectionView.isUserInteractionEnabled = online
        self.collectionView.alpha = online ? 1 : 0
        self.onlineContainer.alpha = online ? 0 : 1
        self.onlineButton.alpha = online ? 0 : 1
        self.powerButton.alpha = online ? 1 : 0
    }
    
    func go(online: Bool, _ completion: ((JSON?, Bool)->())? = nil) {
        self.loading(is: true)
        R.get("/scripts/Packer/set_status.php", parameters: ["online": online]) { json, error in
            self.loading(is: false)
            self.online = online
            self.updateUI()
            completion?(json, error)
        }
    }
    
    func loading(`is`: Bool) {
        for v in view.subviews {
            v.alpha = `is` ? (v.tag != 1 ? 0 : 1) : (v.tag != 2 ? 1 : 0)
        }
        self.loadingVIew.alpha = `is` ? 1 : 0
        self.view.isUserInteractionEnabled = !`is`
        if `is` { self.loadingIndicator.startAnimating() }
        else { self.loadingIndicator.stopAnimating() }
    }
    
    @IBOutlet weak var loadingIndicator: ActivityIndicator!
    @IBOutlet weak var loadingVIew: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        collectionView.refreshControl = refreshControl
        //collectionView.addSubview(refreshControl)
        
        onlineButton.action = {
            self.go(online: true) { json, error in
                guard let _ = json, !error else {
                    return
                }
                
                self.online = true
                self.refreshData()
            }
        }
        
        powerButton.action = {
            let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            a.addButton("Go Offline", backgroundColor: Color.red, textColor: UIColor.white) {
                self.go(online: false) { json, error in
                    guard let _ = json, !error else {
                        return
                    }
                    self.online = false
                    self.refreshData()
                }
            }
            a.addButton("Cancel") {}
            a.showNotice("Go Offline?", subTitle: "You will not be able to pack orders offline.")
        }
        
        startDeliveryButton.action = {
            let x = self.loadedOrders.map { $0.id }
            self.loading(is: true)
            R.post("/scripts/Packer/driver_load_items.php", parameters: ["orders": x]) { json, error in
                self.loading(is: false)
                guard !error, let j = json, j["success"].boolValue else {
                    return
                }
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeliverVC") as! DeliverVC
                vc.order_ids = x
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBOutlet weak var onlineContainer: UIView!
    @IBOutlet weak var powerButton: LargeButton!
    
    func progress(with: PackerOrder) {
        progressNext(with: with.id)
    }
    
    func progressNext(with: Int) {
        R.get("/scripts/Packer/start_packing.php", parameters: ["order_id": with]) { json, error in
            guard !error, let _ = json else {
                return
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PackOrderVC") as! PackOrderVC
            vc.order_id = with
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    var loadedOrders = [PackerOrder]()
    
    @IBOutlet weak var startDeliveryButton: LargeButton!
    @IBOutlet weak var loadCountLabel: UILabel!
    @IBOutlet weak var startDeliveryButtonBottom: NSLayoutConstraint!
    
    func updateLoadCount() {
        UIView.animate(withDuration: 0.3) {
            self.startDeliveryButtonBottom.constant = self.loadedOrders.isEmpty ? -58 : 0
            self.view.layoutIfNeeded()
        }
        self.loadCountLabel.text = "\(loadedOrders.count) Orders Loaded"
    }
    
}

extension PackerVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.alpha = self.online ? 1 : 0
        return orders.isEmpty && online ? 1 : orders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if orders.isEmpty {
            let c = collectionView.dequeueReusableCell(withReuseIdentifier: "nothingCell", for: indexPath)
            return c
        }
        let data = orders[indexPath.row]
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PackerOrderCell
        c.topTitle.text = "Order #\(User.current.packer_shop_id!)-\(data.id)"
        c.subtitleOne.text = "Items: \(data.itemCount)"
        c.startButton.action = {
            if let pt = User.current.packerType, pt == .driver {
                var didLoad = false
                if self.loadedOrders.contains(where: { data.id == $0.id }) {
                    self.loadedOrders.remove(at: self.loadedOrders.index { data.id == $0.id }!)
                    didLoad = false
                } else {
                    self.loadedOrders.append(data)
                    didLoad = true
                }
                c.startButtonLabel.text = didLoad ? "✓ Loaded" : "Load"
                c.startButton.backgroundColor = didLoad ? Color.green : Color.grey.0
                self.updateLoadCount()
            } else {
                let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                a.addButton("Pack", backgroundColor: Color.green, textColor: UIColor.white) {
                    self.progress(with: data)
                }
                a.addButton("Cancel") {}
                a.showNotice("Start Packing?", subTitle: "Do you want to start packing this order? (#\(User.current.packer_shop_id!)-\(data.id))")
            }
        }
        
        if let pt = User.current.packerType, pt == .driver {
            c.startButton.backgroundColor = Color.grey.0
            c.startButtonLabel.text = "Load"
            c.subtitleTwo.text = "Packed by " + (data.packerName ?? "Unknown")
        }
        
        c.layer.masksToBounds = true
        c.layer.cornerRadius = 10.0
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
}

class PackerOrderCell: UICollectionViewCell {
    
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var topTitle: UILabel!
    
    @IBOutlet weak var subtitleOne: UILabel!
    @IBOutlet weak var subtitleTwo: UILabel!
    
    @IBOutlet weak var startButton: LargeButton!
    @IBOutlet weak var startButtonLabel: UILabel!
}

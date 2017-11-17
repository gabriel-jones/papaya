//
//  StatusViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 14/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import MessageUI

class OrderItem: PPObj {
    enum Status: Int {
        case unpacked = 0, packed = 1, anomaly = -1
    }
    
    var name: String
    var quantity: Int
    var status: Status
    var numberPacked: Int?
    
    init(dict: JSON) {
        self.name = dict["name"].stringValue
        self.quantity = dict["quantity"].intValue
        self.status = Status(rawValue: dict["status"].intValue)!
        if self.status == .anomaly {
            self.numberPacked = Int(dict["anomaly"].doubleValue)
        }
        super.init(id: dict["id"].intValue)
    }
}

/*

class Order {
    static var current = Order()
    
    enum Status: String {
        case sent, packing, packed, delivery, ready, cancelled
    }
    var id = -1
    var status: Status = .sent
    var items = [OrderItem]()
    var total = 0.0
    
    var cartCost = 0.0
    var deliveryFee = 0.0
    var packingFee = 0.0
    var orderTotal = 0.0
    
    var deliveryStart = Location()
    var deliveryDriver: Location?
    var deliveryEnd = Location()
    
    func fetch(_ c: @escaping (Bool)->()) {
        if self.id == -1 { return }
        R.get("/scripts/Orders/current_order_status.php", parameters: ["order_id": "\(self.id)"]) { j, error in
            guard !error, let json = j, json["error"].string == nil else {
                c(true)
                return
            }
            
            self.items.removeAll()
            
            let s = json["status"].stringValue
            self.status = Order.Status(rawValue: s)!
            for item in json["items"].arrayValue {
                self.items.append(OrderItem(dict: item))
            }
            
            self.total = json["subtotal"].doubleValue
            
            if self.status != .ready {
                var coords = json["delivery"]["start"].stringValue.components(separatedBy: ";")
                self.deliveryStart = Location(lat: Double(coords[0])!, long: Double(coords[1])!)
                if let driverLocation = json["delivery"]["driver"].string {
                    coords = driverLocation.components(separatedBy: ";")
                    if coords.count == 2 {
                        if let lat = Double(coords[0]), let long = Double(coords[1]) {
                            self.deliveryDriver = Location(lat: lat, long: long)
                        }
                    }
                }
                
                coords = json["delivery"]["end"].stringValue.components(separatedBy: ";")
                self.deliveryEnd = Location(lat: Double(coords[0])!, long: Double(coords[1])!)
            } else {
                self.cartCost = json["subtotal"].doubleValue
                self.packingFee = json["packing_fee"].doubleValue
                self.deliveryFee = json["delivery_fee"].doubleValue
                self.orderTotal = json["total"].doubleValue
            }
            
            c(false)
        }
    }
}

class StatusViewController: UIViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate, StatusDelegate, GMSMapViewDelegate {
    
    //MARK: - Properties
    
    var isShowingDetail = false
    var packingProgress: Float = 0.0
    var deliveryProgress: Float = 0.0
    var anomaliesPresent = false
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var errorButton: LargeButton!
    
    @IBOutlet weak var generalStatusView: UIView!
    @IBOutlet weak var generalStatusImage: UIImageView!
    @IBOutlet weak var generalStatusMessage: UILabel!
    
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var orderProgressView: UIView!
    @IBOutlet weak var sentCircle: UIView!
    @IBOutlet weak var packedCircle: UIView!
    @IBOutlet weak var deliveredCircle: UIView!
    @IBOutlet weak var packingLine: UIView!
    @IBOutlet weak var deliveryLine: UIView!
    @IBOutlet weak var packingTrackWidth: NSLayoutConstraint!
    @IBOutlet weak var deliveryTrackWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var deliveryImage: UIImageView!
    @IBOutlet weak var deliveryImageProgressConstraint: NSLayoutConstraint!
    
    
    var deliveryMap: GMSMapView!
    
    @IBOutlet weak var detailButton: LargeButton!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var submessageView: UIView!
    @IBOutlet weak var submessageImage: UIImageView!
    @IBOutlet weak var submessageLabel: UILabel!
    
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var callStore: LargeButton!
    @IBOutlet weak var contactUs: LargeButton!
    @IBOutlet weak var orderSummary: LargeButton!
    @IBOutlet weak var orderSummarySubview: LargeButton!
    
    @IBOutlet weak var orderLargeProgressView: UIView!
    @IBOutlet weak var orderLargeProgressLabel: UILabel!
    @IBOutlet weak var orderLargeProgressTrack: UIView!
    @IBOutlet weak var orderLargeProgressProgress: LargeButton!
    @IBOutlet weak var orderLargeProgressProgressWidth: NSLayoutConstraint!
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var tabIndicator: UIView!
    @IBOutlet weak var tabListButton: LargeButton!
    @IBOutlet weak var tabListLabel: UILabel!
    @IBOutlet weak var tabCartButton: LargeButton!
    @IBOutlet weak var tabCartLabel: UILabel!
    
    @IBOutlet weak var overviewButton: LargeButton!
    
    //MARK: - View Methods
    
    override func viewWillAppear(_ animated: Bool) {
        self.load()
    }
    
    func load() {
        for v in self.view.subviews {
            v.isHidden = v.tag != 1
        }
        
        let a = ActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        a.colorType = .Grey
        a.center = self.view.center
        a.draw()
        a.startAnimating()
        self.view.addSubview(a)
        let x = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 25))
        x.center = a.center
        x.center.y += 40
        x.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        x.textColor = UIColorFromRGB(0x949494)
        x.textAlignment = .center
        x.text = "LOADING"
        self.view.addSubview(x)
        
        Order.current.fetch { err in
            a.removeFromSuperview()
            x.removeFromSuperview()
            print("fetched stuff")
            if err {
                print("connection error TODO1")
                return
            }
            
            self.updateMap()
            self.updateMapRoute { _err in
                DispatchQueue.main.async {
                    print("Got map route")
                    if _err {
                        print("connection error TODO2")
                    }
                    
                    self.updateStatus()
                    self.setupPageViewControllers()
                    
                    self.anomaliesPresent = !Order.current.items.filter{$0.status == .anomaly}.isEmpty
                    self.updateAnomalyWarning()
                    
                    
                    self.view.subviews.forEach { $0.isHidden = false; }
                }
            }
        }
    }
    
    func updateStatus() {
        switch Order.current.status {
        case .sent:
            self.setPackingProgress(to: 0)
            self.setDeliveryProgress(to: 0)
            self.detailButton.alpha = 0.0
            self.submessageView.alpha = 1.0
            self.generalStatusImage.image = #imageLiteral(resourceName: "Paper Airplane")
            self.generalStatusMessage.text = "Your order has been sent to the store."
        case .packing:
            self.calculatePackingProgress()
            self.setDeliveryProgress(to: 0)
            self.setPackingProgress(to: self.packingProgress)
            self.detailButton.alpha = 1.0
            self.submessageView.alpha = 0.0
            self.generalStatusMessage.text = "Your order is being packed."
        case .packed:
            self.setDeliveryProgress(to: 0)
            self.setPackingProgress(to: 1.0)
            self.detailButton.alpha = 1.0
            self.submessageView.alpha = 0.0
            self.isPacked = true
            self.generalStatusMessage.text = "Your order has been packed, and is awaiting delivery."
        case .delivery:
            self.calculateDeliveryProgress()
            self.setPackingProgress(to: 1.0)
            self.isPacked = true
            self.setDeliveryProgress(to: self.deliveryProgress)
            self.detailButton.alpha = 1.0
            self.submessageView.alpha = 0.0
            self.generalStatusMessage.text = "Your order is being delivered."
        case .ready:
            self.setPackingProgress(to: 1.0)
            self.isPacked = true
            self.setDeliveryProgress(to: 1.0)
            self.isDelivered = true
            self.detailButton.alpha = 0.0
            self.submessageView.alpha = 0.0
            
            self.totalView.alpha = 1.0
            self.finishButton.alpha = 1.0
            self.generalStatusImage.image = #imageLiteral(resourceName: "Tick Green Filled")
            self.generalStatusMessage.text = "Your order has been completed."
            self.updateTotals()
            self.orderProgressView.alpha = 0.0
        default: break
        }
    }
    
    func updateTotals() {
        cartSubtotal.text = Order.current.cartCost.currency_format
        packingFee.text = Order.current.packingFee.currency_format
        deliveryFee.text = Order.current.deliveryFee.currency_format
        orderTotal.text = Order.current.orderTotal.currency_format
    }
    
    func calculatePackingProgress() {
        self.packingProgress = Float(Order.current.items.filter {$0.status == .packed || $0.status == .anomaly}.count) / Float(Order.current.items.count)
    }
    
    func calculateDeliveryProgress() {
        let trackLength = deliveryPath.length(of: .geodesic)
        let remainingDriverLength = driverPath.length(of: .geodesic)
        print(trackLength, remainingDriverLength)
        if remainingDriverLength == 0 {
            self.deliveryProgress = 0
            return
        }
        self.deliveryProgress = max(Float((trackLength - remainingDriverLength) / trackLength), 0)
    }
    
    var deliveryPath = GMSPath()
    var driverPath = GMSPath()
    
    var deliveryRoute = GMSPolyline()
    var driverRoute = GMSPolyline()
    
    var shopMarker = GMSMarker()
    var driverMarker = GMSMarker()
    var deliveryMarker = GMSMarker()
    
    func setupMap() {
        self.deliveryMap = GMSMapView(frame: CGRect(x: 16, y: 390, width: self.view.frame.width-32, height: self.view.frame.height - 296))
        self.deliveryMap.alpha = 0.0
        self.deliveryMap.delegate = self
        self.view.addSubview(deliveryMap)
        
        deliveryRoute.strokeColor = UIColorFromRGB(0x949494)
        deliveryRoute.strokeWidth = 3.0
        deliveryRoute.map = self.deliveryMap
        
        driverRoute.strokeColor = Color.red
        driverRoute.strokeWidth = 3.0
        driverRoute.map = self.deliveryMap

        let img = UIImageView(image: #imageLiteral(resourceName: "Marker Grey Filled"))
        img.contentMode = .scaleAspectFit
        img.frame.size = CGSize(width: img.image!.size.width/4, height: img.image!.size.height/4)
        
        shopMarker.iconView = img
        
        let img2 = UIImageView(image: #imageLiteral(resourceName: "Delivery Green Filled"))
        img2.contentMode = .scaleAspectFit
        img2.frame.size = CGSize(width: img.image!.size.width/2, height: img.image!.size.height/4)
        
        driverMarker.iconView = img2
        
        let img3 = UIImageView(image: #imageLiteral(resourceName: "Marker Red Filled"))
        img3.contentMode = .scaleAspectFit
        img3.frame.size = CGSize(width: img.image!.size.width/2, height: img.image!.size.height/2)

        deliveryMarker.iconView = img3

        shopMarker.map = self.deliveryMap
        driverMarker.map = self.deliveryMap
        deliveryMarker.map = self.deliveryMap
    }
    
    func updateMap() {
        shopMarker.position = Order.current.deliveryStart
        if let driverPos = Order.current.deliveryDriver {
            driverMarker.position = driverPos
        } else {
            driverMarker.iconView?.alpha = 0.0
        }
        deliveryMarker.position = Order.current.deliveryEnd
    }
    
    func updateMapRoute(c: @escaping (Bool) -> ()) {
        getPolylineRoute(from: shopMarker.position, to: deliveryMarker.position) { str in
            DispatchQueue.main.async {
                guard let pathStr = str else {
                    c(true)
                    return
                }
                self.deliveryPath = GMSPath(fromEncodedPath: pathStr)!
                self.deliveryRoute.path = self.deliveryPath
                if self.driverMarker.iconView?.alpha != 0 {
                    getPolylineRoute(from: self.driverMarker.position, to: self.deliveryMarker.position) { driverStr in
                        DispatchQueue.main.async {
                            guard let driverPathStr = driverStr else {
                                return
                            }
                            self.driverPath = GMSPath(fromEncodedPath: driverPathStr)!
                            self.driverRoute.path = self.driverPath
                            
                            self.updateMapBounds()
                            c(false)
                        }
                    }
                } else {
                    c(false)
                }
            }
        }
    }
    
    func updateMapBounds() {
        var bounds = GMSCoordinateBounds()
        for index in 1...deliveryPath.count() {
            bounds = bounds.includingCoordinate(deliveryPath.coordinate(at: index))
        }
        deliveryMap.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMap()
        
        orderInProgress = false
        self.generalStatusView.layer.zPosition = -1000
        self.errorButton.layer.zPosition = 1000
        
        self.contactUs.action = {
            
        }
        
        self.callStore.action = {
            //TODO: insert telephone number
            if let url = URL(string: "tel://1-441-232-5818"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        self.orderSummarySubview.action = self.openSummary
        self.orderSummary.action = self.openSummary
        
        self.detailButton.action = self.toggleDetail
        self.overviewButton.action = self.toggleDetail
        
        self.tabListButton.action = {
            if self.switchVC(to: .list) {
                self.updateLabels()
            }
        }
        
        self.tabCartButton.action = {
            if self.switchVC(to: .cart) {
                self.updateLabels()
            }
        }
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        self.finishButton.action = {
            Order.current.id = -1
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func swipe(_ sender: UISwipeGestureRecognizer) {
        guard Order.current.status == .packing || Order.current.status == .delivery else {
            return
        }
        
        if (sender.direction == .up && !self.isShowingDetail) || (sender.direction == .down && self.isShowingDetail) {
            self.toggleDetail()
        }
    }
    
    enum Mode {
        case overview, detail
    }
    
    func show(mode: Mode) {
        guard (self.isShowingDetail && mode == .detail) || (mode == .overview && !self.isShowingDetail) else {
            return
        }
        toggleDetail()
    }
    
    func updateAnomalyWarning() {
        print("update anomalies: \(anomaliesPresent)")
        UIView.animate(withDuration: 0.3) {
            print("animate")
            self.errorButton.frame.origin.y += 150 * (self.anomaliesPresent ? -1 : 1)
        }
    }
    
    func toggleDetail() {
        self.view.isUserInteractionEnabled = false
        print("Called toggle")
        let x = self.isShowingDetail
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut, animations: {
            self.generalStatusView.alpha = x ? 1.0 : 0.0
            self.generalStatusView.frame.origin.y -= 242 * (x ? -1 : 1)
            self.detailView.alpha = x ? 1.0 : 0.0
            self.detailView.frame.origin.y = x ? 327 : 287
            self.separator.frame.origin.y = x ? 250 : 262
            self.orderProgressView.frame.origin.y += 139 * (x ? 1 : -1)
            
            self.helpView.frame.origin.y += 137 * (x ? -1 : 1)
            self.detailView.alpha = x ? 1.0 : 0.0
        }, completion: { b in
            self.view.isUserInteractionEnabled = true
            self.isShowingDetail = !self.isShowingDetail
        })
        
        UIView.animate(withDuration: 0.4, delay: x ? 0.0 : 0.3, options: .curveEaseInOut, animations: {
            self.orderLargeProgressView.frame.origin.y = x ? 260 : 212
            self.orderLargeProgressView.alpha = x ? 0 : 1
            if Order.current.status == .packing {
                self.pageViewController!.view.frame.origin.y = x ? 411 : 328
                self.pageViewController!.view.alpha = x ? 0.0 : 1.0
                self.tabView.alpha = x ? 0 : 1
                self.tabView.frame.origin.y = x ? 204 : 271
            } else {
                self.deliveryMap.alpha = x ? 0 : 1
                self.deliveryMap.frame.origin.y = x ? 390 : 280
            }
            self.overviewButton.alpha = x ? 0 : 1
            self.overviewButton.frame.origin.y = x ? 30 : 75
        }, completion: nil)
    }
    
    
    @IBAction func minimize(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func more(_ sender: Any) {
        let a = YoutubeActionController()
        
        if Order.current.status == .sent {
            a.addAction(Action(ActionData.init(title: "Delete Order", image: #imageLiteral(resourceName: "Trash Red")), style: ActionStyle.destructive) { _ in
                
                let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                a.addButton("Delete", backgroundColor: Color.red, textColor: UIColor.white) {
                    let a = UIAlertController(title: "Please enter your password to continue", message: nil, preferredStyle: .alert)
                    a.addTextField { t in
                        t.isSecureTextEntry = true
                        t.keyboardAppearance = .dark
                        t.autocorrectionType = .no
                        t.autocapitalizationType = .none
                    }
                    a.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    a.addAction(UIAlertAction(title: "OK", style: .destructive) { [weak a] (_) in
                        do {
                            let p = try keychain.get("user_password")
                            if a!.textFields![0].text! == p {
                                R.get("/scripts/Orders/delete_order.php", parameters: ["order_id": "\(Order.current.id)"]) { json, error in
                                    
                                    guard !error, let _ = json else {
                                        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                                        a.addButton("OK") {}
                                        a.showWarning("Failed", subTitle: "Cannot delete order. Please try again.")
                                        return
                                    }
                                    
                                    Order.current.id = -1
                                    orderInProgress = false
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        } catch {
                            print("Could not read from keychain. Exiting...")
                            exit(-666)
                        }
                        
                    })
                    self.present(a, animated: true, completion: nil)
                }
                a.addButton("Cancel") {}
                a.showWarning("Delete order?", subTitle: "This cannot be undone.")
                
            })
        }
        present(a, animated: true, completion: nil)
    }

    var isPacked: Bool = false {
        didSet {
            self.packedCircle.backgroundColor = isPacked ? Color.green : UIColorFromRGB(0xd4d4d4)
        }
    }
    
    var isDelivered: Bool = false {
        didSet {
            self.deliveredCircle.backgroundColor = isDelivered ? Color.green : UIColorFromRGB(0xd4d4d4)
        }
    }
    
    func setPackingProgress(to: Float) {
        print(to)
        self.orderLargeProgressProgressWidth.constant = CGFloat(to) * self.orderLargeProgressTrack.frame.width
        self.packingTrackWidth.constant = CGFloat(to) * packingLine.frame.width
        self.orderLargeProgressLabel.text = "\(Int(round(to*100)))% PACKED"
    }
    
    @IBOutlet weak var finishButton: LargeButton!
    @IBOutlet weak var totalView: UIView!
    
    @IBOutlet weak var cartSubtotal: UILabel!
    @IBOutlet weak var packingFee: UILabel!
    @IBOutlet weak var deliveryFee: UILabel!
    @IBOutlet weak var orderTotal: UILabel!
    
    func setDeliveryProgress(to: Float) {
        self.deliveryImage.isHidden = to == 0 || to == 1.0
        self.deliveryImageProgressConstraint.constant = -20.0 - CGFloat(to) * deliveryLine.frame.width
        self.deliveryTrackWidth.constant = CGFloat(to) * deliveryLine.frame.width
        self.orderLargeProgressProgressWidth.constant = CGFloat(to) * self.orderLargeProgressTrack.frame.width
        self.orderLargeProgressLabel.text = "\(Int(round(to*100)))% DELIVERED"
    }
    
    //MARK: - UIPageViewController 
    
    enum PageMode {
        case list, cart
    }
  
    var pageMode = PageMode.list
    var pageViewController: UIPageViewController?
    
    var listVC: StatusVC!
    var cartVC: StatusVC!
    
    func setupPageViewControllers() {
        let pageController = self.storyboard!.instantiateViewController(withIdentifier: "StatusPageController") as! UIPageViewController
        pageController.dataSource = self
        pageController.delegate = self
        
        cartVC = self.storyboard!.instantiateViewController(withIdentifier: "StatusDetailVC") as! StatusVC
        cartVC.mode = .cart
        cartVC.delegate = self
        listVC = self.storyboard!.instantiateViewController(withIdentifier: "StatusDetailVC") as! StatusVC
        listVC.mode = .list
        listVC.delegate = self
        
        let vcs = [listVC] as! [StatusVC]
        pageController.setViewControllers(vcs, direction: .forward, animated: false, completion: nil)
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        
        pageViewController!.view.frame = CGRect(x: 16, y: 411, width: self.view.frame.width-32, height: self.view.frame.height - 350)
        pageViewController!.view.alpha = 0.0
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    func switchVC(to: PageMode) -> Bool {
        if self.pageMode == to { return false }
        
        let vc = (to == .cart ? [cartVC] : [listVC]) as! [StatusVC]
        print("Switch to: \(vc[0].title ?? "nil")")
        self.pageViewController!.setViewControllers(vc, direction: to == .list ? .reverse : .forward, animated: true, completion: nil)
        return true
    }
    
    func updateLabels() {
        self.pageMode = self.pageMode == .cart ? .list : .cart
        let grey = UIColorFromRGB(0xAAAAAA)
        UIView.animate(withDuration: 0.3) {
            self.tabIndicator.center.x += (self.tabView.frame.width / 2) * CGFloat(self.pageMode == .list ? -1 : 1)
            self.tabCartLabel.textColor = self.pageMode == .list ? grey : Color.green
            self.tabListLabel.textColor = self.pageMode == .cart ? grey : Color.green
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if pageMode == .cart { return listVC }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if pageMode == .list { return cartVC }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.updateLabels()
        }
    }
    
    func getData(for: StatusViewController.PageMode) -> [OrderItem] {
        return Order.current.items.filter { `for` == .list ? $0.status == .unpacked : $0.status == .packed || $0.status == .anomaly }
    }
    
    func getSummaryData() -> [(String, Int)] {
        return Order.current.items.map { ($0.name, $0.quantity) }
    }
    
    func getTotal() -> Double {
        return Order.current.total
    }
    
    var v: UIView?
    
    func openSummary() {
        openOverlay()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryVC
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    func openOverlay() {
        v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        v!.backgroundColor = .black
        v!.alpha = 0.6
        self.view.addSubview(v!)
    }
    
    func closeOverlay() {
        v?.removeFromSuperview()
    }
    
}

protocol StatusDelegate {
    func getData(for: StatusViewController.PageMode) -> [OrderItem]
    func closeOverlay()
    func getTotal() -> Double
}

class StatusVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    var delegate: StatusDelegate!
    var mode: StatusViewController.PageMode!
    var data: [OrderItem] = []
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LOAD: \(mode)")
        self.collectionView.register(UINib(nibName: "LargeStatusCell", bundle: nil), forCellWithReuseIdentifier: "largeStatusCell")
        self.collectionView.register(UINib(nibName: "StatusCell", bundle: nil), forCellWithReuseIdentifier: "statusCell")
        
        self.data = delegate.getData(for: mode)
        self.emptyLabel.isHidden = !data.isEmpty
        self.collectionView.isHidden = data.isEmpty
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let x = self.data[indexPath.row]
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "largeStatusCell", for: indexPath) as! LargeStatusCell
            print(x.status)
            cell.statusView.backgroundColor = x.status == .anomaly ? Color.red : Color.green
            cell.special.text = mode == .list ? "NOW PACKING" : "LAST PACKED"
            //TODO: time value
            cell.clock.isHidden = mode == .list
            cell.time.isHidden = mode == .list
            
            cell.title.text = x.name
            cell.title.textColor = x.numberPacked != nil && x.numberPacked == 0 ? Color.red : UIColor.black
            
            cell.subtitle.text = mode == .list ? "QUANTITY: \(x.quantity)" : "\(x.numberPacked ?? x.quantity) / \(x.quantity) PACKED" + (x.status == .anomaly ? " - OUT OF STOCK" : "")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! StatusCell
            cell.statusView.backgroundColor = x.status == .anomaly ? Color.red : Color.green
            
            cell.title.text = x.name
            cell.title.textColor = x.numberPacked != nil && x.numberPacked == 0 ? Color.red : UIColor.black
            
            cell.subtitle.text = mode == .list ? "QUANTITY: \(x.quantity)" : "\(x.numberPacked ?? x.quantity) / \(x.quantity) PACKED" + (x.status == .anomaly ? " - OUT OF STOCK" : "")
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: indexPath.row == 0 ? 100 : 65)
    }
}

class LargeStatusCell: UICollectionViewCell {
    @IBOutlet weak var special: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var clock: UIImageView!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}

class StatusCell: UICollectionViewCell {
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}

class SummaryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: StatusDelegate!
    
    @IBOutlet weak var closeButton: LargeButton!
    @IBOutlet weak var total: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderInProgress = false
        self.total.text = delegate.getTotal().currency_format
        self.closeButton.action = {
            self.close()
        }
    }
    
    func close() {
        self.delegate.closeOverlay()
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Order.current.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SummaryCell
        let x = Order.current.items[indexPath.row]
        c.nameLabel.text = x.name
        c.quantityLabel.text = "\(x.quantity)"
        
        c.quantityLabel.text = x.status == .anomaly ? "\(x.numberPacked!)/\(x.quantity)" : "\(x.quantity)"
        
        c.errorImage.isHidden = x.status != .anomaly
        return c
    }
    @IBOutlet weak var contentView: UIView!
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if !self.contentView.point(inside: t.location(in: self.view), with: event) {
                self.close()
            }
        }
    }
    
}

class SummaryCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var errorImage: UIImageView!
}
*/

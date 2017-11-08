//
//  PackOrderVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 31/07/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView

class PackItem: PPObj {
    
    var name: String = ""
    var quantity: Int = 0
    var category: String = ""
    var anomalyPacked: Int?
    var status: PackStatus = .unpacked
    var price: Double = 0.0
    
    init(dict: JSON) {
        name = dict["name"].stringValue
        quantity = dict["quantity"].intValue
        category = dict["category"].stringValue
        status = PackStatus(rawValue: dict["status"].intValue)!
        if let a = dict["anomaly"].int {
            anomalyPacked = a
        }
        price = dict["price"].doubleValue
        super.init(id: dict["id"].intValue)
    }
    
    func toArray() -> [String: Any] {
        var p: [String:Any] = [
            "name": name,
            "quantity": quantity,
            "category": category,
            "status": status.rawValue,
            "price": price,
            "id": id
        ]
        if let x = anomalyPacked {
            p["anomaly"] = x
        }
        return p
    }
    
    func toJSON() -> JSON {
        return JSON(self.toArray())
    }
}

enum PackStatus: Int {
    case packed = 1, unpacked = 0, anomaly = -1
}

extension Array where Element == PackItem {
    func of(status: PackStatus) -> [PackItem] {
        return self.filter { $0.status == status }
    }
    
    func of(status: [PackStatus]) -> [PackItem] {
        return self.filter { status.contains($0.status) }
    }
}

class PackOrderVC: UIViewController {
    
    //MARK: - Properties
    var order_id = 30//TODO: default -1
    var currentItem: PackItem? = nil
    var items: [PackItem] = []
    var showFinish = false
    var loadingAlert: UIAlertController!
    
    //MARK: - Outlets
    //MARK: Current Item
    @IBOutlet weak var currentContentView: UIView!
    
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var currentQuantity: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    
    @IBOutlet weak var currentImageView: UIView!
    @IBOutlet weak var currentDetailView: UIView!
    
    @IBOutlet weak var collectNone: LargeButton!
    @IBOutlet weak var collectSome: LargeButton!
    @IBOutlet weak var collectAll: LargeButton!
    
    //MARK: All Items
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Finished View
    @IBOutlet weak var finishContentView: UIView!
    @IBOutlet weak var signatureView: DrawView!
    @IBOutlet weak var finishButton: LargeButton!
    @IBOutlet weak var signatureVertical: NSLayoutConstraint!
    @IBOutlet weak var clearVertical: NSLayoutConstraint!
    
    //MARK: General
    @IBOutlet weak var seeItemsLabel: UILabel!
    @IBOutlet weak var seeItemsButton: LargeButton!
    
    @IBOutlet weak var offline: UIView!
    
    //MARK: - Actions
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearSignature(_ sender: UIButton) {
        signatureView.clear()
    }
    
    //MARK: - Methods
    
    func loadOrderDetails(_ completion: @escaping () -> ()) {
        R.get("/scripts/Packer/get_packing_details.php", parameters: ["order_id":self.order_id]) { json, error in
            self.offline.alpha = error ? 1 : 0
            if let j = json {
                print(j)
                for item in j.arrayValue {
                    self.items.append(PackItem(dict: item))
                }
                
                self.nextItem(false)
                
                completion()
            } else {
                self.offline.alpha = 1
            }
            
        }
    }
    
    func addFailedStatus(_ item: PackItem) {
        print("Add failed status for item: \(item.name)")
        var x = [JSON]()
        if let str = UserDefaults.standard.string(forKey: "prepacked_packer_status_items") {
            let failedItemsJSON = JSON(parseJSON: str)
            x = failedItemsJSON.arrayValue
            if x.contains(where: { PackItem(dict: $0).id == item.id }) {
                return
            }
            x.append(item.toJSON())
        } else {
            x = [item.toJSON()]
        }
        print("Item Json:", JSON(x).rawString() ?? "NIL")
        if let rawStr = JSON(x).rawString() {
            UserDefaults.standard.set(rawStr, forKey: "prepacked_packer_status_items")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func removeAllFailedStatuses() {
        print("Remove all failed statuses")
        UserDefaults.standard.removeObject(forKey: "prepacked_packer_status_items")
        UserDefaults.standard.synchronize()
    }
    
    func getFailedStatuses() -> [PackItem]? {
        print("get all failed statuses")
        if let str = UserDefaults.standard.string(forKey: "prepacked_packer_status_items") {
            let failedItemsJSON = JSON(parseJSON: str)
            print(failedItemsJSON)
            var _items = [PackItem]()
            for item in failedItemsJSON.arrayValue {
                _items.append(PackItem(dict: item))
            }
            return _items
        }
        return nil
    }
    
    func updateFailedStatuses(_ completion: ((Bool)->())? = nil) {
        print("update failed statuses")
        if let failedStatuses = getFailedStatuses() {
            print("found failed statuses")
            if failedStatuses.isEmpty {
                print("statuses empty")
                if let c = completion {
                    c(false)
                }
                return
            }
            
            let group = DispatchGroup()
            for (index, item) in failedStatuses.enumerated() {
                group.enter()
                print("updating status for item: \(item.name)")
                var x = failedStatuses
                x.remove(at: index)
                UserDefaults.standard.set(x, forKey: "prepacked_packer_status_items")
                UserDefaults.standard.synchronize()
                self.updateStatus(of: item) {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                print("Finished HTTP requests")
                if let c = completion {
                    c(true)
                }
                return
            }
        } else {
            if let c = completion {
                c(false)
            }
            return
        }
    }
    
    func updateStatus(of _item: PackItem?, _ completion: (() -> ())? = nil) {
        guard let item = _item else {
            return
        }
        print("update status for: \(item.name)")
        var parameters: [String:Any] = [
            "order_id": self.order_id,
            "item_id": item.id,
            "item_status": item.status.rawValue
        ]
        if item.status == .anomaly {
            parameters["anomaly"] = item.anomalyPacked
        }
        R.get("/scripts/Packer/edit_packing.php", parameters: parameters) { json, error in
            self.offline.alpha = error ? 1 : 0
            if error {
                self.addFailedStatus(item)
                return
            }
            
            if let c = completion {
                c()
            }
        }
    }
    
    func nextItem(_ animated: Bool = true, _ completion: (() -> ())? = nil) {
        
        currentItem = items.of(status: .unpacked).first
        if currentItem == nil {
            updateAllUI()
            toggleFinished(true)
            if let c = completion { c() }
            return
        } else {
            toggleFinished(false)
        }
        
        print("animating next item")
        let x = animated ? 0.3 : 0
        UIView.animate(withDuration: x, animations: {
            self.currentImageView.frame.origin.x = -self.view.frame.width
            self.currentDetailView.frame.origin.x = -self.view.frame.width
            
        }) { _ in
            self.updateAllUI()
            self.currentImageView.frame.origin.x = self.view.frame.width
            self.currentDetailView.frame.origin.x = self.view.frame.width
            UIView.animate(withDuration: x) {
                self.currentImageView.frame.origin.x = 0
                self.currentDetailView.frame.origin.x = 0
                if let c = completion { c() }
            }
        }
    }
    
    //MARK: - View Methods
    
    var v: UIView?
    
    func addOverlay() {
        v = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        v?.backgroundColor = .black
        v?.alpha = 0.4
        view.addSubview(v!)
    }
    
    func removeOverlay() {
        v?.removeFromSuperview()
    }
    
    @objc func networkChanged(_ notification: NSNotification) {
        guard let status = Network.reachability?.status else { return }
        offline.alpha = status == .unreachable ? 1 : 0
    }
    
    func finishLoading() {
        for v in self.view.subviews {
            v.alpha = 1
        }
        stopLoading()
        collectionView.alpha = 0
        view.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        
        if UIScreen.main.bounds.height <= 640 {
            clearVertical.constant -= 30
            signatureVertical.constant -= 30
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        view.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged), name: .flagsChanged, object: Network.reachability)
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.allowsSelection = false
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        collectionView.frame = CGRect(x: 16, y: view.frame.height, width: view.frame.width-32, height: view.frame.height - 134)
        
        seeItemsButton.frame = CGRect(x: 16, y: view.frame.height - 45 - 16, width: view.frame.width - 32, height: 45)
        seeItemsLabel.frame = CGRect(x: 8, y: 8, width: seeItemsButton.frame.width - 16, height: seeItemsButton.frame.height - 16)
        
        for v in view.subviews {
            v.alpha = v.tag != 1 ? 0 : 1
        }
        
        loadOrderDetails {
            self.updateFailedStatuses { s in
                self.finishLoading()
            }
        }
        
        //MARK: LargeButton actions
        seeItemsButton.action = toggleItemView
        
        currentContentView.layer.zPosition = -1
        finishContentView.layer.zPosition = -1

        
        collectAll.action = {
            self.currentItem?.status = .packed
            self.currentItem?.anomalyPacked = nil
            self.updateStatus(of: self.currentItem)
            self.nextItem()
        }
        
        collectSome.action = {
            self.addOverlay()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AnomalyVC") as! AnomalyVC
            vc.delegate = self
            vc.item = self.currentItem
            vc.order_id = self.order_id
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
        
        collectNone.action = {
            self.currentItem?.status = .anomaly
            self.currentItem?.anomalyPacked = 0
            self.updateStatus(of: self.currentItem)
            self.nextItem()
        }
        
        finishButton.action = finishOrder
        
        //MARK: CollectionView Swipe
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        collectionView.addGestureRecognizer(tapGesture)
        
        let _tap = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        currentImage.isUserInteractionEnabled = true
        currentImage.addGestureRecognizer(_tap)
    }
    
    @objc func imageTap() {
        if let item = self.currentItem {
            let vc = ImageDetailVC.instantiate(from: .order)
            vc.image = self.currentImage.image
            vc.delegate = self
            vc.id = item.id
            vc.modalPresentationStyle = .overCurrentContext
            self.addOverlay()
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func finishOrder() {
        addOverlay()
        view.isUserInteractionEnabled = false
        startLoading()
        
        guard signatureView.hasContent else {
            return
        }
        
        signatureView.save()
        
        let img = self.signatureView.signature
        R.finishOrder(id: order_id, image: img, items: items) { json, error in
            self.removeOverlay()
            self.stopLoading()
            self.view.isUserInteractionEnabled = true
            let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            guard let j = json, !error, j["success"].boolValue else {
                a.addButton("OK") {}
                a.showWarning("Could not complete order", subTitle: "Check your internet connection and try again.")
                return
            }
            a.addButton("OK") {
                self.navigationController?.popViewController(animated: true)
            }
            a.showSuccess("Nice job!", subTitle: "The order has been completed.")
        }
    }
    
    @objc func tapCell(_ sender: UITapGestureRecognizer) {
        let ip = collectionView.indexPathForItem(at: sender.location(in: collectionView))
        guard let indexPath = ip, let cell = collectionView.cellForItem(at: indexPath) as? PackingListCell else {
            return
        }
        let _items = indexPath.section == 1 ? items.of(status: [.packed, .anomaly]) : items.of(status: .unpacked)
        if _items[indexPath.row].status != .unpacked {
            cell.toggleDetail()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func startLoading() {
        loadingAlert = UIAlertController(title: "Loading...", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: loadingAlert.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        loadingAlert.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        present(loadingAlert, animated: true, completion: nil)
    }
    
    func stopLoading() {
        loadingAlert.dismiss(animated: true, completion: nil)
    }
    
    var isViewingCurrentItem = true
    func toggleItemView() {
        print(" -- Toggle Item View (\(isViewingCurrentItem)) -- ")
        self.view.isUserInteractionEnabled = false
        let t = isViewingCurrentItem
        self.isViewingCurrentItem = !self.isViewingCurrentItem
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut, animations: {
            self.currentContentView.alpha = t ? 0 : 1
            self.currentContentView.frame.origin.y = t ? -(self.currentContentView.frame.height + self.currentContentView.frame.origin.y) : 73
            
            self.finishContentView.alpha = t ? 0 : 1
            self.finishContentView.frame.origin.y = t ? -(self.finishContentView.frame.height + self.finishContentView.frame.origin.y) : 73
            
            self.seeItemsButton.frame.origin.y = t ? 73 : (self.currentContentView.frame.height + self.currentContentView.frame.origin.y) + 16
            
            self.collectionView.alpha = t ? 1 : 0
            self.collectionView.frame.origin.y = t ? 134 : self.view.frame.height
            self.updateDetailLabel()
        }) { _ in
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func updateDetailLabel() {
        self.seeItemsLabel.text = !isViewingCurrentItem ? "SEE \(self.showFinish ? "ORDER COMPLETION" : "CURRENTLY PACKING")" : "SEE ALL ITEMS"
    }
    
    @IBOutlet weak var currentContentViewLeading: NSLayoutConstraint!
    func toggleFinished(_ show: Bool? = nil, animated: Bool = true) {
        print(" -- Toggle Finished View (\(String(describing: show))) ; (\(showFinish)) -- ")
        var t = showFinish
        if let s = show {
            if s == showFinish { return }
            t = !s
        }
        print("Should toggle", t)
        UIView.animate(withDuration: animated ? 0.7 : 0, delay: 0, options: .curveEaseInOut, animations: {
            print("animate")
            self.currentContentViewLeading.constant = t ? 0 : -self.view.frame.width+16
            self.view.layoutIfNeeded()

        }) { _ in
            self.showFinish = !t
            self.updateDetailLabel()
        }
    }
    
    func updateAllUI() {
        self.collectionView.reloadData()
        
        if let item = currentItem {
            currentQuantity.text = "\(item.quantity)"
            
            let a = NSMutableAttributedString(string:
                item.name + "\n" +
                item.price.currency_format + " each\n" +
                item.category
            )
            
            //Name Color
            let nameRange = NSMakeRange(0, item.name.length)
            a.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.grey.3, range: nameRange)
            
            //Price Color
            let priceRange = NSMakeRange(item.name.length, item.price.currency_format.length+1)
            a.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.green, range: priceRange)
            
            //Category & end of price Color
            let categoryStart = priceRange.location + priceRange.length + 1
            let categoryRange = NSMakeRange(categoryStart, a.length - categoryStart)
            a.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.grey.2, range: categoryRange)
            
            currentLabel.attributedText = a
            
            self.currentImage.image = #imageLiteral(resourceName: "Picture Grey")
            self.currentImage.contentMode = .center
            R.loadImg(img: URL(string: C.URL.main + "/img/items/\(item.id).png")!) { image in
                if let img = image {
                    UIView.animate(withDuration: 0.15, animations: {
                        self.currentImage.alpha = 0.0
                    }, completion: { _ in
                        self.currentImage.contentMode = .scaleAspectFit
                        self.currentImage.image = img
                        UIView.animate(withDuration: 0.15) {
                            self.currentImage.alpha = 1.0
                        }
                    })
                }
            }
        }
    }
}

extension PackOrderVC: AnomalyDelegate {
    func didDismiss(_ reduceTo: Int?) {
        self.removeOverlay()
        if let r = reduceTo {
            self.currentItem?.status = .anomaly
            self.currentItem?.anomalyPacked = r
            self.updateStatus(of: self.currentItem)
            self.nextItem()
        }
    }
}

extension PackOrderVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //let i2 = items.of(status: [.packed, .anomaly]).isEmpty ? 0 : 1
        //let i1 = items.of(status: .unpacked).isEmpty ? 0 : 1
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 1 ? items.of(status: [.packed, .anomaly]).count : items.of(status: .unpacked).count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let h = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! PackingListHeader
            h.titleLabel.text = ["Unp", "P"][indexPath.section] + "acked Items (\(collectionView.numberOfItems(inSection: indexPath.section)))"
        return h
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PackingListCell
        let i = indexPath.section == 1 ? items.of(status: [.packed, .anomaly]) : items.of(status: .unpacked)
        let item = i[indexPath.row]
        var attributes: [NSAttributedStringKey:Any] = [:]
        var subtitle = ""
        var title = item.name
        
        if item.status == .unpacked {
            if indexPath.row == 0 && indexPath.section == 0 {
                title = "[Packing] " + title
                attributes[NSAttributedStringKey.foregroundColor] = Color.green
            }
            subtitle = "Quantity: \(item.quantity)"
        } else if item.status == .packed {
            attributes[NSAttributedStringKey.strikethroughStyle] =  NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)
            attributes[NSAttributedStringKey.foregroundColor] = Color.green
            subtitle = "Collected All (\(item.quantity))"
        } else if item.status == .anomaly {
            attributes[NSAttributedStringKey.strikethroughStyle] =  NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)
            attributes[NSAttributedStringKey.foregroundColor] = Color.red
            subtitle = "Collected \(item.anomalyPacked!) / \(item.quantity)"
        }
        
        c.titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: attributes)
        c.subtitleLabel.text = subtitle
        
        c.detailButton.action = {
            c.toggleDetail(false)
            item.status = .unpacked
            item.anomalyPacked = nil
            self.updateStatus(of: item)
            self.nextItem()
        }
        
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 102)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: section == 0 ? 34 : 50)
    }
}

extension PackOrderVC: DrawViewDelegate {
    func didDraw() {
        self.finishButton.alpha = signatureView.hasContent ? 1 : 0.5
    }
}

extension PackOrderVC: DetailDelegate {
    func didFinishDetail() {
        self.removeOverlay()
    }
    
    func didFinishDetailWith(item toGoTo: Item?) {
        self.didFinishDetail()
    }
}

class PackingListHeader: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
}

class PackingListCell: UICollectionViewCell {
    var showingDetail = false
    func toggleDetail(_ show: Bool? = nil) {
        var t = showingDetail
        if show != nil {
            t = !show!
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.itemContentView.frame.origin.x = t ? 0 : -116
            self.detailButton.frame.origin.x = t ? self.frame.width : self.frame.width - 100
        }) { _ in
            self.showingDetail = !t
        }
    }
    
    @IBOutlet weak var detailButton: LargeButton!
    @IBOutlet weak var itemContentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
}

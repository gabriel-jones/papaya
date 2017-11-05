//
//  StatusVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 03/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLActionController
import SCLAlertView

enum StatusMode: String {
    case sent, packing, packed, delivery, finished
}

protocol StatusCollectionModelDelegate {
    func tip(personType: Order.Person.PersonType)
    func addExpress()
    func changeDelivery()
    func finish()
    func summary()
}

class StatusCollectionModel {
    
    var currentModel = Array<String>()
    var delegate: StatusCollectionModelDelegate!
    
    func getCell(row: Int) -> String? {
        return currentModel[row]
    }
    
    class _Data {
        func statusMessage(for: StatusMode) -> String? {
            return [
                .sent: "Your order has been sent to the store and is waiting to be packed.",
                .packing: "Your order is being packed by an employee at Miles Market.",
                .packed: "Your order has been packed and is awaiting delivery to:",
                .delivery: "Your order is being delivered to:",
                .finished: "Your order has been completed. Thank you for using PrePacked!"
            ][`for`]
        }
    }; private var _data = _Data()
    
    func applyData(cell: inout UITableViewCell) {
        let status = Order.current.status
        
        switch cell {
        case let c as MainStatus:
            c.statusTitle.text = status.rawValue.capitalizingFirstLetter()
            c.statusMessage.text = _data.statusMessage(for: status)
            c.statusImage.image = #imageLiteral(resourceName: "Paper Airplane")
        case let c as AddExpress:
            c.addExpressButton.action = delegate.addExpress
        case let c as PersonCell:
            let currentPerson = status == .delivery ? Order.current.delivery.driver : Order.current.packing.packer
            guard let person = currentPerson else {
                break
            }
            c.personDescription.text = [
                .packing: "Being packed by:",
                .packed: "Packed by:",
                .delivery: "Being delivered by:"
            ][status]
            c.personName.text = person.name
            c.personTip.action = {
                self.delegate.tip(personType: person.type)
            }
        case let c as StartTip:
            c.tipDriverButton.action = { self.delegate.tip(personType: .driver) }
            c.tipPackerButton.action = { self.delegate.tip(personType: .packer) }
        case let c as PriceBreakdown:
            unowned let prices = Order.current.prices
            c.totalLabel.text = prices.total.currency_format
            c.subtotalLabel.text = prices.cartSubtotal.currency_format
            c.expressLabel.text = prices.expressCost.currency_format
            c.packingLabel.text = prices.packingFee.currency_format
            c.tipsLabel.text = prices.tips.currency_format
        case let c as FinishButton:
            c.button.action = delegate.finish
        case let c as OrderSummary:
            c.button.action = delegate.summary
            /*c.itemCountLabel.text = "\(Order.current.packing.items.count - Order.current.packing.packedItemsCount) items left"
            c.percentLabel.text = "\(Order.current.packing.progress * 100)% Packed"
            c.setProgress(to: Order.current.packing.progress)*/
        default:break
        }
    }
}

class Order {
    static var current = Order()
    
    var id: Int = 0
    var status: StatusMode = .sent
    var isExpress = false
    
    var packerTip: Double = 0
    var driverTip: Double = 0
    
    var shopId: Int = 0
    
    struct Person {
        var id: Int
        var name: String
        enum PersonType {
            case driver, packer
        }; var type: PersonType
    }
    
    class PriceCollection {
        var total = 0.0
        
        var cartSubtotal = 0.0
        var packingFee = 0.0
        var expressCost = 0.0
        var tips = 0.0
        
    }; var prices = PriceCollection()
    
    class Packing {
        var packer: Person?
        var items = Array<OrderItem>()
        var packedItemsCount: Int {
            get {
                return items.map { $0.status == .packed || $0.status == .anomaly }.count
            }
        }
        
        var progress: Float {
            get {
                return Float(packedItemsCount) / Float(items.count)
            }
        }
    }; var packing = Packing()
    
    class Delivery {
        var isEnabled = true
        
        var driver: Person?
        
        var from = Location()
        var fromAddress = String()
        
        var driverLocation: Location?
        
        var to = Location()
        var toAddress = String()
    }; var delivery = Delivery()
}

class StatusFetchModel {
    static var shared = StatusFetchModel()
    
    func fetch(order: Int, _ callback: @escaping (JSON?, Bool) -> ()) {
        print("fetch", order)
        R.get("/scripts/Orders/current_order_status.php", parameters: ["order_id": order], callback)
    }
}

class StatusVC: BaseVC {
    
    //MARK: - Properties
    
    let model = StatusCollectionModel()
    
    var packing_progress: Float = 0
    var delivery_progress: Float = 0
    
    //MARK: - Outlets
    @IBOutlet weak var callStore: LargeButton!
    @IBOutlet weak var getSupport: LargeButton!
    @IBOutlet weak var viewOrderSummary: LargeButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Progress
    
    @IBOutlet weak var deliveryBulb: UIView!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var deliveryProgress: UIView!
    @IBOutlet weak var deliveryTrack: UIView!
    @IBOutlet weak var packingLabel: UILabel!
    @IBOutlet weak var packingBulb: UIView!
    @IBOutlet weak var packingProgress: UIView!
    @IBOutlet weak var packingTrack: UIView!
    
    //MARK: - Actions
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func more(_ sender: UIButton) {
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
        
        a.addAction(Action(ActionData(title: "Support", image: #imageLiteral(resourceName: "Help Green Filled")), style:
        .default) { action in
            let vc = StatusSupportVC.instantiate(from: .status)
            self.addOverlay(vc, animated: true, completion: nil)
        })
        
        present(a, animated: true, completion: nil)
    }
    
    //MARK: - View Methods
    
    func updateRegisters() {
        for module in model.currentModel {
            tableView.register(UINib(nibName: module, bundle: nil), forCellReuseIdentifier: module)
        }
    }
    
    func updateModules() {
        print("update modules")
        var model = ["MainStatus"]
        
        let status = Order.current.status
        switch(status) {
        case .sent:
            model += ["StartTip"]
        case .packing:
            model += ["PersonCell"] //, "PackingStatus"]
        case .packed:
            model += ["PersonCell"]
        case .delivery:
            model += ["PersonCell", "DeliveryStatus"]
        case .finished:
            model += ["PriceBreakdown", "FinishButton"]
        }
        
        if Order.current.isExpress {
            model.insert("ExpressStatus", at: 0)
        } else if status == .sent || status == .packed {
            model += ["AddExpress"]
        }
        
        model += ["OrderSummary"]
        self.model.currentModel = model
        self.updateRegisters()

        tableView.reloadData()
        /*
        collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }, completion: nil)*/
    }
    
    func updateData( _ completion: (() -> ())? = nil) {
        StatusFetchModel.shared.fetch(order: Order.current.id) { json, error in
            guard let j = json, !error else {
                return
            }
            print(j)
            if j.null != nil {
                return
            }
            
            unowned let model = Order.current
            model.shopId = j["shop_id"].intValue
            
            model.isExpress = Bool.binaryValue(j["is_express"].intValue) ?? false
            model.status = StatusMode(rawValue: j["status"].stringValue)!
            if j["packer"].null != nil {
                model.packing.packer = Order.Person(id: j["packer"]["id"].intValue, name: j["packer"]["name"].stringValue, type: .packer)
            }
            
            if j["driver"].null != nil {
                model.delivery.driver = Order.Person(id: j["driver"]["id"].intValue, name: j["driver"]["name"].stringValue, type: .driver)
            }
            
            model.driverTip = j["driver_tip"].doubleValue
            model.packerTip = j["packer_tip"].doubleValue
            model.prices.tips = model.driverTip + model.packerTip
            
            model.delivery.to = Location(lat: j["latitude"].doubleValue, long: j["longitude"].doubleValue)
            model.delivery.toAddress = j["address"].stringValue
            
            if let shop = Shop.from(id: model.shopId) {
                model.delivery.from = shop.location
                model.delivery.fromAddress = shop.address
            }
            
            completion?()
        }
    }
    
    @objc func refresh(_ sender: Any) {
        updateData {
            self.updateUI()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    func updateUI() {
        updateModules()
        updateProgress()
    }
    
    func updateProgress() {
        let index = ["sent", "packing", "packed", "delivering", "finished"].index(of: Order.current.status.rawValue) ?? 0
        if index > 0 {
            let w = CGFloat(packing_progress) * packingTrack.frame.width
            packingProgress.frame.size = CGSize(width: w, height: packingProgress.frame.height)
        }
        if index > 1 {
            packingBulb.backgroundColor = Color.yellow
            packingLabel.textColor = Color.yellow
        }
        if index > 2 {
            let w = CGFloat(delivery_progress) * deliveryTrack.frame.width
            deliveryProgress.frame.size = CGSize(width: w, height: deliveryProgress.frame.height)
        }
        if index > 3 {
            deliveryBulb.backgroundColor = Color.yellow
            deliveryLabel.textColor = Color.yellow
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        model.currentModel = []
        //Load update for order
        updateData {
            //Update UI
            self.updateUI()
        }
    }
}

extension StatusVC: StatusCollectionModelDelegate, GiveTipDelegate {
    func addExpress() {
        
    }
    
    func changeDelivery() {
        
    }
    
    func tip(personType: Order.Person.PersonType) {
        let vc = GiveTipVC.instantiate(from: .status)
        vc.delegate = self
        vc.personType = personType
        self.addOverlay(vc, animated: true, completion: nil)
    }
    
    func tip(amount: Double, personType: Order.Person.PersonType) {
        print("Tip: \(amount), \(personType)")
        if amount != 0 {
            
        }
        self.closeOverlay(animated: true)
    }
    
    func finish() {
        Order.current.id = -1
        self.dismiss(animated: true, completion: nil)
    }
    
    func summary() {
        
    }
    
    
}

//MARK: - CollectionView

extension StatusVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.currentModel.count+1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == model.currentModel.count ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = model.getCell(row: indexPath.section)!
        var cell = tableView.dequeueReusableCell(withIdentifier: cellData, for: indexPath)
        model.applyData(cell: &cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}

//
//  PayViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 18/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON
import SCLAlertView

var orderInProgress = false

class CheckoutVC: GroceryVC {
    
    //MARK: - Propertiies 
    var scrollLimit = false
    var isShowingDeliveryDetail = false
    
    //MARK: - Outlets
    
    //MARK: Total View
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var packingFeeLabel: UILabel!
    @IBOutlet weak var expressLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopSubtitle: UILabel!
    
    @IBOutlet weak var buyButton: LargeButton!
    
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var editCardButton: LargeButton!
    
    @IBOutlet weak var cartDetailsLabel: UILabel!
    @IBOutlet weak var viewCartButton: LargeButton!
    
    @IBOutlet weak var deliveryAddressLabel: UILabel!
    @IBOutlet weak var viewDeliveryButton: LargeButton!
    @IBOutlet weak var deliveryMap: GMSMapView!
    @IBOutlet weak var deliveryContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var deliveryMask: UIView!
    //MARK: - Actions
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func expressChange(_ sender: UISwitch) {
        GroceryList.current.delivery.isExpress = sender.isOn
        updateTotals()
    }
    
    //MARK: - Methods
    
    func updateTotals() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deliveryMask.clipsToBounds = true
        deliveryMask.cornerRadius = 10
        
        deliveryMap.camera = GMSCameraPosition.camera(withLatitude: 32.309657, longitude: -64.750270, zoom: 12.0)

        buyButton.action = buy
        
        editCardButton.action = editPayment
        viewCartButton.action = viewCart
        viewDeliveryButton.action = editDelivery
        
        subtotalLabel.text = GroceryList.current.total.currency_format
        packingFeeLabel.text = 10.0.currency_format
        expressLabel.text = 5.0.currency_format
        
        var total = 10 + GroceryList.current.total
        if GroceryList.current.delivery.isExpress {
            total += 5
        }
        totalLabel.text = total.currency_format
        
        shopName.text = GroceryList.current.shop.name
        shopSubtitle.text = Date().default_format
        
        cardLabel.text = String(repeating: "**** ", count: 3) + User.current.card
        
        cartDetailsLabel.text = GroceryList.current.total.currency_format + " | \(GroceryList.current.items.count) items"
        
        deliveryAddressLabel.text = GroceryList.current.delivery.isEnabled ? GroceryList.current.delivery.address : "Disabled"
        
        if !GroceryList.current.delivery.isEnabled {
            deliveryContainerHeight.constant = 75
            viewDeliveryButton.alpha = 0
            deliveryAddressLabel.textColor = Color.red
        }
    }
}

protocol CheckoutDeliveryDelegate: class {
    func pickedDelivery(location: Location, address: String)
}

//MARK: GMSMapView
extension CheckoutVC: CheckoutDeliveryDelegate {
    func pickedDelivery(location: Location, address: String) {
        let delivery = GroceryList.current.delivery
        delivery.address = address
        delivery.location = location
        
        deliveryAddressLabel.text = delivery.address
    }
}

//MARK: Buttons
extension CheckoutVC {
    func editPayment() {
        let a = UIAlertController(title: "Please enter your password", message: nil, preferredStyle: .alert)
        a.addTextField { t in
            t.isSecureTextEntry = true
            t.keyboardAppearance = .dark
            t.autocorrectionType = .no
            t.autocapitalizationType = .none
        }
        a.addAction(UIAlertAction(title: "OK", style: .default) { [weak a] (_) in
            do {
                let p = try keychain.get("user_password")
                if a!.textFields![0].text! == p {
                    let vc = PaymentVC.instantiate(from: .settings)
                    vc.isFromPayVC = true
                    let nav = UINavigationController(rootViewController: vc)
                    nav.navigationBar.barStyle = .black
                    nav.navigationBar.tintColor = UIColor.white
                    nav.navigationBar.barTintColor = Color.green
                    nav.navigationBar.isTranslucent = false
                    nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
                    self.present(nav, animated: true, completion: nil)
                }
            } catch {
                print("Could not read from keychain. Exiting...")
                exit(-666)
            }
            
        })
        a.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(a, animated: true, completion: nil)
    }
    
    func editDelivery() {
        print("editDelivery()")
        let vc = CheckoutDeliveryVC.instantiate(from: .order)
        print("1")
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        print("2")
    }
    
    func viewCart() {
        print("View cart")
    }
    
    func buy() {
        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        a.addButton("Continue", backgroundColor: Color.green) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Processing") as! ProcessingVC
            vc.delegate = self
            
            
            vc.modalPresentationStyle = .overCurrentContext
            self.addOverlay(vc, animated: true, completion: nil)
        }
        a.addButton("Cancel") {}
        a.showNotice("Start Order?", subTitle: "You will not be charged until the order is completed.")
    }
}

/*//MARK: UITableView
extension CheckoutVC: UITableViewDelegate, UITableViewDataSource {
    //
}*/

//MARK: ProcessDelegate
extension CheckoutVC: ProcessDelegate {
    
    func didProcess(_ error: ProcessingVC.OrderError?) {
        self.closeOverlay()
                
        guard let e = error else {
            R.itemImages.removeAll()
            _ = self.navigationController?.popToRootViewController(animated: false)
            orderInProgress = true
            return
        }
        
        let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        var sub = ""
        switch e {
        case .unverified:
            sub = "Your email is not verified."
            a.addButton("Resend Verification Email") {
                R.verifyEmail(User.current.email) { success in
                    let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    a.addButton("OK") {}
                    if success {
                        a.showWarning("Could not send verification email", subTitle: "Please check your connection and try again.")
                    } else {
                        a.showSuccess("Email sent", subTitle: "Please check your email for the verification link.")
                    }
                }
            }
        case .payment:
            sub = "Your payment details were revoked."
            a.addButton("Review payment details") {
                self.editPayment()
            }
        case .offline:
            sub = "Please check your connection and try again."
        case .userID:
            sub = "There was an unexpected account error. Please try again."
        }
        a.addButton("OK") {}
        a.showWarning("Could not add order", subTitle: sub)
    }
}

protocol ProcessDelegate {
    func didProcess(_ error: ProcessingVC.OrderError?)
}

class ProcessingVC: UIViewController {
    
    //MARK: - Properties
    var delegate: ProcessDelegate!
    //TODO: input variables
    
    //MARK: - Outlets
    @IBOutlet weak var loading: LoadingIndicator!
    
    //MARK: - Enums
    enum OrderError: Int {
        case offline, unverified = 3, payment, userID = 2
    }
    
    //MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        //ac.draw()
        //ac.startAnimating()
        loading.startAnimating()
        buy()
    }
    
    func addOrder(c: @escaping (OrderError?)->()) {
        //3. add order
        var body: [String:Any] = [:]
        
        var items = [[String:Any]]()
        for item in GroceryList.current.items {
            items.append(["id":"\(item.0.id)", "quantity":"\(item.1)"])
        }
        
        body["shop_id"] = GroceryList.current.shop_id
        body["user_id"] = User.current.id
        body["items"] = items
        body["latitude"] = GroceryList.current.delivery.location!.latitude
        body["longitude"] = GroceryList.current.delivery.location!.longitude
        body["address"] = GroceryList.current.delivery.address!
        body["amount"] = GroceryList.current.total
        
        R.post("/scripts/Orders/add_order.php", parameters: body) { json, error in
            guard !error, let j = json else {
                c(.offline)
                return
            }
            
            if j["success"].boolValue {
                Order.current.id = j["id"].intValue
                c(nil)
            } else {
                let err = OrderError(rawValue: j["code"].intValue)
                c(err ?? .offline)
            }
        }
    }
    
    func buy() {
        //1. check online status
        R.checkConnection() { online in
            if !online {
                self.dismiss(animated: true) {
                    self.delegate.didProcess(.offline)
                }
                return
            }
            
            //2. order
            self.addOrder { e in
                self.dismiss(animated: true) {
                    self.delegate.didProcess(e)
                }
            }
        }
    }
}

func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (String?) -> ()) {
    let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard error == nil else {
            print(error!.localizedDescription)
            completion(nil)
            return
        }
        
        let json = JSON(data: data!)
        completion(json["routes"][0]["overview_polyline"]["points"].string)
    }.resume()
}

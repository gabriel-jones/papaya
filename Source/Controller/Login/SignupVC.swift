//
//  SignupVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 16/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps
import GooglePlaces

protocol SignupDelegate: class {
    func navigate(_ direction: UIPageViewControllerNavigationDirection)
    func finish()
    func signup(_ completion: @escaping (Bool) -> ())
    func set(key: String, value: Any)
}

class SignupChildVC: BaseVC {
    var delegate: SignupDelegate!
    
    override func tap(_ sender: UITapGestureRecognizer) {
        super.tap(sender)
        self.view.endEditing(true)
    }
}

class SignupVC: BaseVC {
    
    //MARK: - Properties
    
    var page: Int = 0
    var pageViewController: UIPageViewController?
    private(set) lazy var pageVCs: [SignupChildVC] = {
        return [0,1,2,3,4].map { self.getVC(at: $0) }
    }()
    
    var data = JSON([:])
    
    //MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    //MARK: - Actions
    
    @IBAction func login(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigate(.reverse)
    }
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.gradientBackground()
        
        self.setupPageVC()
    }
    
    //MARK: - Methods
    
}

extension SignupVC: UIPageViewControllerDelegate {
    
    //MARK: - View Methods
    func setupPageVC() {
        //PageVC
        let pageController = self.storyboard!.instantiateViewController(withIdentifier: "SignupPageController") as! UIPageViewController
        pageController.delegate = self
        
        //Set current page to first VC
        if let vc = pageVCs.first {
            pageController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
        
        //Set pageVC frame and add to self
        pageViewController = pageController
        addChildViewController(pageViewController!)
        pageViewController!.view.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 41 - 54)
        pageViewController!.view.clipsToBounds = false
        pageViewController!.view.subviews.first?.clipsToBounds = false
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
        
        for v in pageViewController!.view.subviews {
            if let s = v as? UIScrollView {
                s.delaysContentTouches = false
            }
        }
    }
}

extension SignupVC: SignupDelegate {
    func getVC(at index: Int) -> SignupChildVC {
        let name = "Signup_" + ["TermsVC", "DetailsVC", "CardVC", "DeliveryVC", "PremiumVC"][index]
        let vc = self.storyboard!.instantiateViewController(withIdentifier: name) as! SignupChildVC
        vc.delegate = self
        return vc
    }
    
    func navigate(_ direction: UIPageViewControllerNavigationDirection) {
        self.view.endEditing(true)
        page += direction == .forward ? 1 : -1
        if page > pageVCs.count { page = pageVCs.count-1 }
        if page < 0 {
            self.login(self)
        }
        self.setVC(pageVCs[page], direction)
    }
    
    func setVC(_ viewController: UIViewController, _ direction: UIPageViewControllerNavigationDirection = .forward, _ animated: Bool = true) {
        pageViewController!.setViewControllers([viewController], direction: direction, animated: animated, completion: { completed in
            DispatchQueue.main.async {
                self.didNavigate(completed)
            }
        })
    }
    
    func didNavigate(_ completed: Bool) {
        titleLabel.text = ["Terms and Conditions", "Account Details", "Payment Information", "Delivery", "Premium"][page]
        
        if page == 4 {
            titleLabel.textColor = Color.yellow
            titleLabel.font = UIFont(name: "GothamRounded-Bold", size: titleLabel.font.pointSize)
        }
    }
    
    func finish() {
        /*let al = alert(actions: [
            AlertButton.init("OK", backgroundColor: Color.green, textColor: UIColor.white) {
                didLogin = true
                self.dismiss(animated: true, completion: nil)
            }
        ])
        al.showSuccess("You're signed up!", subTitle: "Please check your email for a verification link")*/
    }
    
    func signup(_ completion: @escaping (Bool) -> ()) {
        R.register(email: data["email"].stringValue, password: data["password"].stringValue, fname: data["fname"].stringValue, lname: data["lname"].stringValue, cc: data["cardNumber"].stringValue, cvv: data["code"].stringValue, exp: data["exp"].stringValue, address: data["address"].stringValue, houseNumber: data["houseNumber"].stringValue, location: Location.init(lat: data["latitude"].doubleValue, long: data["longitude"].doubleValue), premium: data["premium"].boolValue) { err in
            guard err == nil else {
                /*let al = alert(actions: [
                    AlertButton.init("OK", backgroundColor: Color.red, textColor: UIColor.white) {
                        
                    }
                ])
                switch err! {
                case .incorrectEmail:
                    al.showError("Could not sign up", subTitle: "Invalid email.")
                    self.navigate(to: 1)
                case .invalidPayment:
                    al.showError("Could not sign up", subTitle: "Invalid payment details.")
                    self.navigate(to: 2)
                case .ambiguous:
                    al.showError("Could not sign up", subTitle: "Please try again.")
                default: break
                }
                */
                completion(false)
                return
            }
            completion(true)
         }
    }
    
    func navigate(to: Int) {
        self.setVC(pageVCs[to], .reverse, true)
    }
    
    func set(key: String, value: Any) {
        data[key] = JSON(value)
    }
}

class Signup_TermsVC: SignupChildVC {
    @IBOutlet weak var agree: LargeButton!
    @IBOutlet weak var terms: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        agree.action = {
            self.delegate.navigate(.forward)
        }
    }
}

class Signup_DetailsVC: SignupChildVC, UITextFieldDelegate {
    @IBOutlet weak var firstName: LoginTextField!
    @IBOutlet weak var lastName: LoginTextField!
    @IBOutlet weak var email: LoginTextField!
    @IBOutlet weak var password: LoginTextField!
    @IBOutlet weak var repeatPassword: LoginTextField!
    
    @IBOutlet weak var nextButton: LargeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.action = {
            self.load()
            self.check { valid in
                self.stopLoading()
                if valid {
                    self.delegate.set(key: "fname", value: self.firstName.text!)
                    self.delegate.set(key: "lname", value: self.lastName.text!)
                    self.delegate.set(key: "email", value: self.email.text!)
                    self.delegate.set(key: "password", value: self.password.text!)
                    self.delegate.navigate(.forward)
                }
            }
        }
        
        firstName.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        lastName.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        email.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        password.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        repeatPassword.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textDidChange(_ sender: LoginTextField) {
        sender.error = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func check(_ completion: @escaping (Bool) -> ()) {
        firstName.error = firstName.text!.isEmpty
        lastName.error = lastName.text!.isEmpty
        password.error = password.text!.isEmpty
        email.error = email.text!.isEmpty
        repeatPassword.error = repeatPassword.text != password.text || repeatPassword.text!.isEmpty
        
        for v in self.view.subviews {
            if let tx = v as? LoginTextField {
                if tx.error {
                    completion(false)
                    return
                }
            }
        }
        
        R.checkEmail(email.text!) { result in
            print(result)
            switch result {
            case .valid:
                completion(true)
            case .invalid, .taken:
                self.email.error = true
                completion(false)
            case .requestError:
                print("request error")
                completion(false)
            }
        }
    }
}

class Signup_CardVC: SignupChildVC, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var cc: LoginTextField!
    @IBOutlet weak var exp: LoginTextField!
    @IBOutlet weak var code: LoginTextField!
    
    @IBOutlet weak var nextButton: LargeButton!
    
    var picker: UIPickerView!
    var y: Array<String> = []
    var m: Array<String> = []
    var curMonth = "January"
    var curYear = ""
    var active: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.action = {
            self.check { valid in
                if valid {
                    self.delegate.set(key: "cardNumber", value: self.cc.text!)
                    self.delegate.set(key: "exp", value: self.exp.text!)
                    self.delegate.set(key: "code", value: self.code.text!)
                    self.delegate.navigate(.forward)
                }
            }
        }
        
        cc.tag = 6002
        cc.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        
        code.tag = 6000
        code.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        
        exp.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        exp.tag = 6001
        
        self.setupPickerView()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        active = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        active = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 6001 {
            return false
        }
        if textField.tag == 6002 {
            if !(string =~ "[0-9 ]+") && string != "" || string == ". " {
                return false
            }
            
            if string.characters.count >= 16 {
                return false
            }
        }
        return true
    }
    
    @objc func textDidChange(_ sender: LoginTextField) {
        if sender.tag == 6000 {
            if code.text!.characters.count > 3 {
                code.text = code.text?.substring(to: 3)
            }
        }
        
        sender.error = false
    }
    
    func setupPickerView() {
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        for i in 0..<12 {
            m.append("\(months[i])")
        }
        
        let currYear = Calendar.current.component(.year, from: Date())
        
        for i in currYear...currYear+25 {
            y.append("\(i)")
        }
        
        let tbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        tbar.barStyle = .default
        let flex = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let tbar_done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        tbar.items = [flex,tbar_done]
        
        picker = UIPickerView(frame: CGRect(x: 0, y: tbar.frame.height, width: self.view.frame.width, height: 200))
        picker.delegate = self
        
        let input = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: picker.frame.height + tbar.frame.height))
        input.addSubview(picker)
        input.addSubview(tbar)
        
        exp.inputView = input
        exp.keyboardAppearance = .dark
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            curMonth = m[row]
        } else {
            curYear = y[row]
        }
        exp.text = "\(monthN(curMonth))/\(curYear)"
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return m[row]
        } else {
            return y[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.width/2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return m.count
        } else {
            return y.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    @objc func donePicker() {
        exp.resignFirstResponder()
    }
    
    func check(_ completion: (Bool) -> ()) {
        exp.error = exp.text!.isEmpty
        code.error = code.text!.isEmpty
        cc.error = cc.text!.isEmpty
        
        for v in self.view.subviews {
            if let tx = v as? LoginTextField {
                if tx.error {
                    completion(false)
                    return
                }
            }
        }
        
        completion(true)
    }
}

class Signup_DeliveryVC: SignupChildVC, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: LargeButton!
    
    @IBOutlet weak var houseNumber: UITextField!
    var placeID = String()
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.action = {
            self.load()
            self.getLatLng { success, result in
                self.stopLoading()
                guard let result = result, success else {
                    return
                }
                self.delegate.set(key: "address", value: self.address.text!)
                self.delegate.set(key: "latitude", value: result.coordinate.latitude)
                self.delegate.set(key: "longitude", value: result.coordinate.longitude)
                self.delegate.set(key: "houseNumber", value: self.houseNumber.text!)
                self.delegate.set(key: "placeID", value: result.placeID)
                self.delegate.navigate(.forward)
            }
        }
        containerHeight.constant = 74
        
        address.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        houseNumber.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textDidChange(_ sender: LoginTextField) {
        if sender.tag == 69 {
            return
        }
        
        houseNumberContainer.isHidden = true
        
        let t = sender.text
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
            if sender.text == t {
                self.loadAddresses()
            }
        }
    }
    
    func getLatLng(_ completion: @escaping (Bool, GMSPlace?)->()) {
        if placeID.isEmpty { return }
        GMSPlacesClient.shared().lookUpPlaceID(placeID) { result, error in
            guard let result = result, error == nil else {
                completion(false, nil)
                return
            }
            completion(true, result)
        }
    }
    
    var autocomplete: [GMSAutocompletePrediction] = []
    
    func loadAddresses() {
        let q = address.text
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "bm"
        GMSPlacesClient.shared().autocompleteQuery(q!, bounds: nil, filter: filter) { results, error in
            guard let results = results, error == nil else {
                print(error!)
                return
            }
            
            self.autocomplete.removeAll()
            for result in results {
                self.autocomplete.append(result)
            }
            
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        UIView.animate(withDuration: 0.3) {
            //self.containerHeight.constant = self.autocomplete.count == 0 ? 74 : 375
            self.containerHeight.constant = CGFloat(self.autocomplete.count * 50 + 74)
            self.view.layoutIfNeeded()
        }
        return autocomplete.count
    }
    
    @IBOutlet weak var houseNumberContainer: UIView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryCell", for: indexPath)
        cell.textLabel?.text = autocomplete[indexPath.row].attributedFullText.string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addr = autocomplete[indexPath.row]
        address.text = addr.attributedFullText.string
        placeID = addr.placeID!
        autocomplete.removeAll()
        tableView.reloadData()
        houseNumberContainer.isHidden = false
        view.endEditing(true)
    }
}

class Signup_PremiumVC: SignupChildVC {

    @IBOutlet weak var getPremium: LargeButton!
    @IBOutlet weak var noThanks: LargeButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPremium.action = {
            self.finish(true)
        }
        
        noThanks.action = {
            self.finish(false)
        }
    }
    
    func finish(_ premium: Bool) {
        self.load()
        self.delegate.set(key: "premium", value: premium)
        self.delegate.signup { success in
            self.stopLoading()
            if success {
                self.delegate.finish()
            }
        }
    }
}



















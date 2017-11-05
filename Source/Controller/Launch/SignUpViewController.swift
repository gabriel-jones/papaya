//
//  SignUpViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 16/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//


import UIKit

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    enum RegexError: Error {
        case error
    }
    
    init(_ pattern: String) throws {
        self.pattern = pattern
        do {
            self.internalExpression = try NSRegularExpression(pattern: self.pattern, options: .caseInsensitive)
        } catch {
            throw RegexError.error
        }
    }
    
    func test(_ input: String) -> Bool {
        let matches = self.internalExpression.matches(in: input, options: [], range: NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}

infix operator =~
func =~ (input: String, pattern: String) -> Bool {
    return try! Regex(pattern).test(input)
}

func monthN(_ m: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM"
    let date = dateFormatter.date(from: m)
    let month  = Calendar.current.component(.month, from: date!)
    return String(format: "%02d", month)
}
/*
class SignUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Properties
    var picker: UIPickerView!
    var y: Array<String> = []
    var m: Array<String> = []
    var curMonth = "January"
    var curYear = ""
    var active: UITextField?

    //MARK: - IBOutlets
    
    @IBOutlet weak var firstName: TextField!
    @IBOutlet weak var lastName: TextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var email: TextField!
    @IBOutlet weak var password: TextField!
    @IBOutlet weak var passwordRepeat: TextField!
    @IBOutlet weak var signup: LargeButton!
    @IBOutlet weak var exp: TextField!
    @IBOutlet weak var cvv: TextField!
    @IBOutlet weak var cardNum: TextField!
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var smallScreenBack: UIButton!
    @IBOutlet weak var smallScreenSignUp: LargeButton!
    
    func actuallySignUp() {
        self.isSigningUp = true
        for v in self.view.subviews {
            v.alpha = 0.5
        }
        let a = ActivityIndicator(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        a.center = self.view.center
        a.colorType = .White
        self.view.addSubview(a)
        a.draw()
        a.startAnimating()
        R.register(email: self.email.text!, password: self.password.text!, fname: self.firstName.text!, lname: self.lastName.text!, cc: self.cardNum.text!.replacingOccurrences(of: " ", with: ""), cvv: self.cvv.text!, exp: self.exp.text!) { s in
            DispatchQueue.main.async {
                self.isSigningUp = false
                if s == nil {
                    for v in self.view.subviews {
                        UIView.animate(withDuration: 0.3, animations: {
                            v.alpha = 1.0
                        })
                    }
                    a.removeFromSuperview()
                    
                    let al = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    al.addButton("OK") {
                        didLogin = true
                        self.dismiss(animated: true, completion: nil)
                    }
                    al.showSuccess("You're signed up!", subTitle: "Please check your email for a verification link")
                    
                } else {
                    if s == .incorrectEmail {
                        self.email.error = true
                    } else if s == .invalidPayment {
                        self.cardNum.error = true
                        self.cvv.error = true
                        self.exp.error = true
                    } else {
                        SCLAlertView().showWarning("An Error Occurred", subTitle: "Please try again, if the problem persists try restarting the app")
                    }
                }
            }
        }
    }
    
    var isSigningUp = false
    func validate() {
        if isSigningUp {
            return
        }
        isSigningUp = true
        
        exp.error = exp.text!.isEmpty
        cvv.error = cvv.text!.isEmpty
        cardNum.error = cardNum.text!.isEmpty
        firstName.error = firstName.text!.isEmpty
        lastName.error = lastName.text!.isEmpty
        password.error = password.text!.isEmpty
        email.error = email.text!.isEmpty
        passwordRepeat.error = passwordRepeat.text != password.text || passwordRepeat.text!.isEmpty
        
        for v in self.contentView.subviews {
            if let tx = v as? TextField {
                if tx.error {
                    self.isSigningUp = false
                    return
                }
            }
        }
        
        
        let a = ActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        a.center = self.view.center
        self.view.addSubview(a)
        a.colorType = .White
        a.draw()
        a.startAnimating()
        R.checkEmail(self.email.text!) { r in
            DispatchQueue.main.async {
                a.removeFromSuperview()
                let _a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                _a.addButton("OK", action: {})
                if r == .invalid {
                    self.email.error = true
                    _a.showWarning("Email Error", subTitle: "The email is invalid")
                } else if r == .taken {
                    self.email.error = true
                    _a.showWarning("Email Error", subTitle: "That email has already been registered")
                } else if r == .valid {
                    self.email.error = false
                    
                    var errors = false
                    for v in self.contentView.subviews {
                        if let tx = v as? TextField {
                            errors = errors || tx.error
                        }
                    }
                    if !errors {
                        self.actuallySignUp()
                    }
                } else {
                    _a.showWarning("Error", subTitle: "An error occured, please try again")
                }
                self.isSigningUp = false
            }
            
        }
        self.isSigningUp = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.main.bounds.width <= 580 {
            self.smallScreenBack.isHidden = false
            self.smallScreenSignUp.isHidden = false
            self.signup.isHidden = true
            self.back.isHidden = true
        }
        
        signup.action = validate
        smallScreenSignUp.action = validate
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setupPickerView()
        
        setupTextFields()
        
        let t = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.contentView.addGestureRecognizer(t)
        
    }
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTap() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    var isScrolledUp = false
    func keyboardWillShow(notification: Notification) {
        if self.view.frame.origin.y == 0 {
            if active != nil {
                var aRect = self.view.frame
                aRect.size.height -= 216 + 75
                if !aRect.contains(active!.frame.origin) {
                    isScrolledUp = true
                    self.view.frame.origin.y -= 216
                }
            }
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0{
            if isScrolledUp {
                self.view.frame.origin.y += 216
            }
        }
    }
}

//MARK: - UITextField
extension SignUpViewController {
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
    
    func textDidChange(_ sender: TextField) {
        if sender.tag == 6000 {
            if cvv.text!.characters.count > 3 {
                cvv.text = cvv.text?.substring(to: cvv.text!.characters.index(cvv.text!.startIndex, offsetBy: 3))
            }
        }
        
        /*if sender.tag == 6002 {
            var t = sender.text!
            if (t.characters.count - (t.components(separatedBy: " ").count-1)) % 4 == 0 { t.insert(" ", index: t.characters.count-(t.components(separatedBy: " ").count-1)) }
            sender.text = t
        }*/
        
        sender.error = false
    }
    
    func setupTextFields() {
        email.img = #imageLiteral(resourceName: "Email White")
        email.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        password.img = #imageLiteral(resourceName: "Lock White Filled-1")
        password.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        passwordRepeat.img = #imageLiteral(resourceName: "Lock White Filled-1")
        passwordRepeat.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        
        cardNum.img = #imageLiteral(resourceName: "Card White")
        cardNum.tag = 6002
        cardNum.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        
        cvv.img = #imageLiteral(resourceName: "CVV White")
        cvv.tag = 6000
        cvv.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        
        exp.img = #imageLiteral(resourceName: "Clock White")
        exp.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        exp.tag = 6001
    }
}


//MARK: - Picker View
extension SignUpViewController {
    
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
    
    func donePicker() {
        exp.resignFirstResponder()
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
}
*/

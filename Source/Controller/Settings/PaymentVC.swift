//
//  PaymentVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 7/8/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SCLAlertView

class PaymentVC: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var isFromPayVC = false
    
    @IBOutlet weak var creditCard: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var expirationDate: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var picker: UIPickerView!

    var y: Array<String> = []
    var m: Array<String> = []
    
    var curMonth = "January"
    var curYear = ""
    
    var madeChanges = false
    
    @IBAction func save(_ sender: UIButton?) {
        
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func shouldClose() -> Bool {
        self.view.endEditing(true)
        if madeChanges {
            let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            a.addButton("Save Changes", backgroundColor: Color.green, textColor: UIColor.white) {
                self.save(nil)
            }
            a.addButton("Exit", backgroundColor: Color.red, textColor: UIColor.white) {
                self.navigationController?.popViewController(animated: true)
            }
            a.addButton("Cancel", backgroundColor: Color.grey.0, textColor: UIColor.white) {}
            a.showWarning("Are you sure you want to exit?", subTitle: "Any unsaved changes will be lost.")
            return false
        }
        return true
    }
    
    @objc func close(_ sender: Any) {
        self.view.endEditing(true)
        if madeChanges {
            let a = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            a.addButton("Save Changes", backgroundColor: Color.green, textColor: UIColor.white) {
                self.save(nil)
            }
            a.addButton("Exit", backgroundColor: Color.red, textColor: UIColor.white) {
                self.dismiss(animated: true, completion: nil)
            }
            a.addButton("Cancel", backgroundColor: Color.grey.0, textColor: UIColor.white) {}
            a.showWarning("Exit?", subTitle: "Any unsaved changes will be lost.")
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
        return shouldClose()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromPayVC {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close(_:)))
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        
        for i in 0..<12 { m.append("\(months[i])") }
        
        let currYear = Calendar.current.component(.year, from: Date())
        
        for i in currYear...currYear+25 {
            y.append("\(i)")
        }
        
        creditCard.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        cvv.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        expirationDate.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        
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
        
        expirationDate.inputView = input

    }
    
    @objc func donePicker() {
        expirationDate.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        madeChanges = true
        if sender.tag == 6000 {
            if cvv.text!.characters.count > 3 {
                cvv.text = cvv.text?.substring(to: 3)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("should change?")
        print(textField.tag)
        if textField.tag == 6000 {
            if !(string =~ "[0-9]+") && string != "" {
                return false
            }
        } else if textField.tag == 6001 {
            return false
        } else if textField.tag == 6002 {
            if !(string =~ "[0-9 ]+") && string != "" || string == ". " {
                return false
            }
            if textField.text!.characters.count >= 16 && string != "" {
                return false
            }
        }
        
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        madeChanges = true
        if component == 0 {
            curMonth = m[row]
        } else {
            curYear = y[row]
        }
        expirationDate.text = "\(monthN(curMonth))/\(curYear)"
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
}

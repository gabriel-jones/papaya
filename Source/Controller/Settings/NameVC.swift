//
//  NameVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 21/07/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class NameVC: UITableViewController {

    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var first: UITextField!
    @IBOutlet weak var last: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.first.text = User.current.name.0
        self.last.text = User.current.name.1
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        self.first.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.last.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    var madeChanges = false
    
    override func navigationShouldPopOnBackButton() -> Bool {
        self.view.endEditing(true)
        if madeChanges {
            alert(actions: [
                AlertButton("Save Changes", backgroundColor: Color.green, textColor: UIColor.white) {
                    self.save(nil)
                },
                AlertButton("Exit", backgroundColor: Color.red, textColor: UIColor.white) {
                    self.navigationController?.popViewController(animated: true)
                },
                AlertButton("Cancel", backgroundColor: Color.grey.0)
            ]).showWarning("Exit?", subTitle: "Any unsaved changes will be lost.")
            return false
        }
        return true
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        madeChanges = true
    }

    @IBAction func save(_ sender: Any?) {
        self.view.endEditing(true)
        if !madeChanges { return }
        
        let a = alert(actions: [AlertButton("OK")])
        if first.text!.isEmpty || last.text!.isEmpty {
            a.showWarning("Could not change name", subTitle: "Please enter a first and last name.")
        }
        self.view.isUserInteractionEnabled = false
        R.get("/scripts/User/change_name.php", parameters: ["fname": self.first.text!, "lname": self.last.text!, "user_id": User.current.id]) { json, error in
            self.view.isUserInteractionEnabled = true
            
            guard let j = json, !error, j["success"].boolValue else {
                a.showWarning("Could not change name", subTitle: "Please check your connection and try again.")
                return
            }
            
            User.current.name = (self.first.text!, self.last.text!)
            
            self.madeChanges = false
            a.showSuccess("Success", subTitle: "Your name has been changed.")
            
        }
    }

}

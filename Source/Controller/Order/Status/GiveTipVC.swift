//
//  GiveTipVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 13/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

protocol GiveTipDelegate: class {
    func tip(amount: Double, personType: Order.Person.PersonType)
}

class GiveTipVC: BaseVC {
    
    //MARK: - Properties
    
    weak var delegate: GiveTipDelegate!
    var person: Order.Person!
    var personType: Order.Person.PersonType!
    
    //MARK: - Outlets
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personDescription: UILabel!
    @IBOutlet weak var personName: UILabel!
    
    @IBOutlet weak var amountTwo: ActiveLargeButton!
    @IBOutlet weak var amountThree: ActiveLargeButton!
    @IBOutlet weak var amountFive: ActiveLargeButton!
    @IBOutlet weak var amountOther: LargeButton!
    
    @IBOutlet weak var sendTip: LargeButton!
    
    //MARK: - Actions
    
    
    @IBAction func close(_ sender: UIButton) {
        self.delegate.tip(amount: 0, personType: self.personType)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if person != nil {
            personName.text = person.name
            personDescription.text = person.type == .packer ? "Packed By:" : "Delivered By:"
        } else {
            personName.text = personType == .packer ? "Packer" : "Driver"
            personDescription.text = "To be packed by:"
        }
        
        
        amountTwo.delegate = self
        amountThree.delegate = self
        amountFive.delegate = self
        
        sendTip.action = {
            let tip = self.getAmount()
            if tip == 0 {
                return
            }
            
            self.delegate.tip(amount: tip, personType: self.personType)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Methods
    
    func getAmount() -> Double {
        if amountTwo.isActive {
            return 2.0
        } else if amountThree.isActive {
            return 3.0
        } else if amountFive.isActive {
            return 5.0
        } else {
            //Other amount
            return 0
        }
    }
    
}

extension GiveTipVC: ActiveLargeButtonDelegate {
    func didToggleActive(to active: Bool, sender: ActiveLargeButton) {
        if sender.tag != 2 {
            amountTwo.toggleActive(to: false, callDelegate: false, animated: false)
        }
        if sender.tag != 3 {
            amountThree.toggleActive(to: false, callDelegate: false, animated: false)
        }
        if sender.tag != 5 {
            amountFive.toggleActive(to: false, callDelegate: false, animated: false)
        }
    }
}

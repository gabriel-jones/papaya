//
//  StatusSupportVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 13/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class StatusSupportVC: BaseVC {
    //MARK: - Properties
    
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var callStore: LargeButton!
    @IBOutlet weak var help: LargeButton!
    @IBOutlet weak var faqs: LargeButton!
    @IBOutlet weak var contactUs: LargeButton!
    @IBOutlet weak var ok: LargeButton!
    
    //MARK: - Actions
    
    
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callStore.action = {
            
        }
        
        help.action = {
            
        }
        
        faqs.action = {
            
        }
        
        contactUs.action = {
            
        }
        
        ok.action = {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Methods
    
}

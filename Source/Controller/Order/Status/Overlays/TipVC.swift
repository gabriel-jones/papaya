//
//  TipVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 03/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class TipVC: UIViewController {
    //MARK: - Properties
    
    
    
    //MARK: - Outlets
    
    
    
    //MARK: - Actions
    
    
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    //MARK: - Methods
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}

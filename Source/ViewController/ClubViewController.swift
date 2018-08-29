//
//  ClubViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/2/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation

class ClubViewController: UIViewController {
    
    public var club: Club!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.getClub()
    }
    
    @objc private func getClub() {
        /*
        Request.shared.getClub { result in
            switch result {
            case .success(let club):
            case .failure(_):
                
            }
        }
         */
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
    }
    
    private func buildConstraints() {
        
    }
}

//
//  SettingsUserTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/28/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class SettingsUserTableViewCell: UITableViewCell {
    public static let identifer: String = C.ViewModel.CellIdentifier.settingsUserCell.rawValue
    
    public var user: User? {
        didSet {
            self.updateUser()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.buildViews()
        self.buildConstraints()
        
        self.updateUser()
    }
    
    private func buildViews() {
        self.imageView?.image = #imageLiteral(resourceName: "User Colored")
        
        self.accessoryType = .disclosureIndicator
        
        self.detailTextLabel?.textColor = .lightGray
        self.detailTextLabel?.font = Font.gotham(size: self.detailTextLabel!.font!.pointSize)
        
        self.textLabel?.font = Font.gotham(size: self.textLabel!.font!.pointSize)
    }
    
    private func buildConstraints() {
        
    }
    
    private func updateUser() {
        guard let user = self.user else {
            return
        }
        
        self.textLabel?.text = user.name
        self.detailTextLabel?.text = user.email
    }
}

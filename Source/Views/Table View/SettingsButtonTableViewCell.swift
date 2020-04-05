//
//  SettingsButtonTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

protocol SettingsButtonTableViewCellDelegate {
    func didSubmit()
}

class SettingsButtonTableViewCell: UITableViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.settingsButtonCell.rawValue
    public var delegate: SettingsButtonTableViewCellDelegate?
    
    private let button = LoadingButton()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func set(title: String) {
    }
    
    private func buildViews() {
        backgroundColor = .clear

        addSubview(button)
    }
    
    @objc func submit(_ sender: LoadingButton) {
        delegate?.didSubmit()
    }
    
    private func buildConstraints() {
    }

}

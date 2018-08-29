//
//  SettingsInputTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

extension UITextField {
    func setLeftPadding(points: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: points, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setRightPadding(points: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: points, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}

class SettingsInputTableViewCell: UITableViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.settingsInputCell.rawValue
    
    public let textField = JVFloatLabeledTextField()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {        
        textField.floatingLabelFont = Font.gotham(size: textField.floatingLabelFont.pointSize)
        textField.floatingLabelYPadding = 8
        textField.font = Font.gotham(size: 16)
        textField.tintColor = UIColor(named: .green)
        textField.setLeftPadding(points: 28)
        addSubview(textField)
    }
    
    private func buildConstraints() {
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

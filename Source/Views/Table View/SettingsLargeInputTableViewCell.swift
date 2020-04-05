//
//  SettingsInputTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class SettingsLargeInputTableViewCell: UITableViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.settingsLargeInputCell.rawValue
    
    public let textView = JVFloatLabeledTextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        textView.floatingLabelFont = Font.gotham(size: textView.floatingLabelFont.pointSize)
        textView.floatingLabelYPadding = 5
        textView.font = Font.gotham(size: 16)
        textView.tintColor = UIColor(named: .green)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 16)
        //textView.floatingLabelXPadding = 28
        textView.floatingLabel.font = Font.gotham(size: 12)
        textView.placeholderLabel.font = Font.gotham(size: 12)
        textView.placeholderTextColor = .gray
        addSubview(textView)
    }
    
    private func buildConstraints() {
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(-8)
            make.top.equalTo(8)
        }
    }
    
}


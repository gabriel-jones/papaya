//
//  EmptyTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/12/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

protocol EmptyTableViewCellDelegate: class {
    func tappedButton()
}

class EmptyTableViewCell: UITableViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.emptyCell.rawValue
    
    public var delegate: EmptyTableViewCellDelegate?
    
    public let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    private let button = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var emptyText: String? {
        get {
            return emptyLabel.text
        }
        set {
            emptyLabel.text = newValue
        }
    }
    
    public var buttonText: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }
    
    public var img: UIImage? {
        get {
            return emptyImageView.image
        }
        set {
            emptyImageView.image = newValue?.tintable
        }
    }
    
    private func buildViews() {
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0)
        
        emptyImageView.tintColor = UIColor(named: .green)
        addSubview(emptyImageView)
        
        emptyLabel.font = Font.gotham(size: 17)
        emptyLabel.textAlignment = .center
        addSubview(emptyLabel)
        
        button.setTitleColor(UIColor(named: .green), for: .normal)
        button.titleLabel?.font = Font.gotham(size: 16)
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(named: .green).cgColor
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(tapAddItemsButton(_:)), for: .touchUpInside)
        addSubview(button)
    }
    
    @objc private func tapAddItemsButton(_ sender: UIButton) {
        self.delegate?.tappedButton()
    }
    
    private func buildConstraints() {
        emptyImageView.snp.makeConstraints { make in
            make.top.equalTo(75)
            make.height.width.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalTo(emptyImageView.snp.centerX)
            make.top.equalTo(emptyImageView.snp.bottom).offset(18)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(emptyLabel.snp.centerX)
            make.top.equalTo(emptyLabel.snp.bottom).offset(24)
        }
    }
}

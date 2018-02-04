//
//  ItemActionTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/6/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

extension UIButton {
    func alignVertical(spacing: CGFloat = 6.0) {
        guard let imageSize = self.imageView?.image?.size,
            let text = self.titleLabel?.text,
            let font = self.titleLabel?.font
            else { return }
        self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedStringKey.font: font])
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        self.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
    }
}

class ItemActionTableViewCell: UITableViewCell {

    public static let identifier: String = C.ViewModel.CellIdentifier.itemActionCell.rawValue
    
    public var delegate: ItemActionDelegate?
    private var hasLoaded = false
    
    public enum ItemActions {
        case like, liked, addToList, rate, instructions
        
        public var descriptor: (String, UIImage) {
            get {
                switch self {
                case .like:
                    return ("Like", #imageLiteral(resourceName: "Heart Outline").tintable)
                case .liked:
                    return ("Liked", #imageLiteral(resourceName: "Heart").tintable)
                case .addToList:
                    return ("Add to List", #imageLiteral(resourceName: "Plus").tintable)
                case .instructions:
                    return ("Instructions", #imageLiteral(resourceName: "Note").tintable)
                default:
                    return (String(), UIImage())
                }
            }
        }
    }
        
    private let stack = UIStackView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func load(actions: [ItemActions]) {
        if hasLoaded {
            return
        }
        hasLoaded = true
        for action in actions {
            let button = self.buildActionView()
            button.setTitle(action.descriptor.0, for: .normal)
            button.setImage(action.descriptor.1, for: .normal)
            stack.addArrangedSubview(button)
        }
    }
    
    private func buildActionView() -> UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor(named: .green), for: .normal)
        button.titleLabel?.font = Font.gotham(size: 16)
        button.imageView?.tintColor = UIColor(named: .green)
        button.addTarget(self, action: #selector(startHighlight(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(endHighlight(_:)), for: .touchCancel)
        button.addTarget(self, action: #selector(endHighlight(_:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.alignVertical()
        //button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return button
    }
    
    private func buildViews() {
        masksToBounds = true
        
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        
        addSubview(stack)
    }
    
    private func buildConstraints() {
        stack.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(4)
            make.bottom.equalTo(-4)
        }
    }

    @objc private func startHighlight(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            sender.backgroundColor = UIColor(named: .backgroundGrey)
        }
    }
    
    @objc private func endHighlight(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            sender.backgroundColor = .clear
        }
    }
    
    @objc private func like(_ sender: UIButton) {
        endHighlight(sender)
    }
    
    @objc private func addToList(_ sender: UIButton) {
        endHighlight(sender)
    }
}

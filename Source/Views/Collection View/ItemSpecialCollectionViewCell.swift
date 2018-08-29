//
//  ItemSpecialCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/3/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import TagListView

class ItemSpecialCollectionViewCell: UICollectionViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.specialItemCell.rawValue
    
    public var delegate: TagListViewDelegate?
    
    private let countryFlag = UIImageView()
    private let countryName = UILabel()
    private var itemImage = UIImageView()
    private let itemName = UILabel()
    private let itemDescription = TopAlignedLabel()
    private let tagView = TagListView()
    
    private var countryTemplate: UIView!
    private var nameTemplate: UIView!
    private var desc1Template: UIView!
    private var desc2Template: UIView!
    private var desc3Template: UIView!
    private var desc4Template: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildTemplate() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.alpha = 0.6
        view.isHidden = true
        return view
    }
    
    private func buildViews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        masksToBounds = false
        
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        
        countryFlag.contentMode = .scaleAspectFit
        countryFlag.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        countryFlag.tintColor = .gray
        addSubview(countryFlag)
        
        countryName.text = "American"
        countryName.font = Font.gotham(size: 11)
        addSubview(countryName)
        
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        itemImage.tintColor = .gray
        addSubview(itemImage)
        
        itemName.font = Font.gotham(weight: .bold, size: 17)
        itemName.numberOfLines = 0
        addSubview(itemName)
        
        itemDescription.font = Font.gotham(size: 10)
        itemDescription.numberOfLines = 0
        itemDescription.textColor = .gray
        itemDescription.lineBreakMode = .byTruncatingTail
        addSubview(itemDescription)
        
        tagView.alignment = .left
        tagView.enableRemoveButton = false
        tagView.paddingX = 8
        tagView.paddingY = 8
        tagView.textFont = Font.gotham(size: 9)
        tagView.textColor = UIColorFromRGB(0x616161)
        addSubview(tagView)
        
        countryTemplate = buildTemplate()
        countryName.addSubview(countryTemplate)
        
        nameTemplate = buildTemplate()
        itemName.addSubview(nameTemplate)
        
        desc1Template = buildTemplate()
        itemDescription.addSubview(desc1Template)
        
        desc2Template = buildTemplate()
        itemDescription.addSubview(desc2Template)
        
        desc3Template = buildTemplate()
        itemDescription.addSubview(desc3Template)
        
        desc4Template = buildTemplate()
        itemDescription.addSubview(desc4Template)
    }
    
    private func buildConstraints() {
        countryFlag.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalTo(8)
            make.left.equalTo(12)
        }
        
        countryName.snp.makeConstraints { make in
            make.left.equalTo(countryFlag.snp.right).offset(4)
            make.centerY.equalTo(countryFlag.snp.centerY)
        }
        
        itemImage.snp.makeConstraints { make in
            make.top.equalTo(countryFlag.snp.bottom).offset(2)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalToSuperview().dividedBy(2.5)
        }
        
        itemName.snp.makeConstraints { make in
            make.top.equalTo(itemImage.snp.bottom).offset(8)
            make.left.equalTo(16)
            make.right.equalTo(-8)
        }
        
        itemDescription.snp.makeConstraints { make in
            make.top.equalTo(itemName.snp.bottom).offset(4)
            make.left.equalTo(16)
            make.right.equalTo(-8)
            //make.bottom.equalTo(tagView.snp.top).offset(-8)
        }
        
        tagView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-8)
            make.bottom.equalTo(-8)
        }
        
        nameTemplate.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalToSuperview().multipliedBy(CGFloat(2.0/5.0))
        }
        
        desc1Template.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalTo(nameTemplate.snp.bottom).offset(10)
            make.height.equalTo(16)
            make.width.equalToSuperview().multipliedBy(CGFloat(6.0/10.0))
        }
        
        desc2Template.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalTo(desc1Template.snp.bottom).offset(6)
            make.height.equalTo(desc1Template.snp.height)
            make.width.equalToSuperview().multipliedBy(CGFloat(8.0/10.0))
        }
        
        desc3Template.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalTo(desc2Template.snp.bottom).offset(6)
            make.height.equalTo(desc1Template.snp.height)
            make.width.equalToSuperview().multipliedBy(CGFloat(3.0/10.0))
        }
        
        desc4Template.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalTo(desc3Template.snp.bottom).offset(6)
            make.height.equalTo(desc1Template.snp.height)
            make.width.equalToSuperview().multipliedBy(CGFloat(5.0/10.0))
        }
    }
    
    private func createTagViews(with: [Tag]) -> [TagView] {
        return with.map {
            let v = TagView(title: $0.name)
            v.tagBackgroundColor = UIColorFromRGB(0xEDEDED)
            v.cornerRadius = 5
            v.textColor = UIColorFromRGB(0x616161)
            return v
        }
    }
    
    public func load(item: SpecialItem) {
        nameTemplate.layer.removeAllAnimations()
        nameTemplate.isHidden = true
        desc1Template.isHidden = true
        desc2Template.isHidden = true
        desc3Template.isHidden = true
        desc4Template.isHidden = true
        tagView.removeAllTags()

        countryName.text = item.countryOfOrigin?.name

        if let text = item.countryOfOrigin?.flagEmoji {
            let attributes = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 19)
            ]
            let textSize = text.size(withAttributes: attributes)
            
            let renderer = UIGraphicsImageRenderer(size: textSize)
            let image = renderer.image(actions: { context in
                text.draw(at: .zero, withAttributes: attributes)
            })
            countryFlag.image = image
        }

        itemName.text = item.name
        itemDescription.text = item.description
        tagView.addTagViews(createTagViews(with: item.tags))
        tagView.paddingX = 8
        tagView.paddingY = 8
        tagView.marginX = 4
        tagView.marginY = 4
        tagView.textFont = Font.gotham(size: 9)
        tagView.textColor = UIColorFromRGB(0x616161)
        
        if let url = item.img {
            itemImage.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "Picture").tintable) { result in
                self.setImageTemplate(result.error != nil)
            }
            
            itemImage.heroID = self.getImageId()
        }
    }
    
    private func setImageTemplate(_ to: Bool) {
        itemImage.contentMode = to ? .center : .scaleAspectFit
        itemImage.backgroundColor = to ? UIColor(named: .backgroundGrey) : .clear
        itemImage.layer.cornerRadius = to ? 10 : 0
    }
    
    public func setIsTemplate(_ isTemplate: Bool, hasImage: Bool = false) {
        if isTemplate && !hasImage {
            itemImage.image = nil
            itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
            self.setImageTemplate(true)
        } else {
            self.setImageTemplate(false)
        }
        
        if isTemplate {
            countryName.text = " "
            itemName.text = " "
            itemDescription.text = " "
            tagView.removeAllTags()
        }
        
        countryTemplate.isHidden = !isHidden
        nameTemplate.isHidden = !isTemplate
        desc1Template.isHidden = !isTemplate
        desc2Template.isHidden = !isTemplate
        desc3Template.isHidden = !isTemplate
        desc4Template.isHidden = !isTemplate
        
        if isTemplate {
            DispatchQueue.main.async {
                self.layoutSubviews()
                UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                    self.countryTemplate.alpha = 0.3
                    self.nameTemplate.alpha = 0.3
                    self.desc1Template.alpha = 0.3
                    self.desc2Template.alpha = 0.3
                    self.desc3Template.alpha = 0.3
                    self.desc4Template.alpha = 0.3
                }, completion: nil)
            }
        }
    }
    
    override func layoutSubviews() {
        countryTemplate.layer.cornerRadius = countryTemplate.frame.height / 2
        nameTemplate.layer.cornerRadius = nameTemplate.frame.height / 2
        desc1Template.layer.cornerRadius = desc1Template.frame.height / 2
        desc2Template.layer.cornerRadius = desc2Template.frame.height / 2
        desc3Template.layer.cornerRadius = desc3Template.frame.height / 2
        desc4Template.layer.cornerRadius = desc4Template.frame.height / 2
    }
    
    public func getImageId() -> String {
        return withUnsafePointer(to: &itemImage) {
            "item_img_" + $0.debugDescription
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

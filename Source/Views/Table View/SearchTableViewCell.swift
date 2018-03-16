//
//  SearchTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/4/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.searchRecommendCell.rawValue
    
    private let searchImage = UIImageView()
    private let searchWord = UILabel()
    private let nameTemplate = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        separatorInset.left = 0
        accessoryType = .disclosureIndicator

        nameTemplate.backgroundColor = .lightGray
        nameTemplate.alpha = 0.6
        nameTemplate.isHidden = true
        addSubview(nameTemplate)
        
        searchWord.font = Font.gotham(size: 15)
        addSubview(searchWord)
                
        searchImage.image = #imageLiteral(resourceName: "Search").tintable
        searchImage.tintColor = UIColor.darkGray
        addSubview(searchImage)
    }
    
    private func buildConstraints() {
        searchImage.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview().offset(8)
            make.topMargin.equalToSuperview().offset(8)
            make.bottomMargin.equalToSuperview().offset(-8)
            make.width.equalTo(searchImage.snp.height)
        }
        
        searchWord.snp.makeConstraints { make in
            make.left.equalTo(searchImage.snp.right).offset(8)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        nameTemplate.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview().offset(44)
            make.top.equalTo(12)
            make.bottom.equalTo(-12)
            make.width.equalToSuperview().multipliedBy(CGFloat(1.5/5.0))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameTemplate.layer.cornerRadius = nameTemplate.frame.height / 2
    }
    
    public func loadTemplate() {
        searchWord.text = ""
        nameTemplate.isHidden = false
        DispatchQueue.main.async {
            self.layoutSubviews()
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.nameTemplate.alpha = 0.3
            }, completion: nil)
        }
    }
    
    public func load(search: String) {
        searchWord.text = search
        nameTemplate.layer.removeAllAnimations()
        nameTemplate.removeFromSuperview()
    }
    
    
}

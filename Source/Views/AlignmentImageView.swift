//
//  AlignmentImageView.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/2/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
/*
class MyImageView: UIImageView {
    private let _imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        let _imageView = UIImageView(frame: self.bounds)
        _imageView.contentMode = .scaleAspectFill
        addSubview(_imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        let _imageView = UIImageView(frame: self.bounds)
        _imageView.contentMode = .scaleAspectFill
        addSubview(_imageView)
    }
    
    override init(image: UIImage?) {
        super.init(frame: .zero)
        self.clipsToBounds = true
        let _imageView = UIImageView(frame: self.bounds)
        _imageView.image = image
        _imageView.contentMode = .scaleAspectFill
        _imageView.sizeToFit()
        self.frame = _imageView.frame
    }
    
    override func layoutSubviews() {
        
        guard let image = image else {
            return
        }
        
        // compute scale factor for imageView
        let widthScaleFactor: CGFloat = self.bounds.width / image.size.width
        let heightScaleFactor: CGFloat = self.bounds.height / image.size.height
        
        var imageViewXOrigin: CGFloat = 0
        var imageViewYOrigin: CGFloat = 0
        var imageViewWidth: CGFloat = 0
        var imageViewHeight: CGFloat = 0
        
        
        // if image is narrow and tall, scale to width and align vertically to the top
        if (widthScaleFactor > heightScaleFactor) {
            imageViewWidth = image.size.width * widthScaleFactor
            imageViewHeight = image.size.height * widthScaleFactor
        }
            
        else {
            imageViewWidth = image.size.width * heightScaleFactor
            imageViewHeight = image.size.height * heightScaleFactor
            imageViewXOrigin = -(imageViewWidth - self.bounds.width) / 2
        }
        
        _imageView.frame = CGRect(x: imageViewXOrigin, y: imageViewYOrigin, width: imageViewWidth, height: imageViewHeight);
    }
    
    override var image: UIImage? {
        didSet {
            _imageView.image = image
            self.setNeedsLayout()
        }
    }
}
 */

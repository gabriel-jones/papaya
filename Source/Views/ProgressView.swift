//
//  ProgressView.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/19/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    public var progressColorOne: UIColor = UIColorFromRGB(0x00D44D)
    public var progressColorTwo: UIColor = UIColorFromRGB(0x57E1B6)
    
    private let progress = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        progress.frame = CGRect(x: 0, y: 0, width: 0, height: frame.height)
        progress.backgroundColor = progressColorOne
        progress.gradientBackground(colors: [progressColorOne, progressColorTwo], position: (.left, .right))
        addSubview(progress)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progress.gradientBackground(colors: [progressColorOne, progressColorTwo], position: (.left, .right))
    }
    
    public func setProgress(_ to: Float, animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.progress.frame = CGRect(x: 0, y: 0, width: self.frame.width * CGFloat(to), height: self.frame.height)
        })
    }
    
}

class InfiniteProgressView: UIView {
    
    public var progressColorOne: UIColor = UIColorFromRGB(0x00D44D)
    public var progressColorTwo: UIColor = UIColorFromRGB(0x57E1B6)
    
    private let progress = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        
        progress.fillColor = nil
        progress.strokeColor = progressColorOne.cgColor
        progress.lineWidth = frame.height
        progress.lineCap = kCALineCapRound
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: frame.height / 2))
        path.addLine(to: CGPoint(x: frame.width / 6, y: frame.height / 2))
        progress.path = path.cgPath
        
        layer.addSublayer(progress)
    }
    
    public func startAnimating() {
        stopAnimating()
        
        let group = CAAnimationGroup()
        group.duration = 4
        group.repeatCount = .infinity
        
        let positionAnimation = CABasicAnimation(keyPath: "position.x")
        positionAnimation.fromValue = -(frame.width / 6)
        positionAnimation.toValue = frame.width + (frame.width / 12)
        positionAnimation.duration = 2.0
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.repeatCount = .infinity
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0.2
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = 1.0
        strokeAnimation.repeatCount = .infinity
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        strokeAnimation.autoreverses = true
        
        group.animations = [positionAnimation, strokeAnimation]
        progress.add(group, forKey: "stretchMove")
    }
    
    public func stopAnimating() {
        progress.removeAllAnimations()
    }
}

//
//  StepProgressView.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/19/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class StepProgressView: UIView {
    
    public var trackColor: UIColor = UIColorFromRGB(0xDADADA)
    public var labelColor: UIColor = UIColorFromRGB(0xB6B6B6)
    public var progressColor: UIColor = UIColorFromRGB(0x00D44D)
    
    private let pointRadius: CGFloat = 7.5
    
    private var progressIndex: Int = 0
    private var animateProgress: Bool = false
    private var fractionalProgress: Float = 0
    
    public var labelFont: UIFont = UIFont.boldSystemFont(ofSize: 12)
    
    private let lineLayer = CAShapeLayer()
    
    public var points = [String]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        layer.addSublayer(lineLayer)
        self.setNeedsDisplay()
    }
    
    public func setProgress(_ index: Int, animated: Bool, fractional: Float = 0) {
        self.progressIndex = index
        self.animateProgress = animated
        self.fractionalProgress = fractional
        
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        
        lineLayer.removeAllAnimations()
        subviews.forEach { $0.removeFromSuperview() }
        context.clear(rect)
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        let w: CGFloat = frame.width,
            h: CGFloat = frame.height,
            midY: CGFloat = h / 2,
            labelMargin: CGFloat = 12,
            labelBottomOffset: CGFloat = labelMargin,
            stepWidth = (w - pointRadius * 2) / CGFloat(points.count - 1)
        
        // Draw track
        context.setStrokeColor(trackColor.cgColor)
        context.setLineWidth(4)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: pointRadius, y: midY - labelBottomOffset))
        context.addLine(to: CGPoint(x: w - pointRadius, y: midY - labelBottomOffset))
        context.strokePath()
        
        // Draw progress
        lineLayer.strokeColor = progressColor.cgColor
        lineLayer.lineCap = kCALineCapRound
        lineLayer.lineWidth = 4
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: pointRadius, y: midY - labelBottomOffset))
        let progressX = (CGFloat(progressIndex) * stepWidth) + (CGFloat(fractionalProgress) * stepWidth)
        linePath.addLine(to: CGPoint(x: max(pointRadius, min(progressX, CGFloat(points.count - 1) * stepWidth)), y: midY - labelBottomOffset))
        
        if animateProgress {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = 0.3
            animation.fromValue = lineLayer.path
            animation.toValue = linePath.cgPath
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.isRemovedOnCompletion = true
            lineLayer.add(animation, forKey: nil)
        }
        
        lineLayer.path = linePath.cgPath
        lineLayer.isHidden = progressIndex == -1
        
        // Points
        for (index, point) in points.enumerated() {
            // Add circles
            context.setFillColor(index <= progressIndex ? progressColor.cgColor : trackColor.cgColor)
            let pointRect = CGRect(x: CGFloat(index) * stepWidth, y: midY - labelBottomOffset - pointRadius, width: pointRadius * 2, height: pointRadius * 2)
            context.addEllipse(in: pointRect)
            context.drawPath(using: .fill)
            
            // Add labels
            let labelY: CGFloat = pointRect.maxY + labelMargin
            let label = UILabel()
            label.font = labelFont
            label.text = point
            label.textColor = index <= progressIndex ? progressColor : labelColor
            label.sizeToFit()
            switch index {
            case 0:
                label.textAlignment = .left
                label.frame.origin = CGPoint(x: 0, y: labelY - label.frame.height / 2)
            case points.count - 1:
                label.textAlignment = .right
                label.frame.origin = CGPoint(x: w - label.frame.width, y: labelY - label.frame.height / 2)
            default:
                label.textAlignment = .center
                label.center = CGPoint(x: pointRect.midX, y: labelY)
            }
            addSubview(label)
        }
    }
}

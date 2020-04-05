//
//  LoadingView.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/19/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    public var color: UIColor = .black
    public var hidesWhenStopped = true
    private var _isAnimating = false
    public var lineWidth: CGFloat = 3.5
    public var isAnimating: Bool {
        get {
            return _isAnimating
        }
    }
    
    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !_isAnimating {
            isHidden = true
        }
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = self.lineWidth
        layer.lineCap = kCALineCapRound
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }
    
    private struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
    private class var poses: [Pose] {
        get {
            return [
                Pose(0.0, 0.000, 0.7),
                Pose(0.4, 0.500, 0.5),
                Pose(0.4, 1.000, 0.3),
                Pose(0.4, 1.500, 0.1),
                Pose(0.4, 1.875, 0.1),
                Pose(0.4, 2.250, 0.3),
                Pose(0.4, 2.625, 0.5),
                Pose(0.4, 3.000, 0.7),
            ]
        }
    }
    
    public func startAnimating() {
        _isAnimating = true
        layer.removeAllAnimations()
        isHidden = false
        
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = type(of: self).poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }
        
        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
    }
    
    public func stopAnimating() {
        _isAnimating = false
        layer.removeAllAnimations()
        if hidesWhenStopped {
            isHidden = true
        }
    }
    
    private func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = kCAAnimationLinear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
}

//
//  DrawView.swift
//  PrePacked and TimeSheets
//
//  Created by Gabriel Jones on 2/10/15.
//  Copyright (c) 2015 Gabriel Jones. All rights reserved.
//

import UIKit

protocol DrawViewDelegate {
    func didDraw()
}

class DrawView: UIView {
    
    var hasContent = false
    var delegate: DrawViewDelegate?
    
    class Line {
        
        var start: CGPoint
        var end: CGPoint
        
        init(start _start: CGPoint, end _end: CGPoint ) {
            start = _start
            end = _end
            
        }
    }
    
    private var lines: [Line] = []
    private var lastPoint: CGPoint!
    
    var signature = UIImage()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func clear() {
        self.hasContent = false
        self.lines = []
        self.setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstThing = touches.first!
        lastPoint = firstThing.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hasContent = true
        let firstThing = touches.first!
        let newPoint = firstThing.location(in: self)
        lines.append(Line(start: lastPoint, end: newPoint))
        lastPoint = newPoint
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.beginPath()
        context.setLineCap(.round)
        for line in lines {
            context.move(to: CGPoint(x: line.start.x, y: line.start.y))
            context.addLine(to: CGPoint(x: line.end.x, y: line.end.y))
        }
        context.setStrokeColor(Color.grey.1.cgColor)
        context.setLineWidth(1)
        context.strokePath()
        self.delegate?.didDraw()
    }
    
    func displayImage(img: UIImage) {
        let imgView = UIImageView(frame: self.bounds)
        imgView.image = img
        self.addSubview(imgView)
    }
    
    func save() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        self.signature = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
}

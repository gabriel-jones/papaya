import UIKit

protocol CheckboxDelegate {
    func changed(_ state: Checkbox.State)
}

class Checkbox: UIView {
    //in the aaarms
    var tint: UIColor! = UIColor.green {
        didSet {
            tickLayer.fillColor = self.tint.cgColor
            tickLayer.strokeColor = self.tint.cgColor
        }
    }
    
    var boxColor: UIColor! = UIColor.gray {
        didSet {
            box.layer.borderColor = boxColor.cgColor
        }
    }
    
    func setState(_ state: State) {
        self.state = state
    }
    
    fileprivate var state: State! = .off
    fileprivate var tickLayer: CAShapeLayer!
    fileprivate var box: UIView!
    
    var delegate: CheckboxDelegate!
    
    enum State { case on; case off }
    
    func getState() -> State {
        return self.state
    }
    
    func draw() {
        
        self.backgroundColor = UIColor.clear
        
        let s = self.frame.size.width
        box = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: s/2, height: s/2)))
        box.center = self.center
        box.layer.borderWidth = (s/2)/12.5
        box.layer.cornerRadius = s/10
        box.layer.borderColor = self.boxColor.cgColor
        box.layoutIfNeeded()
        self.addSubview(box)
        
        let p = box.frame.origin
        let w = box.frame.width
        let h = box.frame.height
        let path = UIBezierPath()
        path.move(to: CGPoint(x: p.x+w/5, y: p.y+h/3.5))
        path.addLine(to: CGPoint(x: p.x+w/1.8, y: p.y+h/1.6 ))
        path.move(to: CGPoint(x: (p.x+w/1.8)-(w/20), y: p.y+h/1.6 ))
        path.addLine(to: CGPoint(x: p.x+w*1.2, y: p.y-h/4))
        tickLayer = CAShapeLayer()
        tickLayer.path = path.cgPath
        tickLayer.lineWidth = (s/2)/12.5
        tickLayer.opacity = 0.0
        tickLayer.fillColor = self.tintColor.cgColor
        tickLayer.strokeColor = self.tintColor.cgColor
        self.layer.addSublayer(tickLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.draw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.draw()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 0.7
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 1.0
        for touch in touches {
            if self.point(inside: touch.location(in: self), with: event) {
                self.toggle()
            }
        }
    }
    
    func toggle() {
        if self.delegate != nil {
            delegate.changed(self.getState())
        }
        
        if state == .on {
            state = .off
            tickLayer.opacity = 0.0
        } else {
            state = .on
            tickLayer.opacity = 1.0
            let a = CABasicAnimation(keyPath: "strokeEnd")
            a.duration = 0.25
            a.fromValue = 0.0
            a.toValue = 1.0
            self.tickLayer.add(a, forKey: "path")
            
        }
    }
}

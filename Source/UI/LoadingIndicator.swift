import UIKit

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Float.pi * 2.0)
        rotateAnimation.duration = duration
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

class LoadingIndicator: UIView {
    var colors: [UIColor] = [
        Color.yellow,
        Color.yellow,
        Color.yellow,
    ]
    
    private var bulgeTimer: Timer!
    private var rotateTimer: Timer!
    
    private var circles = [UIView]()
    
    override init(frame: CGRect) {
        print("init form frame")
        super.init(frame: frame)
        self.initialise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("init from coder")
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    func startAnimating() {
        print("start animating")
        bulgeTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.animate()
        }
        bulgeTimer.fire()
        
        rotateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.rotate360Degrees(duration: 2.0)
        }
        rotateTimer.fire()
    }
    
    func stopAnimating() {
        bulgeTimer.invalidate()
        rotateTimer.invalidate()
    }
    
    private func animate() {
        let w = frame.width, h = frame.height
        UIView.animate(withDuration: 0.15, animations: {
            for x in 0..<3 {
                //self.circles[x].alpha = 0.9
                self.circles[x].transform = CGAffineTransform(translationX: [0, w / 25, w / -25][x], y: [h / 25, h / -25, h / -25][x])
            }
        }) { _ in
            UIView.animate(withDuration: 0.4, animations: {
                for x in 0..<3 {
                    //self.circles[x].alpha = 1.0
                    self.circles[x].transform = CGAffineTransform(translationX: [0, w / -4, w / 4][x], y: [h / -4, h / 4, h / 4][x])
                }
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 0.2, options: [], animations: {
                    for x in 0..<3 {
                        self.circles[x].transform = CGAffineTransform.identity
                    }
                })
            }
        }
    }
    
    func initialise() {
        print("init")
        clipsToBounds = false
        
        let w = frame.width
        let h = frame.height
        
        let size: CGFloat = w / 4
        
        let circlePositions: [CGPoint] = [
            CGPoint(x: center.x, y: center.y - size/2),
            CGPoint(x: center.x - size/2, y: center.y + size/2 - h / 25),
            CGPoint(x: center.x + size/2, y: center.y + size/2 - h / 25)
        ]
        for x in 0..<3 {
            circles.append(UIView(frame: CGRect(x: 0, y: 0, width: size, height: size)))
            circles[x].center = circlePositions[x]
            circles[x].backgroundColor = colors[x]
            circles[x].layer.cornerRadius = size / 2
            addSubview(circles[x])
            
        }
    }
}

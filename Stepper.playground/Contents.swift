//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

class Stepper: UIView {
    public var max = 100
    public var min = 1
    public var value = 1
    
    private let valueLabel = UILabel()
    private let decreaseButton = UIButton()
    private let increaseButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func build() {
        layer.cornerRadius = 5
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        
        decreaseButton.setTitle("-", for: .normal)
        decreaseButton.setTitleColor(UIColor.green, for: .normal)
        decreaseButton.addTarget(self, action: #selector(decrease(_:)), for: .touchUpInside)
        addSubview(decreaseButton)
        
        increaseButton.setTitle("+", for: .normal)
        increaseButton.setTitleColor(UIColor.green, for: .normal)
        increaseButton.addTarget(self, action: #selector(increase(_:)), for: .touchUpInside)
        addSubview(increaseButton)
        
        valueLabel.text = String(value)
        valueLabel.textAlignment = .center
        addSubview(valueLabel)
    }
    
    @objc func decrease(_ sender: UIButton) {
        
    }
    
    @objc func increase(_ sender: UIButton) {
        
    }
    
}

let stp = Stepper()
PlaygroundPage.current.liveView = stp

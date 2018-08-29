//
//  SignupExpressViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/10/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

fileprivate func createBenefitView(benefit: NSAttributedString) -> UIView {
    let container = UIView()
    let view = UIView()
    
    let image = UIImageView()
    image.tintColor = UIColorFromRGB(0x00a745)
    image.image = #imageLiteral(resourceName: "Check").tintable
    view.addSubview(image)
    
    image.snp.makeConstraints { make in
        make.left.equalToSuperview().inset(12)
        make.top.equalToSuperview()
        make.width.height.equalTo(25)
    }
    
    let label = UILabel()
    label.attributedText = benefit
    label.font = Font.gotham(size: 17)
    label.textColor = UIColorFromRGB(0x696969)
    label.numberOfLines = 0
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
        make.left.equalTo(image.snp.right).offset(16)
        make.bottom.right.equalToSuperview()
        make.centerY.equalTo(image.snp.centerY)
    }
    
    container.addSubview(view)
    
    view.snp.makeConstraints { make in
        make.left.right.equalToSuperview()
        make.top.bottom.equalToSuperview().inset(12)
    }
    
    return container
}

class ExpressViewController: UIViewController {
    
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    
    private let benefits = [
        "Free deliveries *",
        "Schedule orders up to a week in advance",
        "No surge pricing during peak hours",
        "Priority order status"
    ]
    
    private let selectPlanContainer = UIView()
    private let selectPlanLabel = UILabel()
    
    private let annualPlanView = ExpressPlanView()
    private let monthlyPlanView = ExpressPlanView()
    
    private let disclaimerContainer = UIView()
    private let disclaimerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = .white
        
        navigationItem.title = "Papaya Express"
        navigationItem.largeTitleDisplayMode = .always
        
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)
        
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.axis = .vertical
        scroll.addSubview(stack)

        for benefit in benefits {
            let benefitString = NSMutableAttributedString(string: benefit)
            let benefitView = createBenefitView(benefit: benefitString)
            stack.addArrangedSubview(benefitView)
        }
        
        selectPlanLabel.text = "Select a Plan"
        selectPlanLabel.font = Font.gotham(weight: .bold, size: 26)
        selectPlanContainer.addSubview(selectPlanLabel)
        stack.addArrangedSubview(selectPlanContainer)
        
        annualPlanView.image = #imageLiteral(resourceName: "PremiumAnnualPlan")
        annualPlanView.amount = 12.99
        annualPlanView.savings = "Save 35%"
        annualPlanView.subtitle = "Our most popular and cheapest plan. Billed annually. Cancel anytime."
        stack.addArrangedSubview(annualPlanView)
        stack.setCustomSpacing(25, after: annualPlanView)
        
        monthlyPlanView.image = #imageLiteral(resourceName: "PremiumMonthlyPlan")
        monthlyPlanView.amount = 19.99
        monthlyPlanView.subtitle = "Billed monthly. Cancel anytime."
        stack.addArrangedSubview(monthlyPlanView)
        
        disclaimerLabel.text = "* Free deliveries only for orders over $20"
        disclaimerLabel.font = Font.gotham(size: 12)
        disclaimerLabel.textColor = UIColorFromRGB(0xA7A7A7)
        disclaimerContainer.addSubview(disclaimerLabel)
        stack.addArrangedSubview(disclaimerContainer)
    }
    
    private func buildConstraints() {
        scroll.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(32)
        }
        
        selectPlanLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(75)
            make.bottom.equalToSuperview().inset(24)
        }
        
        disclaimerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(50)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

class ExpressPlanView: UIView {
    public var image: UIImage? {
        didSet {
            imageBackgroundView.image = image?.alpha(0.65)
        }
    }
    public var subtitle: String? {
        didSet {
            descriptionLabel.text = subtitle
        }
    }
    public var savings: String? {
        didSet {
            savingsContainer.isHidden = savings == nil
            if let savings = self.savings {
                let savingsAttributed = NSMutableAttributedString(string: savings)
                savingsAttributed.addAttribute(.font, value: Font.gotham(weight: .bold, size: 12), range: NSMakeRange(savings.count - 2, 1))
                savingsLabel.attributedText = savingsAttributed
            }
        }
    }
    public var amount: Double? {
        didSet {
            priceLabel.text = (self.amount ?? 0).currencyFormat
        }
    }
    
    private let imageBackgroundView = UIImageView()
    private let containerView = UIView()
    private let priceLabel = UILabel()
    private let priceIntervalLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let savingsLabel = UILabel()
    private let savingsContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        masksToBounds = false
        clipsToBounds = false
        
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 20
        
        imageBackgroundView.masksToBounds = true
        imageBackgroundView.clipsToBounds = true
        imageBackgroundView.layer.cornerRadius = 10
        addSubview(imageBackgroundView)
        
        imageBackgroundView.addSubview(containerView)
        
        priceLabel.textColor = .white
        priceLabel.font = Font.gotham(weight: .bold, size: 44)
        containerView.addSubview(priceLabel)
        
        priceIntervalLabel.textColor = .white
        priceIntervalLabel.font = Font.gotham(size: 20)
        priceIntervalLabel.text = "/month"
        containerView.addSubview(priceIntervalLabel)
        
        descriptionLabel.textColor = UIColorFromRGB(0xEBEBEB)
        descriptionLabel.font = Font.gotham(size: 12)
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
        savingsLabel.textAlignment = .center
        savingsLabel.textColor = .white
        savingsLabel.font = Font.gotham(size: 12)
        savingsContainer.addSubview(savingsLabel)
        
        savingsContainer.backgroundColor = .black
        containerView.addSubview(savingsContainer)
    }
    
    private func buildConstraints() {
        imageBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.left.equalTo(25)
        }
        
        priceIntervalLabel.snp.makeConstraints { make in
            make.lastBaseline.equalTo(priceLabel.snp.lastBaseline)
            make.left.equalTo(priceLabel.snp.right).offset(12)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.left).offset(10)
            make.top.equalTo(priceLabel.snp.bottom).offset(24)
            make.right.equalToSuperview().inset(50)
            make.bottom.equalToSuperview().inset(32)
        }
        
        savingsContainer.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalToSuperview().inset(24)
        }
        
        savingsLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.gradientBackground(colors: [UIColorFromRGB(0x6216C2), UIColorFromRGB(0x75158D)], position: (.bottomLeft, .topRight), opacity: 0.85)
        savingsContainer.layer.cornerRadius = savingsContainer.frame.height / 2
    }
}

extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

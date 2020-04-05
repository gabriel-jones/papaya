//
//  ExpressBuyViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/31/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation

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
    label.font = Font.gotham(size: 17)
    label.attributedText = benefit
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
        make.top.bottom.equalToSuperview().inset(8)
    }
    
    return container
}

func makeAttributedStringFromFormatted(_ str: String, boldFont: UIFont) -> NSMutableAttributedString {
    let attr = NSMutableAttributedString(string: str.replacingOccurrences(of: "**", with: ""))
    let comps = str.components(separatedBy: "**")
    var isBold = false
    var index = 0
    for comp in comps {
        if isBold {
            attr.addAttribute(.font, value: boldFont, range: NSMakeRange(index, comp.count))
        }
        index += comp.count
        isBold = !isBold
    }
    return attr
}

class ExpressBuyViewController: UIViewController {
        
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    
    private let titleView = UIView()
    private let titleLabel = UILabel()
    
    private let benefits = [
        "**Free deliveries** *",
        "**Schedule orders** up to a week in advance",
        "**No surge pricing** during peak hours",
        "**Priority** order status"
    ]
    
    private let selectPlanContainer = UIView()
    private let selectPlanLabel = UILabel()
    
    private let annualPlanView = ExpressPlanView(isAnnual: true)
    private let spacing = UIView()
    private let monthlyPlanView = ExpressPlanView(isAnnual: false)
    
    private let disclaimerContainer = UIView()
    private let disclaimerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    private func buildViews() {
        //isHeroEnabled = true
        view.backgroundColor = .white
        
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        view.addSubview(scroll)
        
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.axis = .vertical
        scroll.addSubview(stack)
        
        titleLabel.font = Font.gotham(weight: .bold, size: 30)
        titleLabel.text = "Papaya Express"
        titleView.addSubview(titleLabel)
        stack.addArrangedSubview(titleView)
        
        for benefit in benefits {
            let benefitString = makeAttributedStringFromFormatted(benefit, boldFont: Font.gotham(weight: .bold, size: 17))
            let benefitView = createBenefitView(benefit: benefitString)
            stack.addArrangedSubview(benefitView)
        }
        
        selectPlanLabel.text = "Select a Plan"
        selectPlanLabel.font = Font.gotham(weight: .bold, size: 26)
        selectPlanContainer.addSubview(selectPlanLabel)
        stack.addArrangedSubview(selectPlanContainer)
        
        stack.addArrangedSubview(annualPlanView)
        
        spacing.backgroundColor = .clear
        stack.addArrangedSubview(spacing)
        
        stack.addArrangedSubview(monthlyPlanView)
        
        disclaimerLabel.text = "* Free deliveries only for orders over $20"
        disclaimerLabel.font = Font.gotham(size: 12)
        disclaimerLabel.textColor = UIColorFromRGB(0xA7A7A7)
        disclaimerContainer.addSubview(disclaimerLabel)
        stack.addArrangedSubview(disclaimerContainer)
    }
    
    private func buildConstraints() {
        scroll.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
        
        selectPlanLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(35)
            make.bottom.equalToSuperview().inset(24)
        }
        
        spacing.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        disclaimerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().inset(35)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        annualPlanView.layoutSubviews()
        monthlyPlanView.layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let tapAnnual = UITapGestureRecognizer(target: self, action: #selector(self.tapAnnual))
        annualPlanView.amount = 12.99
        annualPlanView.savings = "Save 35%"
        annualPlanView.subtitle = "Our most popular and cheapest plan. Billed annually. Cancel anytime."
        annualPlanView.addGestureRecognizer(tapAnnual)
        
        let tapMonthly = UITapGestureRecognizer(target: self, action: #selector(self.tapMonthly))
        monthlyPlanView.amount = 19.99
        monthlyPlanView.subtitle = "Billed monthly. Cancel anytime."
        monthlyPlanView.addGestureRecognizer(tapMonthly)
    }
    
    @objc private func tapAnnual() {
        let vc = ExpressPlanViewController()
        vc.plan = .annual
        //vc.isHeroEnabled = true
        vc.heroModalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .cover(direction: .down))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tapMonthly() {
        let vc = ExpressPlanViewController()
        vc.plan = .monthly
        //vc.isHeroEnabled = true
        vc.heroModalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .cover(direction: .down))
        navigationController?.pushViewController(vc, animated: true)
    }
}

class ExpressPlanView: UIView {
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
                savingsAttributed.addAttribute(.font, value: Font.gotham(weight: .medium, size: 12), range: NSMakeRange(savings.count - 1, 1))
                savingsLabel.attributedText = savingsAttributed
            }
        }
    }
    
    public var amount: Double? {
        didSet {
            var str = (self.amount ?? 0).currencyFormat
            str.insert(" ", index: 1)
            let attrPrice = NSMutableAttributedString(string: str)
            attrPrice.addAttribute(.font, value: Font.gotham(size: 12), range: NSMakeRange(1, 1))
            priceLabel.attributedText = attrPrice
        }
    }
    
    private var isAnnual = true
    
    private var imageLayer = CALayer()
    private let containerView = UIView()
    private let containerGradient = CAGradientLayer()
    private let priceLabel = UILabel()
    private let priceIntervalLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let savingsLabel = UILabel()
    private let savingsContainer = UIView()
    
    init(isAnnual: Bool) {
        super.init(frame: .zero)
        self.isAnnual = isAnnual
        self.setup()
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
        
        containerView.masksToBounds = true
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        addSubview(containerView)
        
        containerGradient.colors = (isAnnual ? [UIColorFromRGB(0x6216C2), UIColorFromRGB(0x75158D)] : [UIColorFromRGB(0x133657), UIColorFromRGB(0x03776A)]).map { $0.cgColor }
        containerGradient.startPoint = CGPoint(x: 0, y: 1)
        containerGradient.endPoint = CGPoint(x: 1, y: 0)
        containerGradient.opacity = 0.85
        containerView.layer.addSublayer(containerGradient)
        
        priceLabel.textColor = .white
        priceLabel.font = Font.gotham(weight: .bold, size: 44)
        containerView.addSubview(priceLabel)
        
        priceIntervalLabel.textColor = .white
        priceIntervalLabel.font = Font.gotham(size: 20)
        priceIntervalLabel.text = "/ month"
        containerView.addSubview(priceIntervalLabel)
        
        descriptionLabel.textColor = UIColorFromRGB(0xEBEBEB)
        descriptionLabel.font = Font.gotham(size: 12)
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
        savingsLabel.textAlignment = .center
        savingsLabel.textColor = .white
        savingsLabel.font = Font.gotham(weight: .bold, size: 12)
        savingsLabel.textAlignment = .center
        savingsContainer.addSubview(savingsLabel)
        
        savingsContainer.isHidden = true
        savingsContainer.backgroundColor = .black
        savingsContainer.layer.cornerRadius = 12.5
        containerView.addSubview(savingsContainer)
        
        imageLayer = CALayer()
        imageLayer.frame = containerView.bounds
        imageLayer.contents = isAnnual ? #imageLiteral(resourceName: "PremiumAnnualPlan").cgImage : #imageLiteral(resourceName: "PremiumMonthlyPlan").cgImage
        imageLayer.opacity = 0.65
        containerView.layer.insertSublayer(imageLayer, at: 0)
        
        //containerView.heroID = "express_plan_\(isAnnual ? "annual" : "monthly")_container"
        //priceLabel.heroID = "express_plan_\(isAnnual ? "annual" : "monthly")_title"
        //priceIntervalLabel.heroID = "express_plan_\(isAnnual ? "annual" : "monthly")_title_interval"
    }
    
    private func buildConstraints() {
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
            make.top.equalTo(priceLabel.snp.bottom).offset(16)
            make.right.equalToSuperview().inset(50)
            make.bottom.equalToSuperview().inset(32)
        }
        
        savingsContainer.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalToSuperview().inset(24)
            make.height.equalTo(25)
        }
        
        savingsLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerGradient.frame = containerView.bounds
        imageLayer.frame = containerView.bounds
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

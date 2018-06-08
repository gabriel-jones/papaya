//
//  SignupExpressViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/10/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import SafariServices

fileprivate func benefitView(_image: UIImage, _title: String, _subtitle: String) -> UIView {
    let v = UIView()
    v.backgroundColor = .white
    v.layer.cornerRadius = 7
    v.layer.shadowOpacity = 0.10
    v.layer.shadowOffset = .zero
    v.layer.shadowRadius = 15
    
    let image = UIImageView()
    image.image = _image
    image.contentMode = .scaleAspectFit
    v.addSubview(image)
    
    let title = UILabel()
    title.text = _title
    title.font = Font.gotham(size: 17)
    title.textColor = .black
    v.addSubview(title)
    
    let subtitle = UILabel()
    subtitle.text = _subtitle
    subtitle.font = Font.gotham(size: 13)
    subtitle.textColor = .gray
    subtitle.numberOfLines = 0
    v.addSubview(subtitle)
    
    image.snp.makeConstraints { make in
        make.left.top.equalToSuperview().inset(16)
        make.height.width.equalTo(50)
    }
    
    title.snp.makeConstraints { make in
        make.top.equalTo(16)
        make.left.equalTo(image.snp.right).offset(12)
    }
    
    subtitle.snp.makeConstraints { make in
        make.top.equalTo(title.snp.bottom).offset(12)
        make.left.equalTo(image.snp.right).offset(16)
        make.right.equalTo(-32)
    }

    return v
}

fileprivate func separatorView() -> UIView {
    let v = UIView()
    v.backgroundColor = UIColorFromRGB(0xd9d9d9)
    return v
}

protocol PricingViewDelegate: class {
    func didSelectBuy(sender: PricingView)
}

class PricingView: UIView {
    public var topText: String = String() {
        didSet {
            topLabel.text = topText
        }
    }
    
    public var topMainText: String = String() {
        didSet {
            topMainLabel.text = topMainText
        }
    }
    
    public var priceText: String = String() {
        didSet {
            priceLabel.text = priceText
        }
    }
    
    public var priceSecondaryText: String = String() {
        didSet {
            priceSecondaryLabel.text = priceSecondaryText
        }
    }
    
    public var descriptionText: String = String() {
        didSet {
            let attr = NSMutableAttributedString(string: descriptionText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 16
            attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, descriptionText.count))
            descriptionLabel.attributedText = attr
        }
    }
    
    public var delegate: PricingViewDelegate?
    
    private let topBar = UIView()
    private let topBarGradient = CAGradientLayer()
    private let topLabel = UILabel()
    private let topMainLabel = UILabel()
    private let priceLabel = UILabel()
    private let priceSecondaryLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buyButton = UIButton()
    private let buyButtonGradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        backgroundColor = .white
        
        layer.cornerRadius = 7
        layer.shadowOpacity = 0.10
        layer.shadowOffset = .zero
        layer.shadowRadius = 15
        
        masksToBounds = false
        clipsToBounds = false
        
        topBar.masksToBounds = true
        addSubview(topBar)
        
        topBarGradient.colors = [UIColorFromRGB(0x3300FF), UIColorFromRGB(0xBC26BF)].map { $0.cgColor }
        topBarGradient.startPoint = CGPoint(x: -0.2, y: -0.2)
        topBarGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        topBar.layer.insertSublayer(topBarGradient, at: 1)
        
        topLabel.font = Font.gotham(size: 14)
        topLabel.textColor = .white
        topBar.addSubview(topLabel)
        
        topMainLabel.font = Font.gotham(weight: .bold, size: 24)
        topMainLabel.textColor = .white
        topBar.addSubview(topMainLabel)
        
        priceLabel.font = Font.gotham(size: 32)
        priceLabel.textColor = .black
        addSubview(priceLabel)
        
        priceSecondaryLabel.font = Font.gotham(size: 14)
        priceSecondaryLabel.textColor = .black
        addSubview(priceSecondaryLabel)
        
        descriptionLabel.font = Font.gotham(size: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        addSubview(descriptionLabel)
        
        buyButton.setTitle("BUY NOW", for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.titleLabel?.font = Font.gotham(size: 14)
        buyButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 48, bottom: 16, right: 48)
        buyButton.addTarget(self, action: #selector(buy(_:)), for: .touchUpInside)
        buyButton.masksToBounds = true
        addSubview(buyButton)
        
        buyButtonGradient.colors = [UIColorFromRGB(0x3300FF), UIColorFromRGB(0xBC26BF)].map { $0.cgColor }
        buyButtonGradient.startPoint = CGPoint(x: -0.2, y: -0.2)
        buyButtonGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        buyButton.layer.insertSublayer(buyButtonGradient, at: 0)
    }
    
    private func buildConstraints() {
        topBar.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(70)
        }
        
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(20)
        }
        
        topMainLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(6)
            make.left.equalTo(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(30)
            make.left.equalTo(32)
        }
        
        priceSecondaryLabel.snp.makeConstraints { make in
            make.bottom.equalTo(priceLabel.snp.bottom).offset(-4)
            make.left.equalTo(priceLabel.snp.right)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(16)
            make.left.equalTo(32)
            make.right.equalTo(-50)
        }
        
        buyButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(snp.bottom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topBarGradient.frame = topBar.bounds
        buyButtonGradient.frame = buyButton.bounds
        
        buyButton.layer.cornerRadius = buyButton.frame.height / 2
        
        let path = UIBezierPath(roundedRect: topBar.bounds, byRoundingCorners:[.topRight, .topLeft], cornerRadii: CGSize(width: 7, height: 7))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        topBar.layer.mask = maskLayer
    }
    
    @objc private func buy(_ sender: UIButton) {
        delegate?.didSelectBuy(sender: self)
    }
}

class ExpressViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    
    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let benefitLabel = UILabel()
    private let freeDelivery = benefitView(_image: #imageLiteral(resourceName: "Free Delivery Purple"), _title: "Free deliveries", _subtitle: "Unlimited free deliveries for orders over $25")
    private let fasterOrders = benefitView(_image: #imageLiteral(resourceName: "Time Purple"), _title: "Faster orders", _subtitle: "Skip the queue and have your priority orders finished first")
    private let peakPricing = benefitView(_image: #imageLiteral(resourceName: "No Money Purple"), _title: "No peak pricing", _subtitle: "Never pay more during busy periods")
    private let separatorOne = separatorView()
    private let segmentedControl = ADVSegmentedControl()
    private let pricingScrollView = UIScrollView()
    private let yearlyView = PricingView()
    private let monthlyView = PricingView()
    private let separatorTwo = separatorView()
    
    private let supportView = benefitView(_image: #imageLiteral(resourceName: "Help Purple"), _title: "Need some help?", _subtitle: "Contact our support if you have any questions")
    private let supportButton = UIButton()
    private let supportButtonGradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)

        navigationItem.title = "Buy Express"
        
        scrollView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 48, right: 16)
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        stack.alignment = .fill
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .equalSpacing
        stack.backgroundColor = .blue
        scrollView.addSubview(stack)
        
        titleView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 110)
        titleView.gradientBackground(colors: [UIColorFromRGB(0x3300FF), UIColorFromRGB(0xBC26BF)], position: (.topLeft, .bottomRight))
        titleView.layer.cornerRadius = 7
        titleView.masksToBounds = true

        titleLabel.text = "Papaya Express"
        titleLabel.font = Font.gotham(weight: .bold, size: 30)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleView.addSubview(titleLabel)
        
        subtitleLabel.text = "Upgrade your experience"
        subtitleLabel.font = Font.gotham(size: 14)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .white
        titleView.addSubview(subtitleLabel)
        
        stack.addArrangedSubview(titleView)
        stack.setCustomSpacing(24, after: titleView)

        benefitLabel.text = "Amazing Benefits"
        benefitLabel.font = Font.gotham(size: 20)
        benefitLabel.textAlignment = .left
        benefitLabel.textColor = .black
        stack.addArrangedSubview(benefitLabel)
        
        stack.addArrangedSubview(freeDelivery)
        stack.addArrangedSubview(fasterOrders)
        stack.addArrangedSubview(peakPricing)
        
        stack.addArrangedSubview(separatorOne)
        
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        segmentedControl.items = ["YEARLY", "MONTHLY"]
        segmentedControl.font = Font.gotham(size: 14)
        segmentedControl.borderColor = .lightGray
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        segmentedControl.layer.cornerRadius = segmentedControl.frame.height / 2
        stack.addArrangedSubview(segmentedControl)
        
        pricingScrollView.isUserInteractionEnabled = false
        pricingScrollView.showsHorizontalScrollIndicator = false
        pricingScrollView.showsVerticalScrollIndicator = false
        pricingScrollView.contentSize = CGSize(width: view.frame.width * 2 + 16, height: 275)
        pricingScrollView.masksToBounds = false
        stack.addArrangedSubview(pricingScrollView)
        
        yearlyView.topText = "Most Popular"
        yearlyView.topMainText = "Save 25%"
        yearlyView.priceText = "$12"
        yearlyView.priceSecondaryText = " / month"
        yearlyView.descriptionText = "Billed annually\nGet a full year’s subscription to Papaya Express"
        yearlyView.delegate = self
        yearlyView.tag = 0
        pricingScrollView.addSubview(yearlyView)
        
        monthlyView.topText = "Basic Plan"
        monthlyView.topMainText = "Monthly"
        monthlyView.priceText = "$15"
        monthlyView.priceSecondaryText = " / month"
        monthlyView.descriptionText = "Billed monthly\nSubscription must be renewed every month"
        monthlyView.delegate = self
        monthlyView.tag = 1
        pricingScrollView.addSubview(monthlyView)
        
        //stack.addArrangedSubview(monthlyView)

        stack.addArrangedSubview(separatorTwo)
        
        stack.addArrangedSubview(supportView)

        supportButton.setTitle("SUPPORT", for: .normal)
        supportButton.setTitleColor(.white, for: .normal)
        supportButton.titleLabel?.font = Font.gotham(size: 14)
        supportButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 48, bottom: 16, right: 48)
        supportButton.addTarget(self, action: #selector(getSupport), for: .touchUpInside)
        supportButton.masksToBounds = true
        supportView.addSubview(supportButton)
        
        supportButtonGradient.colors = [UIColorFromRGB(0x3300FF), UIColorFromRGB(0xBC26BF)].map { $0.cgColor }
        supportButtonGradient.startPoint = CGPoint(x: -0.2, y: -0.2)
        supportButtonGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        supportButton.layer.insertSublayer(supportButtonGradient, at: 0)
    }
    
    @objc private func getSupport() {
        if let url = URL(string: C.URL.help) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        segmentedControl.thumbGradientColor = [UIColorFromRGB(0x3300FF), UIColorFromRGB(0xBC26BF)]
        supportButtonGradient.frame = supportButton.bounds
        supportButton.layer.cornerRadius = supportButton.frame.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        supportButtonGradient.frame = supportButton.bounds
        supportButton.layer.cornerRadius = supportButton.frame.height / 2
//        supportButton.gradientBackground(colors: [UIColorFromRGB(0x3300FF), UIColorFromRGB(0xBC26BF)], position: (.topLeft, .bottomRight))
//        supportButton.layoutSubviews()
//        segmentedControl.thumbGradientColor = [UIColorFromRGB(0x3300FF), UIColorFromRGB(0xBC26BF)]
//        segmentedControl.layoutSubviews()
    }
    
    @objc private func segmentedControlChanged(_ sender: ADVSegmentedControl) {
        let point: CGPoint = sender.selectedIndex == 0 ? .zero : CGPoint(x: stack.frame.width + 16, y: 0)
        pricingScrollView.setContentOffset(point, animated: true)
    }
    
    private func buildConstraints() {
        scrollView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.top.left.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
        }
        
        titleView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(110)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(25)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        freeDelivery.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(90)
        }
        
        fasterOrders.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(90)
        }
        
        peakPricing.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(90)
        }
        
        separatorOne.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(0.5)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.trailing.leading.equalToSuperview().inset(32)
        }
        
        pricingScrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(275)
        }
        
        yearlyView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(stack.snp.width)
            make.height.equalTo(250)
        }
        
        monthlyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(yearlyView.snp.right).offset(16)
            make.width.equalTo(stack.snp.width)
            make.height.equalTo(250)
        }
        
        separatorTwo.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(0.5)
        }
        
        supportView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(110)
        }
        
        supportButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(supportView.snp.bottom)
        }
    }
}

extension ExpressViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ExpressViewController: PricingViewDelegate {
    func didSelectBuy(sender: PricingView) {
        if sender.tag == 0 {
            
        } else {
            
        }
    }
}

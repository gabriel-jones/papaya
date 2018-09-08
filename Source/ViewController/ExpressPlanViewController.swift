//
//  ExpressPlanViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/29/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class ExpressPlanViewController: UIViewController {
    
    enum PlanType: String {
        case annual, monthly
    }
    public var plan: PlanType!
    
    private var paymentMethod: PaymentMethod?
    
    private let containerGradient = CAGradientLayer()
    private let closeButton = UIButton()
    private let imageLayer = CALayer()
    private let titleLabel = UILabel()
    private let titleIntervalLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let subscribeButton = LoadingButton()
    private let detailView = UIView()
    private let paymentMethodLabel = UILabel()
    private let changePaymentMethodButton = UIButton()
    private let cardView = CreditCardView()
    private let receiptLabel = UILabel()
    private let receiptValueLabel = UILabel()
    private let activityIndicator = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        self.loadPaymentDetails()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func subscribe(_ sender: LoadingButton) {
        guard let payment = paymentMethod else {
            let alert = UIAlertController(title: "Joining Express Failed", message: "Please select a payment method.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        sender.showLoading()
        Request.shared.joinExpress(paymentMethod: payment, isMonthlyPlan: plan == .monthly) { result in
            sender.hideLoading()
            switch result {
            case .success(_):
                User.current!.isExpress = true
                self.navigationController?.popToRootViewController(animated: true)
            case .failure(_):
                let alert = UIAlertController(title: "Joining Express Failed", message: "Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func loadPaymentDetails() {
        subscribeButton.showLoading()
        subscribeButton.isEnabled = false
        detailView.isHidden = true
        activityIndicator.startAnimating()
        Request.shared.getFirstPayment { result in
            self.subscribeButton.hideLoading()
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let paymentMethod):
                self.paymentMethod = paymentMethod
                self.cardView.update(new: paymentMethod)
                self.subscribeButton.isEnabled = true
                self.detailView.isHidden = false
            case .failure(_):
                self.showMessage("Can't load payment details", type: .error)
            }
        }
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    private func buildViews() {
        view.backgroundColor = .white
        
        view.heroID = "express_plan_\(plan.rawValue)_container"
        titleLabel.heroID = "express_plan_\(plan.rawValue)_title"
        titleIntervalLabel.heroID = "express_plan_\(plan.rawValue)_title_interval"
        
        let fadeOutGradient = CAGradientLayer()
        fadeOutGradient.colors = [UIColor.clear, UIColor.white].map { $0.cgColor }
        fadeOutGradient.startPoint = CGPoint(x: 0.5, y: 0)
        fadeOutGradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        imageLayer.isGeometryFlipped = true
        imageLayer.contentsGravity = kCAGravityTop
        imageLayer.contents = plan == .annual ? #imageLiteral(resourceName: "PremiumAnnualPlan").cgImage : #imageLiteral(resourceName: "PremiumMonthlyPlan").cgImage
        imageLayer.opacity = 0.65
        view.layer.insertSublayer(imageLayer, at: 0)
        
        view.layer.addSublayer(fadeOutGradient)
        fadeOutGradient.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 400)
        
        let block = CAShapeLayer()
        block.backgroundColor = UIColor.white.cgColor
        block.frame = CGRect(x: 0, y: 400, width: view.frame.width, height: view.frame.height)
        view.layer.addSublayer(block)
        
        containerGradient.colors = (plan == .annual ? [UIColorFromRGB(0x6216C2), UIColorFromRGB(0x75158D)] : [UIColorFromRGB(0x133657), UIColorFromRGB(0x03776A)]).map { $0.cgColor }
        containerGradient.startPoint = CGPoint(x: 0, y: 1)
        containerGradient.endPoint = CGPoint(x: 1, y: 0)
        containerGradient.opacity = 0.85
        view.layer.addSublayer(containerGradient)
        
        closeButton.setImage(#imageLiteral(resourceName: "Close").tintable, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.tintColor = .white
        closeButton.imageView?.tintColor = .white
        view.addSubview(closeButton)
        
        titleLabel.textColor = .white
        titleLabel.font = Font.gotham(weight: .bold, size: 44)
        view.addSubview(titleLabel)
        
        var str = 12.99.currencyFormat
        str.insert(" ", index: 1)
        let attrPrice = NSMutableAttributedString(string: str)
        attrPrice.addAttribute(.font, value: Font.gotham(size: 12), range: NSMakeRange(1, 1))
        titleLabel.attributedText = attrPrice
        
        titleIntervalLabel.textColor = .white
        titleIntervalLabel.font = Font.gotham(size: 20)
        titleIntervalLabel.text = "/ month"
        view.addSubview(titleIntervalLabel)
        
        subtitleLabel.text = "Papaya Express \(plan.rawValue.capitalizingFirstLetter()) Plan"
        subtitleLabel.font = Font.gotham(size: 16)
        subtitleLabel.textColor = .white
        view.addSubview(subtitleLabel)
        
        subscribeButton.backgroundColor = UIColorFromRGB(0xF2C94C)
        subscribeButton.setTitle("Subscribe", for: .normal)
        subscribeButton.setTitleColor(.black, for: .normal)
        subscribeButton.titleLabel?.font = Font.gotham(weight: .bold, size: 16)
        subscribeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        subscribeButton.addTarget(self, action: #selector(subscribe(_:)), for: .touchUpInside)
        subscribeButton.layer.cornerRadius = 20
        view.addSubview(subscribeButton)
        
        paymentMethodLabel.text = "Payment Method"
        paymentMethodLabel.textColor = .white
        paymentMethodLabel.font = Font.gotham(weight: .medium, size: 20)
        detailView.addSubview(paymentMethodLabel)
        
        changePaymentMethodButton.setTitle("Change", for: .normal)
        changePaymentMethodButton.setImage(#imageLiteral(resourceName: "Right Arrow").tintable, for: .normal)
        changePaymentMethodButton.imageView?.tintColor = .white
        changePaymentMethodButton.setTitleColor(.white, for: .normal)
        changePaymentMethodButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        changePaymentMethodButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        changePaymentMethodButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        changePaymentMethodButton.addTarget(self, action: #selector(changePayment), for: .touchUpInside)
        changePaymentMethodButton.titleLabel?.font = Font.gotham(size: 17)
        detailView.addSubview(changePaymentMethodButton)
        
        detailView.addSubview(cardView)
        
        receiptLabel.text = "First Year " + String(repeating: ".", count: 100)
        receiptLabel.font = Font.gotham(size: 15)
        receiptLabel.textColor = .white
        detailView.addSubview(receiptLabel)
        
        receiptValueLabel.text = " $155.88"
        receiptValueLabel.font = Font.gotham(size: 15)
        receiptValueLabel.textColor = .white
        detailView.addSubview(receiptValueLabel)
        
        detailView.backgroundColor = .clear
        detailView.isHidden = true
        view.addSubview(detailView)
        
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
    }
    
    @objc private func changePayment() {
        let vc = PaymentListViewController()
        vc.isModal = true
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    private func buildConstraints() {
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(closeButton.snp.bottom).offset(16)
        }
        
        titleIntervalLabel.snp.makeConstraints { make in
            make.lastBaseline.equalTo(titleLabel.snp.lastBaseline)
            make.left.equalTo(titleLabel.snp.right).offset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        subscribeButton.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.width.equalTo(150)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
        }
        
        detailView.snp.makeConstraints { make in
            make.bottom.right.left.equalToSuperview()
            make.top.equalTo(subscribeButton.snp.bottom).offset(8)
        }
        
        paymentMethodLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(subscribeButton.snp.bottom).offset(24)
        }
        
        changePaymentMethodButton.snp.makeConstraints { make in
            make.centerY.equalTo(paymentMethodLabel.snp.centerY)
            make.right.equalToSuperview().inset(24)
        }
        
        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(paymentMethodLabel.snp.bottom).offset(16)
        }
        
        receiptLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.top.equalTo(cardView.snp.bottom).offset(32)
            make.right.equalTo(receiptValueLabel.snp.left).priority(900)
        }
        
        receiptValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24).priority(1000)
            make.top.equalTo(cardView.snp.bottom).offset(32)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.top.equalTo(subscribeButton.snp.bottom).offset(75)
        }
    }
    
    override func viewWillLayoutSubviews() {
        containerGradient.frame = view.bounds
    }
}

extension ExpressPlanViewController: PaymentListModal {
    func chose(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
        cardView.update(new: paymentMethod)
    }
}

class CreditCardView: UIView {
    
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
    
    public func update(new: PaymentMethod?) {
        if let payment = new {
            cardNumber.text = payment.formattedCardNumber
            expiration.text = "Expires " + payment.shortFormattedExpirationDate!
            cardType.image = payment.image
        } else {
            cardNumber.text = "None selected"
            cardType.image = #imageLiteral(resourceName: "Card").tintable
        }
    }
    
    private let contentView = UIView()
    private let cardType = UIImageView()
    private let cardNumber = UILabel()
    private let cardholderLabel = UILabel()
    private let cardholder = UILabel()
    private let expirationLabel = UILabel()
    private let expiration = UILabel()
    
    private func buildViews() {
        backgroundColor = .clear
        masksToBounds = false
        clipsToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5
        contentView.masksToBounds = true
        contentView.backgroundColor = .white
        addSubview(contentView)
        
        cardType.tintColor = .lightGray
        contentView.addSubview(cardType)
        
        cardNumber.font = Font.gotham(size: 19)
        cardNumber.textColor = .black
        contentView.addSubview(cardNumber)
        
        expiration.font = Font.gotham(size: 13)
        expiration.textColor = .gray
        contentView.addSubview(expiration)
    }
    
    private func buildConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardType.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().offset(12)
        }
        
        cardNumber.snp.makeConstraints { make in
            make.left.equalTo(cardType.snp.right).offset(16)
            make.top.equalTo(12)
        }
        
        expiration.snp.makeConstraints { make in
            make.left.equalTo(cardNumber.snp.left)
            make.top.equalTo(cardNumber.snp.bottom)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}

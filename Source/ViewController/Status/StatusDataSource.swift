//
//  StatusDataSource.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/19/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

// long polling every 30 seconds
// pull to refresh
//

protocol StatusCellDelegate {
    func toggleViewItems(_ cell: Status_PackingCell, showItems: Bool)
    func submitFeedback(rating: Int, comments: String, result: @escaping ((Result<JSON>) -> ()))
    func layoutCell(_ cell: StatusCell)
}

class StatusCell: UITableViewCell {
    
    internal let viewContainer = UIView()
    internal let view = UIView()
    public var delegate: StatusCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    internal func buildViews() {
        selectionStyle = .none
        backgroundColor = .clear
        
        view.backgroundColor = .white
        
        viewContainer.layer.cornerRadius = 7
        viewContainer.clipsToBounds = false
        viewContainer.masksToBounds = false
        
        viewContainer.layer.shadowOpacity = 1
        viewContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewContainer.layer.shadowRadius = 5
        
        addSubview(viewContainer)
        
        view.layer.cornerRadius = 7
        view.masksToBounds = true
        view.clipsToBounds = true
        viewContainer.addSubview(view)
    }
    
    internal func buildConstraints() {
        viewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func set(order: Order) {
        
    }
}

protocol CellWithIdentifier {
    static var identifier: String { get }
}

class Status_PendingCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusPending.rawValue
    
    private let progressView = InfiniteProgressView()
    private let subtitleLabel = UILabel()
    private let timeLabel = UILabel()
    private let timeImage = UIImageView()
    
    override func buildViews() {
        super.buildViews()
        
        view.addSubview(progressView)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.progressView.layoutSubviews()
            self.progressView.startAnimating()
        }

        subtitleLabel.font = Font.gotham(size: 14)
        subtitleLabel.textColor = UIColorFromRGB(0x474747)
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Estimated time left in queue"
        view.addSubview(subtitleLabel)
        
        timeLabel.font = Font.gotham(weight: .bold, size: 25)
        timeLabel.textColor = .black
        timeLabel.textAlignment = .center
        timeLabel.text = "5 min"
        view.addSubview(timeLabel)
        
        timeImage.image = #imageLiteral(resourceName: "Timer").tintable
        timeImage.tintColor = UIColorFromRGB(0x474747)
        view.addSubview(timeImage)
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        progressView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(32)
            make.centerX.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-32)
        }
        
        timeImage.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.right.equalTo(timeLabel.snp.left).offset(-8)
        }
    }
}

class Status_PremiumAdvertCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusPremiumAdvert.rawValue
    
    private let tagLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let disclosureImage = UIImageView()
    
    override func set(order: Order) {
        super.set(order: order)
        
        if order.isPriority {
            return
        }
        
        if order.status == .new {
            tagLabel.text = "Priority"
            titleLabel.text = "Want to speed up your order?"
            subtitleLabel.text = "Rush this order for a one-time fee of $5"
        } else if order.status == .packing {
            tagLabel.text = "Express"
            titleLabel.text = "Want to speed up your order?"
            subtitleLabel.text = "Papaya Express prioritises all your future orders"
        } else if order.status == .packed && !order.isDelivery {
            tagLabel.text = "Express"
            titleLabel.text = "Want to make it faster next time?"
            subtitleLabel.text = "Papaya Express prioritises all your future orders"
        } else if (order.status == .packed || order.status == .delivery || order.status == .finished) && order.isDelivery {
            tagLabel.text = "Express"
            titleLabel.text = "You could've saved \(Double(order.transaction.deliveryFee!).currencyFormat)"
            subtitleLabel.text = "Get free deliveries for orders over $50"
        } else if order.status == .finished && !order.isDelivery {
            tagLabel.text = "Express"
            titleLabel.text = "Want to make it faster next time?"
            subtitleLabel.text = "Papaya Express prioritises all your future orders"
        }
    }
    
    override func buildViews() {
        super.buildViews()
        
        tagLabel.font = Font.gotham(weight: .bold, size: 11)
        tagLabel.textColor = UIColorFromRGB(0x6216C2)
        view.addSubview(tagLabel)
        
        titleLabel.font = Font.gotham(size: 17)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        
        subtitleLabel.font = Font.gotham(size: 13)
        subtitleLabel.textColor = UIColorFromRGB(0x8C8C8C)
        subtitleLabel.numberOfLines = 0
        view.addSubview(subtitleLabel)
        
        disclosureImage.image = #imageLiteral(resourceName: "Right Arrow").tintable
        disclosureImage.tintColor = UIColorFromRGB(0xC1C1C1)
        view.addSubview(disclosureImage)
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        tagLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(tagLabel.snp.bottom).offset(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-20)
        }
        
        disclosureImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.width.height.equalTo(20)
        }
    }
}

class Status_PickupCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusPickup.rawValue
    
    private let progressView = ProgressView()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func buildViews() {
        super.buildViews()
        
        progressView.progressColorOne = UIColorFromRGB(0xE7843D)
        progressView.progressColorTwo = UIColorFromRGB(0xF2C94C)
        view.addSubview(progressView)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.progressView.setProgress(1, animated: false)
        }
        
        subtitleLabel.textColor = UIColorFromRGB(0x757575)
        subtitleLabel.font = Font.gotham(size: 14)
        subtitleLabel.text = "Shopping finished!"
        view.addSubview(subtitleLabel)
        
        titleLabel.textColor = .black
        titleLabel.font = Font.gotham(weight: .bold, size: 25)
        titleLabel.numberOfLines = 0
        titleLabel.text = "Your order is now ready for pickup."
        view.addSubview(titleLabel)
        
        descriptionLabel.textColor = UIColorFromRGB(0x757575)
        descriptionLabel.font = Font.gotham(size: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Go to Miles Market and pick up your groceries now."
        view.addSubview(descriptionLabel)
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        progressView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-24)
        }
    }
}


class Status_DeliveryCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusDelivery.rawValue
    
    private let progressView = ProgressView()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let timeImage = UIImageView()
    
    override func set(order: Order) {
        super.set(order: order)
        titleLabel.text = order.delivery?.address.street
        subtitleLabel.text = order.status == .packed ? "Awaiting delivery to" : "Now delivering to"
        timeLabel.text = order.status == .packed ? "Delivery truck leaving soon" : "Arriving soon"
    }
    
    override func buildViews() {
        super.buildViews()
        
        progressView.progressColorOne = UIColorFromRGB(0xE7843D)
        progressView.progressColorTwo = UIColorFromRGB(0xF2C94C)
        view.addSubview(progressView)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.progressView.setProgress(1, animated: false)
        }
        
        subtitleLabel.textColor = UIColorFromRGB(0x757575)
        subtitleLabel.font = Font.gotham(size: 14)
        subtitleLabel.text = "Now delivering to"
        view.addSubview(subtitleLabel)
        
        titleLabel.textColor = .black
        titleLabel.font = Font.gotham(weight: .bold, size: 25)
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        timeImage.image = #imageLiteral(resourceName: "Timer").tintable
        timeImage.tintColor = UIColorFromRGB(0x757575)
        view.addSubview(timeImage)
        
        timeLabel.textColor = UIColorFromRGB(0x757575)
        timeLabel.font = Font.gotham(size: 14)
        timeLabel.numberOfLines = 0
        view.addSubview(timeLabel)
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        progressView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
        }
        
        timeImage.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(20)
            make.centerY.equalTo(timeLabel.snp.centerY)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(timeImage.snp.right).offset(4)
            make.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-24)
        }
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class Status_PackingCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusPacking.rawValue
    
    private let progressView = ProgressView()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()
    private let changeLabel = UILabel()
    private let changeImage = UIImageView()
    private let viewButton = UIButton()
    private let stackView = UIStackView()
    private let topBorder = UIView()
    
    override func set(order: Order) {
        super.set(order: order)
        
        titleLabel.text = "\(Int((order.percentPacked ?? 0) * 100))%"
        
        let changesCount = order.changesCount
        changeLabel.isHidden = changesCount == 0
        changeImage.isHidden = changesCount == 0
        changeLabel.text = "\(changesCount) change\(changesCount == 1 ? "" : "s")"
        
        stackView.arrangedSubviews.forEach { self.stackView.removeArrangedSubview($0); $0.removeFromSuperview() }
        
        for item in order.items {
            let cell = OrderItemView(item: item)
            cell.isHidden = true
            stackView.addArrangedSubview(cell)
        }
    }
    
    override func buildViews() {
        super.buildViews()
        
        progressView.progressColorOne = UIColorFromRGB(0x00D44D)
        progressView.progressColorTwo = UIColorFromRGB(0x57E1B6)
        view.addSubview(progressView)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.progressView.setProgress(1, animated: false)
        }
        
        subtitleLabel.textColor = UIColorFromRGB(0x757575)
        subtitleLabel.font = Font.gotham(size: 14)
        subtitleLabel.text = "Groceries packed"
        view.addSubview(subtitleLabel)
        
        titleLabel.textColor = .black
        titleLabel.font = Font.gotham(weight: .bold, size: 25)
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        viewButton.setTitle("View", for: .normal)
        viewButton.setTitleColor(UIColorFromRGB(0x2CC664), for: .normal)
        viewButton.setImage(#imageLiteral(resourceName: "Down Arrow").tintable, for: .normal)
        viewButton.tintColor = UIColorFromRGB(0x2CC664)
        viewButton.addTarget(self, action: #selector(view(_:)), for: .touchUpInside)
        viewButton.titleLabel?.font = Font.gotham(weight: .bold, size: 14)
        viewButton.tag = 0
        viewButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        view.addSubview(viewButton)
        
        changeImage.image = #imageLiteral(resourceName: "Error").tintable
        changeImage.tintColor = UIColorFromRGB(0x8c8c8c)
        view.addSubview(changeImage)
        
        changeLabel.textColor = UIColorFromRGB(0x8c8c8c)
        changeLabel.font = Font.gotham(size: 13)
        view.addSubview(changeLabel)
        
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 1.5
        stackView.distribution = .fillProportionally
        stackView.addBackground(color: UIColorFromRGB(0xF3F3F3))
        view.addSubview(stackView)
        
        topBorder.backgroundColor = UIColorFromRGB(0xF3F3F3)
        topBorder.isHidden = true
        view.addSubview(topBorder)
    }
    
    @objc private func view(_ sender: UIButton) {
        UIView.transition(with: sender, duration: 0.3, options: sender.tag == 0 ? .transitionFlipFromBottom : .transitionFlipFromTop, animations: {
            sender.setImage(sender.tag == 0 ? #imageLiteral(resourceName: "Up Arrow").tintable : #imageLiteral(resourceName: "Down Arrow").tintable, for: .normal)
            sender.setTitle(sender.tag == 0 ? "Hide" : "View", for: .normal)
        }, completion: { _ in
            sender.tag = sender.tag == 0 ? 1 : 0
        })
        
        topBorder.isHidden = sender.tag == 1
        stackView.arrangedSubviews.forEach { $0.isHidden = sender.tag == 1 }
        
        delegate?.toggleViewItems(self, showItems: sender.tag == 0)
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        progressView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
        }
        
        viewButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(viewButton.snp.centerY)
            make.right.equalToSuperview().inset(16)
        }
        
        changeImage.snp.makeConstraints { make in
            make.right.equalTo(changeLabel.snp.left).offset(-4)
            make.width.height.equalTo(16)
            make.centerY.equalTo(changeLabel.snp.centerY)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(viewButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        topBorder.snp.makeConstraints { make in
            make.height.equalTo(1.5)
            make.left.right.equalToSuperview()
            make.top.equalTo(stackView.snp.top)
        }
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

class OrderItemView: UIView {
    
    private var item: OrderItem!
    
    public init(item: OrderItem) {
        super.init(frame: .zero)
        self.item = item
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
    
    private let quantityLabel = UILabel()
    private let nameLabel = UILabel()
    private var packedLabel: UILabel?
    private var replacedLabel: UILabel?

    private func setup() {
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        backgroundColor = .white
        
        quantityLabel.text = "\(item.quantity)x"
        quantityLabel.font = Font.gotham(weight: .bold, size: 20)
        quantityLabel.textAlignment = .right
        addSubview(quantityLabel)
        
        nameLabel.text = item.name
        nameLabel.numberOfLines = 0
        nameLabel.font = Font.gotham(size: 16)
        addSubview(nameLabel)
        
        if let packedNumber = item.quantityCollected {
            packedLabel = UILabel()
            packedLabel!.text = "Packed \(packedNumber) / \(item.quantity)"
            packedLabel!.font = Font.gotham(size: 13)
            packedLabel!.textColor = UIColorFromRGB(0x2CC664)
            addSubview(packedLabel!)
            
            guard item.quantity > packedNumber else {
                return
            }
            
            replacedLabel = UILabel()
            replacedLabel!.font = Font.gotham(size: 13)
            replacedLabel!.textColor = UIColorFromRGB(0x8c8c8c)
            replacedLabel!.numberOfLines = 0
            if let replacedWith = item.replacedWith {
                replacedLabel!.text = "Replaced \(replacedWith.quantity) / \(item.quantity) with \"\(replacedWith.name)\""
            } else {
                replacedLabel!.text = "Refunded \(item.quantity - packedNumber) / \(item.quantity)"
            }
            addSubview(replacedLabel!)
        }
    }
    
    private func buildConstraints() {
        quantityLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.left.equalToSuperview()
            make.right.equalTo(nameLabel.snp.left).offset(-12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(56)
            make.top.equalTo(16)
            make.right.equalToSuperview().inset(16)
            if self.packedLabel == nil && self.replacedLabel == nil {
                make.bottom.equalToSuperview().inset(16)
            }
        }
        
        packedLabel?.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(16)
            if self.replacedLabel == nil {
                make.bottom.equalToSuperview().inset(16)
            }
        }
        
        replacedLabel?.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(self.packedLabel!.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}

class Status_SupportCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusSupport.rawValue
    
    public var isDeclined: Bool = false
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let disclosureImage = UIImageView()
    
    override func set(order: Order) {
        super.set(order: order)
        isDeclined = order.status == .declined
        if order.status == .declined {
            subtitleLabel.text = "Contact Miles Market if you have any questions"
        }
    }
    
    override func buildViews() {
        super.buildViews()
        
        titleLabel.font = Font.gotham(size: 17)
        titleLabel.textColor = .black
        titleLabel.text = "Need some help?"
        view.addSubview(titleLabel)
        
        subtitleLabel.font = Font.gotham(size: 13)
        subtitleLabel.textColor = UIColorFromRGB(0x8C8C8C)
        subtitleLabel.text = "Contact our support if you have any questions"
        subtitleLabel.numberOfLines = 0
        view.addSubview(subtitleLabel)
        
        disclosureImage.image = #imageLiteral(resourceName: "Right Arrow").tintable
        disclosureImage.tintColor = UIColorFromRGB(0xC1C1C1)
        view.addSubview(disclosureImage)
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(32)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-28)
        }
        
        disclosureImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.width.height.equalTo(20)
        }
    }
}

import HCSStarRatingView

class Status_CompletedCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusCompleted.rawValue
    
    private let progressView = ProgressView()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let feedbackView = UIView()
    private let feedbackLabel = UILabel()
    private let ratingView = HCSStarRatingView()
    private let commentsView = UITextView()
    private let submitButton = LoadingButton()
        
    override func set(order: Order) {
        super.set(order: order)
        
        titleLabel.text = "Your order has been \(order.isDelivery ? "delivered" : "picked up")."
        if order.isDelivery {
            descriptionLabel.text = "\(order.bags!) bag\(order.bags! > 1 ? "s" : "") of groceries \(order.bags! > 1 ? "were" : "was") delivered to your address, \(order.delivery!.address.street), at \(order.delivery!.timeDelivered!.format("h:mm a"))."
        } else {
            descriptionLabel.text = "You picked up \(order.bags!) bag\(order.bags! > 1 ? "s" : "") of groceries from Miles Market at \(order.time.pickedUp!.format("h:mm a"))."
        }
    }
    
    override func buildViews() {
        super.buildViews()
        
        progressView.progressColorOne = UIColorFromRGB(0xE7843D)
        progressView.progressColorTwo = UIColorFromRGB(0xF2C94C)
        view.addSubview(progressView)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.progressView.setProgress(1, animated: false)
        }
        
        subtitleLabel.textColor = UIColorFromRGB(0x757575)
        subtitleLabel.font = Font.gotham(size: 14)
        subtitleLabel.text = "Order completed!"
        view.addSubview(subtitleLabel)
        
        titleLabel.textColor = .black
        titleLabel.font = Font.gotham(weight: .bold, size: 25)
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        descriptionLabel.textColor = UIColorFromRGB(0x757575)
        descriptionLabel.font = Font.gotham(size: 14)
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        
        view.addSubview(feedbackView)
        
        feedbackLabel.textColor = UIColorFromRGB(0x000000)
        feedbackLabel.font = Font.gotham(size: 14)
        feedbackLabel.text = "Submit Feedback"
        feedbackView.addSubview(feedbackLabel)
        
        ratingView.allowsHalfStars = false
        ratingView.value = 0
        ratingView.spacing = 13
        ratingView.emptyStarImage = #imageLiteral(resourceName: "Star").tintable
        ratingView.filledStarImage = #imageLiteral(resourceName: "Star").tintable
        ratingView.starBorderWidth = 0
        ratingView.emptyStarColor = UIColorFromRGB(0xC4C4C4)
        ratingView.tintColor = UIColorFromRGB(0xF2C94C)
        feedbackView.addSubview(ratingView)
        
        commentsView.layer.cornerRadius = 5
        commentsView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 8, right: 12)
        commentsView.font = Font.gotham(size: 14)
        commentsView.tintColor = UIColorFromRGB(0x6a6a6a)
        commentsView.textColor = UIColorFromRGB(0x6a6a6a)
        commentsView.placeholder = "Additional Comments"
        commentsView.placeholder.backgroundColor = UIColorFromRGB(0xF1F1F1)
        commentsView.placeholderColor = UIColorFromRGB(0xa8a8a8)
        commentsView.backgroundColor = UIColorFromRGB(0xF1F1F1)
        feedbackView.addSubview(commentsView)
        
        submitButton.layer.cornerRadius = 5
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = Font.gotham(weight: .bold, size: 13)
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        submitButton.backgroundColor = UIColorFromRGB(0xE7843D)
        submitButton.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
        feedbackView.addSubview(submitButton)
    }
    
    @objc private func submit(_ sender: LoadingButton) {
        sender.showLoading()
        delegate?.submitFeedback(rating: Int(self.ratingView.value), comments: self.commentsView.text) { result in
            sender.hideLoading()
            if result.value != nil {
                self.feedbackView.isHidden = true
                self.feedbackView.frame.size = CGSize(width: 0, height: 0)
                self.descriptionLabel.snp.makeConstraints { make in
                    make.bottom.equalToSuperview().inset(16)
                }
                self.delegate?.layoutCell(self)
                
                let alert = UIAlertController(title: "Thanks for your feedback!", message: "If you have any more questions / concerns, feel free to contact us at support@papaya.bm", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                // TODO: present
            } else {
                // possible easier syntax?
                /*alert(title: "", message: "", buttons: [
                    "Ok", {
                        
                    },
                    "Cancel": {
                    
                    }
                ])*/
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        submitButton.gradientBackground(colors: [UIColorFromRGB(0xE7843D), UIColorFromRGB(0xF2C94C)], position: (.left, .right))
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        progressView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        feedbackLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }
        
        ratingView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(feedbackLabel.snp.bottom).offset(6)
            make.width.lessThanOrEqualToSuperview().inset(32)
        }
        
        commentsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(ratingView.snp.bottom).offset(16)
            make.height.equalTo(140)
        }
        
        submitButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.top.equalTo(commentsView.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(16)
            make.width.equalTo(150)
        }
        
        feedbackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

class Status_DeclinedCell: StatusCell, CellWithIdentifier {
    public static var identifier: String = C.ViewModel.CellIdentifier.statusDeclined.rawValue
    
    private let progressView = ProgressView()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func buildViews() {
        super.buildViews()
        
        progressView.progressColorOne = UIColorFromRGB(0xEE2424)
        progressView.progressColorTwo = UIColorFromRGB(0xE7843D)
        view.addSubview(progressView)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.progressView.setProgress(1, animated: false)
        }
        
        subtitleLabel.textColor = UIColorFromRGB(0x757575)
        subtitleLabel.font = Font.gotham(size: 14)
        subtitleLabel.text = "Something went wrong."
        view.addSubview(subtitleLabel)
        
        titleLabel.textColor = .black
        titleLabel.font = Font.gotham(weight: .bold, size: 25)
        titleLabel.numberOfLines = 0
        titleLabel.text = "Your order was declined by Miles Market."
        view.addSubview(titleLabel)
        
        descriptionLabel.textColor = UIColorFromRGB(0x757575)
        descriptionLabel.font = Font.gotham(size: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Your order has been refunded. Please contact Miles Market if you need further support."
        view.addSubview(descriptionLabel)
    }
    
    override func buildConstraints() {
        super.buildConstraints()
        
        progressView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-24)
        }
    }
}

protocol StatusFetcherDelegate {
    func startedFetch()
    func stoppedFetch(with result: Result<Order>)
    func stoppedFetch(with result: Result<OrderStatus>)
}

extension StatusFetcherDelegate {
    func stoppedFetch(with result: Result<Order>) {}
    func stoppedFetch(with result: Result<OrderStatus>) {}
}

class StatusFetcher: NSObject {
    public static let shared = StatusFetcher()
    
    public var delegate: StatusFetcherDelegate?
    
    public var order: Order?
    private var dataTask: URLSessionDataTask?
    private var timer: Timer!
    
    public func startFetching(id: Int, statusOnly: Bool = false) {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            if statusOnly {
                self.fetchStatus()
            } else {
                self.fetch(id: id)
            }
        }
        timer.fire()
    }
    
    public func fetchStatus(_ completion: ((Result<OrderStatus>) -> ())? = nil) {
        delegate?.startedFetch()
        
        dataTask?.cancel()
        dataTask = Request.shared.getCurrentOrder { result in
            self.delegate?.stoppedFetch(with: result)
            completion?(result)
        }
    }
    
    public func fetch(id: Int, _ completion: ((Result<Order>) -> ())? = nil) {
        delegate?.startedFetch()
        
        dataTask?.cancel()
        dataTask = Request.shared.getOrder(id: id) { result in
            self.order = result.value
            self.delegate?.stoppedFetch(with: result)
            completion?(result)
        }
    }
    
    public func stopFetching() {
        timer.invalidate()
        dataTask?.cancel()
        dataTask = nil
        order = nil
        timer = nil
    }
}

class StatusDataSource: NSObject, UITableViewDataSource, StatusFetcherDelegate {
    public var statusViewController: StatusFetcherDelegate?
    public var orderId: Int!
    
    private var order: Order?
    private var tableView: UITableView?
    private var cells = [String]()
    private let allCells = [CellWithIdentifier.Type]()
    private let fetcher = StatusFetcher()
    
    public func set(order: Order) {
        self.order = order
        self.updateCells()
        self.statusViewController?.stoppedFetch(with: Result(value: order))
    }
    
    internal func startedFetch() {
        self.statusViewController?.startedFetch()
    }
    
    internal func stoppedFetch(with result: Result<Order>) {
        self.order = result.value
        self.updateCells()
        self.statusViewController?.stoppedFetch(with: result)
    }
    
    public func initTableView(_ tableView: UITableView) {
        fetcher.delegate = self
        fetcher.startFetching(id: self.orderId)
        
        self.tableView = tableView
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        tableView.register(Status_PendingCell.classForCoder(), forCellReuseIdentifier: Status_PendingCell.identifier)
        tableView.register(Status_SupportCell.classForCoder(), forCellReuseIdentifier: Status_SupportCell.identifier)
        tableView.register(Status_PremiumAdvertCell.classForCoder(), forCellReuseIdentifier: Status_PremiumAdvertCell.identifier)
        tableView.register(Status_PickupCell.classForCoder(), forCellReuseIdentifier: Status_PickupCell.identifier)
        tableView.register(Status_DeliveryCell.classForCoder(), forCellReuseIdentifier: Status_DeliveryCell.identifier)
        tableView.register(Status_PackingCell.classForCoder(), forCellReuseIdentifier: Status_PackingCell.identifier)
        tableView.register(Status_CompletedCell.classForCoder(), forCellReuseIdentifier: Status_CompletedCell.identifier)
        tableView.register(Status_DeclinedCell.classForCoder(), forCellReuseIdentifier: Status_DeclinedCell.identifier)
    }
    
    private func updateCells() {
        guard let order = self.order else {
            cells = []
            return
        }
        
        if order.status == .new {
            cells = [Status_PendingCell.identifier]
        } else if order.status == .packing {
            cells = [Status_PackingCell.identifier]
        } else if order.status == .packed && !order.isDelivery {
            cells = [Status_PickupCell.identifier]
        } else if order.status == .delivery || (order.status == .packed && order.isDelivery) {
            cells = [Status_DeliveryCell.identifier]
        } else if order.status == .finished {
            cells = [Status_CompletedCell.identifier]
        } else if order.status == .declined {
            cells = [Status_DeclinedCell.identifier]
        }
        
        if !order.isPriority && !User.current!.isExpress && order.status != .declined {
            cells.insert(Status_PremiumAdvertCell.identifier, at: 1)
        }
        cells.append(Status_SupportCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cells[indexPath.row], for: indexPath) as! StatusCell
        cell.delegate = self
        if let order = self.order {
            cell.set(order: order)
        }
        return cell
    }
}

extension StatusDataSource: StatusCellDelegate {
    func toggleViewItems(_ cell: Status_PackingCell, showItems: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            cell.layoutIfNeeded()
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
        })
    }
    
    func submitFeedback(rating: Int, comments: String, result: @escaping ((Result<JSON>) -> ())) {
        guard let order = order else {
            return
        }
        Request.shared.submitOrderFeedback(order.id, rating: rating, comments: comments) { r in
            result(r)
        }
    }
    
    func layoutCell(_ cell: StatusCell) {
        UIView.animate(withDuration: 0.3, animations: {
            cell.layoutIfNeeded()
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
        })
    }
}

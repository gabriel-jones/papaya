//
//  StatusViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/18/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import SafariServices

fileprivate let priorityColor = UIColorFromRGB(0x6216C2)
fileprivate let primaryColor = UIColor(named: .green)
fileprivate let primaryOffsetColor = UIColorFromRGB(0x2CC664)
fileprivate let gradientFirstColor = UIColorFromRGB(0xE7843D)
fileprivate let gradientSecondColor = UIColorFromRGB(0xF2C94C)

protocol StatusHeaderViewDelegate: class {
    func close()
}

class StatusHeaderView: UIView {
    private let navTitleView = UIView()
    private let navTitleCloseButton = UIButton()
    private let navTitleLabel = UILabel()
    private let navTitlePriority = UIView()
    private let navTitlePriorityLabel = UILabel()
    private let navTitleLoadingView = LoadingView()
    private let navProgressView = StepProgressView()
    
    public var delegate: StatusHeaderViewDelegate?
    
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
        self.layoutIfNeeded()
    }
    
    public func scrollViewDidScroll(withOffset: CGFloat) {
        let y = withOffset
        navProgressView.snp.updateConstraints { make in
            make.top.equalTo(navTitleView.snp.bottom).offset(y > 0 ? 16 : 16 + abs(y) / 7)
        }
        
        navTitleView.snp.updateConstraints { make in
            make.top.equalTo(y > 0 ? 38 : 38 + abs(y) / 3.5)
        }
    }
    
    @objc private func close(_ sender: UIButton) {
        delegate?.close()
    }
    
    private func buildViews() {
        backgroundColor = .white
        
        navTitleCloseButton.setImage(#imageLiteral(resourceName: "Down Arrow").tintable, for: .normal)
        navTitleCloseButton.tintColor = primaryColor
        navTitleCloseButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        navTitleView.addSubview(navTitleCloseButton)
        
        navTitleLabel.textColor = .black
        navTitleLabel.font = Font.gotham(weight: .bold, size: 30)
        navTitleView.addSubview(navTitleLabel)
        
        navTitlePriorityLabel.text = "Priority"
        navTitlePriorityLabel.textColor = .white
        navTitlePriorityLabel.font = Font.gotham(weight: .bold, size: 12)
        navTitlePriority.addSubview(navTitlePriorityLabel)
        
        navTitlePriority.backgroundColor = priorityColor.withAlphaComponent(0.75)
        navTitleView.addSubview(navTitlePriority)
        
        navTitleLoadingView.color = UIColor(named: .green)
        navTitleLoadingView.lineWidth = 2.5
        navTitleView.addSubview(navTitleLoadingView)
        
        addSubview(navTitleView)
        
        navProgressView.alpha = 0
        navProgressView.labelFont = Font.gotham(weight: .bold, size: 12)
        addSubview(navProgressView)
        
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        layer.masksToBounds = false
    }
    
    public func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            navTitleLoadingView.startAnimating()
        } else {
            navTitleLoadingView.stopAnimating()
        }
    }
    
    public func set(orderId: Int) {
        navTitleLabel.text = "Order #\(orderId)"
    }
    
    public func set(order: Order) {
        navTitleLabel.text = "Order #\(order.id)"
        
        navProgressView.points = ["Pending", "Packing", order.isDelivery ? "Delivery" : "Pickup", "Finished"]
        navProgressView.setProgress([
            .new: 0,
            .packing: 1,
            .packed: 2,
            .delivery: 2,
            .finished: 3
        ][order.status] ?? -1, animated: true, fractional: Float(order.status == .packing ? order.percentPacked ?? 0.0 : 0.0))
        
        navTitlePriority.isHidden = !order.isPriority
    }
    
    public func showProgressView() {
        navProgressView.snp.updateConstraints { make in
            make.top.equalTo(navTitleView.snp.bottom).offset(0)
        }
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.navProgressView.alpha = 1
            
            self.navProgressView.snp.updateConstraints { make in
                make.top.equalTo(self.navTitleView.snp.bottom).offset(16)
            }
            self.layoutIfNeeded()
        }
    }
    
    public func hideProgressView() {
        UIView.animate(withDuration: 0.3) {
            self.navProgressView.alpha = 0
            
            self.navProgressView.snp.updateConstraints { make in
                make.top.equalTo(self.navTitleView.snp.bottom).offset(0)
            }
            self.layoutIfNeeded()
        }
    }
    
    private func buildConstraints() {
        navTitleView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(38)
        }
        
        navTitleCloseButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(35)
            make.left.equalToSuperview()
        }
        
        navTitleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(navTitleCloseButton.snp.right).offset(8)
        }
        
        navTitlePriority.snp.makeConstraints { make in
            make.left.equalTo(navTitleLabel.snp.right).offset(12)
            make.centerY.equalTo(navTitleLabel.snp.centerY)
        }
        
        navTitlePriorityLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        navTitleLoadingView.snp.makeConstraints { make in
            make.centerY.equalTo(navTitleLabel.snp.centerY)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(25)
        }
        
        navProgressView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalTo(navTitleView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        navTitlePriority.layer.cornerRadius = navTitlePriority.frame.height / 2
    }
}

class StatusViewController: UIViewController, StatusHeaderViewDelegate {
    
    public var orderId: Int!
    
    private var tableView = UITableView()
    private let headerView = StatusHeaderView()
    private var headerViewHeight: CGFloat = 90
    private let loadingView = LoadingView()
    
    private var isLoading = true
    private var isInitialState = true
    private let dataSource = StatusDataSource()
    private var lastOrderStatus: Order.Status?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource.orderId = orderId
        dataSource.statusViewController = self
        dataSource.initTableView(tableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func buildViews() {
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundColor = UIColor(named: .backgroundGrey)
        tableView.alwaysBounceVertical = true
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        view.addSubview(tableView)
        
        headerView.masksToBounds = false
        headerView.delegate = self
        headerView.set(orderId: orderId)
        view.addSubview(headerView)
        
        loadingView.color = primaryColor
        tableView.addSubview(loadingView)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide).offset(headerViewHeight)
            } else {
                make.top.equalTo(headerViewHeight)
            }
        }
        
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.height.equalTo(headerViewHeight)
        }
        
        loadingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-headerViewHeight)
            make.height.width.equalTo(40)
        }
    }
    
    private func setShowsStatus(_ to: Bool) {
        headerViewHeight = to ? 130 : 90
        UIView.animate(withDuration: 0.3) {
            self.headerView.snp.updateConstraints { make in
                make.height.equalTo(self.headerViewHeight)
            }
            self.tableView.snp.updateConstraints { make in
                if #available(iOS 11, *) {
                    make.top.equalTo(self.view.safeAreaLayoutGuide).offset(self.headerViewHeight)
                } else {
                    make.top.equalTo(self.headerViewHeight)
                }
            }
            
            self.view.layoutIfNeeded()
        }
        if to {
            headerView.showProgressView()
        } else {
            headerView.hideProgressView()
        }
    }
}

extension StatusViewController: StatusFetcherDelegate {
    func startedFetch() {
        if isInitialState {
            loadingView.startAnimating()
        } else {
            headerView.setIsLoading(true)
        }
    }
    
    func stoppedFetch(with result: Result<Order>) {
        headerView.setIsLoading(false)
        
        guard let order = result.value else {
            // error handling
            return
        }
        if isInitialState {
            self.setShowsStatus(true)
            self.loadingView.removeFromSuperview()
        }
        isInitialState = false
        
        headerView.set(order: order)
        
        if order.status != lastOrderStatus {
            tableView.reloadData()
        }
        lastOrderStatus = order.status
    }
}

extension StatusViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        headerView.snp.updateConstraints { make in
            let h = self.headerViewHeight
            make.height.equalTo(y > 0 ? h : h + abs(y) / 2)
        }
        if isInitialState {
            loadingView.snp.updateConstraints { make in
                let h = self.headerViewHeight
                make.centerY.equalToSuperview().offset(y > 0 ? -h : -h - abs(y) / 5)
            }
        }
        self.view.layoutIfNeeded()
        headerView.scrollViewDidScroll(withOffset: y)
    }
}

extension StatusViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension StatusViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print(indexPath)
        if let cell = tableView.cellForRow(at: indexPath) as? Status_SupportCell {
            if cell.isDeclined {
                let alert = UIAlertController(title: "Call Miles Market?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
                    guard let number = URL(string: "tel://14417035040") else { return }
                    UIApplication.shared.open(number)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                let vc = SFSafariViewController(url: URL(string: C.URL.support)!)
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
        } else if let cell = tableView.cellForRow(at: indexPath) as? Status_PremiumAdvertCell {
            let vc = ExpressViewController()
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true, completion: nil)
        }
        return nil
    }
}

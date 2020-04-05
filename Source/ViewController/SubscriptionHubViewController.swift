//
//  SubscriptionHubViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/31/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

// description

//(club / express)membership plan
// - billed <plan> (annually / monthly)
// - amount ($ per month / year)

//payment method
// - paymentmethodcell

//payments
// - last payment, date
// - next payment, subtitle:"On May 12, 2018, you will be charged for a year of membership ($840) to the Microbrew Club. You will be emailed a reminder on May 10, 2018."

// cancel

class SubscriptionHubViewController: UIViewController {
    public var subscription: Subscription?
    public var isExpress: Bool = false
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        tableView.alwaysBounceVertical = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func cancelSubscription(_ sender: LoadingButton) {
        let alert = UIAlertController(title: "Cancel your subscription?", message: "You will lose your \(subscription?.subscriptionType.intervalInMonths == 1 ? "monthly" : "annual") subscription to \(isExpress ? "Papaya Express" : "") if you continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel Subscription", style: .destructive) { _ in
            sender.showLoading()
            if self.isExpress {
                Request.shared.cancelExpress { result in
                    sender.hideLoading()
                    switch result {
                    case .success(_):
                        if self.isExpress {
                            User.current!.isExpress = false
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                    case .failure(_):
                        self.showMessage("Can't cancel subscription", type: .error)
                    }
                }
            } else {
                // cancel club
            }
        })
        alert.addAction(UIAlertAction(title: "Keep Subscription", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SubscriptionHubViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [
            0: 2,
            1: 1,
            2: 2,
            3: 1
        ][section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let subscription = self.subscription else {
            return UITableViewCell()
        }
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "dkfsdfjsdhf")
            cell.textLabel?.text = ["Billed", "Amount"][indexPath.row]
            cell.detailTextLabel?.text = [subscription.subscriptionType.intervalInMonths == 1 ? "Monthly" : "Annually", subscription.subscriptionType.amount.currencyFormat][indexPath.row]
            cell.detailTextLabel?.textColor = .lightGray
            
            cell.textLabel?.font = Font.gotham(size: 16)
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            return cell
        case 1:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.addressCell.rawValue)
            cell.textLabel?.text = subscription.paymentMethod.formattedCardNumber
            cell.textLabel?.font = Font.gotham(size: 16)
            if let expirationDate = subscription.paymentMethod.formattedExpirationDate {
                cell.detailTextLabel?.text = "Expires " + expirationDate
            }
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            cell.detailTextLabel?.textColor = .lightGray
            cell.imageView?.image = subscription.paymentMethod.image
            cell.imageView?.tintColor = .lightGray
            cell.accessoryType = .disclosureIndicator
            return cell
        case 2:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "subscriptionHubPaymentCell") // good, readable identifers are critical for readability
            cell.textLabel?.text = ["Last Payment", "Next Payment"][indexPath.row]
            cell.detailTextLabel?.textColor = .lightGray
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = [
                subscription.lastPayment.format("MMMM d, yyyy"),
                subscription.nextPayment.format("MMMM d, yyyy")
            ][indexPath.row]
            
            cell.textLabel?.font = Font.gotham(size: 16)
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            return cell
        case 3:
            let cell = UITableViewCell()
            let button = LoadingButton()
            button.setTitleColor(UIColor(named: .red), for: .normal)
            button.setTitle("Cancel Subscription", for: .normal)
            button.addTarget(self, action: #selector(cancelSubscription(_:)), for: .touchUpInside)
            button.titleLabel?.font = Font.gotham(size: 15)
            cell.addSubview(button)
            
            button.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [
            0: "Membership Plan",
            1: "Payment Method",
            2: "Payments"
        ][section]
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let subscription = self.subscription else {
            return nil
        }
        if section == 2 {
            return "On \(subscription.nextPayment.format("MMMM d, yyyy")), you will be charged for a \(subscription.subscriptionType.intervalInMonths == 1 ? "month" : "year") of membership (\(subscription.subscriptionType.amount.currencyFormat)) of \(isExpress ? "Papaya Express" : "unknown")."
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 2 ? UITableViewAutomaticDimension : 50
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Font.gotham(size: header.textLabel!.font.pointSize)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.font = Font.gotham(size: footer.textLabel!.font.pointSize)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            // payment method
            let vc = PaymentDetailViewController()
            vc.isModal = true
            vc.isModalSubscription = true
            vc.paymentMethod = self.subscription?.paymentMethod
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true, completion: nil)
        }
    }
}

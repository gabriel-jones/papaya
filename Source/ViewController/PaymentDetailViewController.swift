//
//  PaymentDetailViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class PaymentDetailViewController: UIViewController {
    
    public var paymentMethod: PaymentMethod?
    public var delegate: PaymentListDelegate?
    public var isModal: Bool = false
    public var isModalSubscription: Bool = false
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var saveButton: UIBarButtonItem!
    private var closeButton: UIBarButtonItem?
    private var activityIndicator = LoadingView()
    
    private var years = [String]()
    private var months = [String]()
    private var expirationMonth = String()
    private var expirationYear = String()
    
    private var securityCodeTextField: UITextField?
    private var expirationTextField: UITextField?
    private var cardNumberTextField: UITextField?
    
    private var pickerView: UIPickerView?
    private var inputViewExpiration: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "\(paymentMethod == nil ? "Add" : "") Payment Method"
        
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save(_:)))
        saveButton.tintColor = UIColor(named: .green)
        saveButton.setTitleTextAttributes([ .font: Font.gotham(size: 17) ], for: .normal)
        saveButton.setTitleTextAttributes([ .font: Font.gotham(size: 17) ], for: .highlighted)
        
        if paymentMethod == nil {
            self.navigationItem.rightBarButtonItem = saveButton
        }
        
        activityIndicator.color = UIColor(named: .green)
        activityIndicator.lineWidth = 2.5
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        if paymentMethod == nil || isModal {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            closeButton?.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = closeButton
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.register(SettingsInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsInputTableViewCell.identifier)
        tableView.register(SettingsLargeInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsLargeInputTableViewCell.identifier)
        view.addSubview(tableView)
        
        for i in 1...12 {
            months.append(String(format: "%02d", i))
        }
        let currYear = Calendar.current.component(.year, from: Date())
        for i in currYear...currYear+10 {
            years.append("\(i)")
        }
        
        let tbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        tbar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let tbar_done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(finishedPickerViewSelection))
        tbar.items = [flex, tbar_done]
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: tbar.frame.height, width: view.frame.width, height: view.frame.height / 2 - tbar.frame.height))
        pickerView!.delegate = self
        pickerView!.dataSource = self
        
        inputViewExpiration = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: pickerView!.frame.height + tbar.frame.height))
        inputViewExpiration?.addSubview(pickerView!)
        inputViewExpiration?.addSubview(tbar)
    }
    
    private func setBarButtonItem(isLoading: Bool) {
        navigationItem.rightBarButtonItem = isLoading ? UIBarButtonItem(customView: activityIndicator) : saveButton
        activityIndicator.startAnimating()
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Can't save payment method", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func save(_ sender: UIBarButtonItem) {
        guard
            let cardString = cardNumberTextField?.text,
            let expiration = expirationTextField?.text,
            let securityCode = securityCodeTextField?.text
        else {
            return
        }
        
        if cardString.isEmpty || expiration.isEmpty || securityCode.isEmpty {
            showError(message: "Please fill out all the fields")
            return
        }
        
        let card = cardString.replacingOccurrences(of: " ", with: "")
        
        let expComps = expiration.components(separatedBy: "/")
        if expComps.count != 2 || expComps[0] == "" || expComps[1] == "" {
            showError(message: "Please fill out all the fields")
            return
        }
        let expirationMonth = expComps[0]
        let expirationYear = "20" + expComps[1]
        
        if paymentMethod == nil {
            self.setBarButtonItem(isLoading: true)
            Request.shared.addPaymentMethod(card: card, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: securityCode) { result in
                self.setBarButtonItem(isLoading: false)
                switch result {
                case .success(_):
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.refresh()
                case .failure(_):
                    self.showMessage("Can't create payment method", type: .error)
                }
            }
        }
    }
    
    @objc private func deletePayment(_ sender: LoadingButton) {
        if isModalSubscription {
            let vc = PaymentListViewController()
            vc.delegate = self
            vc.isModal = true
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true, completion: nil)
        } else {
            sender.showLoading()
            Request.shared.deletePaymentMethod(id: self.paymentMethod!.id) { result in
                sender.hideLoading()
                switch result {
                case .success(_):
                    self.hideMessage(animated: true)
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.refresh()
                case .failure(let error):
                    if case .paymentProfileInUse = error {
                        let alert = UIAlertController(title: "Can't delete payment method", message: "This payment method is already in use for a subscription. Please change your payment method for your subscriptions before deleting this payment method.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.showMessage("Can't delete payment method", type: .error)
                    }
                }
            }
        }
    }
    
    @objc private func textDidChange(_ sender: UITextField) {
        if sender.tag == 2 {
            if securityCodeTextField?.text?.count ?? 0 > 3 {
                securityCodeTextField?.text = securityCodeTextField?.text?.substring(to: 3)
            }
        }
        
        if sender.tag == 0 {
            sender.text = modifyCreditCardString(creditCardString: sender.text!)
        }
        
    }
}

func modifyCreditCardString(creditCardString : String) -> String {
    let trimmedString = creditCardString.components(separatedBy: .whitespaces).joined()
    let arrOfCharacters = Array(trimmedString.characters)
    var modifiedCreditCardString = ""
    if(arrOfCharacters.count > 0) {
        for i in 0...arrOfCharacters.count-1 {
            modifiedCreditCardString.append(arrOfCharacters[i])
            if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count) {
                modifiedCreditCardString.append(" ")
            }
        }
    }
    return modifiedCreditCardString
}

extension PaymentDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return paymentMethod == nil ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (paymentMethod == nil ? 3 : 2) : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = ["Credit Card Number", "Expiration Date", "3-digit Security Code"][indexPath.row]
            let str = anet_ExpirationDateFormatter.date(from: paymentMethod?.expirationDate)?.format("MM/y")

            cell.textField.text = [paymentMethod?.formattedCardNumber, paymentMethod?.formattedExpirationDate, nil][indexPath.row]
            cell.textField.isUserInteractionEnabled = paymentMethod == nil
            cell.textField.tag = indexPath.row
            cell.textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            cell.textField.delegate = self
            switch indexPath.row {
            case 0:
                cardNumberTextField = cell.textField
                cell.textField.keyboardType = .numberPad
                cell.imageView?.image = paymentMethod?.image ?? #imageLiteral(resourceName: "Card").tintable
                cell.imageView?.tintColor = .lightGray
                cell.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: cell.textField.frame.height))
            case 1:
                expirationTextField = cell.textField
                cell.textField.inputView = inputViewExpiration
            case 2:
                securityCodeTextField = cell.textField
                cell.textField.keyboardType = .numberPad
            default: break
            }
            return cell
        case 1:
            let cell = UITableViewCell()
            let button = LoadingButton()
            button.setTitleColor(isModalSubscription ? UIColor(named: .green) : UIColor(named: .red), for: .normal)
            button.setTitle(isModalSubscription ? "Change Payment Method" : "Delete Payment Method", for: .normal)
            button.addTarget(self, action: #selector(deletePayment(_:)), for: .touchUpInside)
            button.titleLabel?.font = Font.gotham(size: 15)
            cell.addSubview(button)
            
            button.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            return cell
        default: return UITableViewCell()
        }
    }
}

extension PaymentDetailViewController: PaymentListModal {
    func chose(paymentMethod: PaymentMethod) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)), let button = cell.subviews.first(where: { $0 is LoadingButton }) as? LoadingButton {
            DispatchQueue.main.async { button.showLoading() }
            Request.shared.updateExpress(paymentMethod: paymentMethod) { result in
                button.hideLoading()
                switch result {
                case .success(_):
                    self.hideMessage(animated: true)
                    self.dismiss(animated: true, completion: nil)
                case .failure(_):
                    self.showMessage("Can't change payment method", type: .error)

                }
            }
        }
    }
}

extension PaymentDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            return textField.text!.characters.count + string.characters.count - range.length <= 19
        } else if textField.tag == 1 {
            return false
        }
        return true
    }
}

//TODO: figure out what is changing the month components value when the year component scrolls
//FIXED: it was a bug in simulator
extension PaymentDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            expirationMonth = months[row]
        } else {
            expirationYear = years[row]
        }
        expirationTextField?.text = "\(expirationMonth)/\(expirationYear.substring(from: 2))"
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return months[row]
        } else {
            return years[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return months.count
        } else {
            return years.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    @objc private func finishedPickerViewSelection() {
        self.view.endEditing(true)
    }
}


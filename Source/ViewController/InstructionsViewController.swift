//
//  Instructions.swifrt.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/15/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

protocol InstructionsViewControllerDelegate {
    func didMakeChanges(toCartItem: CartItem)
}

class InstructionsViewController: UIViewController {
    
    public var item: CartItem?
    public var rawItem: Item?
    public var delegate: InstructionsViewControllerDelegate?
    
    private var active = false
    private var activeRequest: URLSessionDataTask?

    private var saveButton: UIBarButtonItem!
    private var closeButton: UIBarButtonItem!
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let activityIndicator = LoadingView()
    private let retryButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        if self.item == nil && self.rawItem != nil {
            self.loadItem()
        }
    }
    
    @objc private func loadItem() {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        tableView.isHidden = true
        retryButton.isHidden = true
        Request.shared.getCartItem(item: self.rawItem!) { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let cartItem):
                self.hideMessage()
                self.item = cartItem
                self.tableView.isHidden = false
                self.tableView.reloadData()
            case .failure(_):
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch details", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
                
            }
        }
    }
    
    private func buildViews() {
        navigationController?.navigationBar.tintColor = UIColor(named: .green)
        navigationItem.title = "Add Instructions"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        saveButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(save(_:)))
        saveButton.tintColor = UIColor(named: .green)
        saveButton.setTitleTextAttributes([.font: Font.gotham(size: 17)], for: .normal)
        saveButton.setTitleTextAttributes([.font: Font.gotham(size: 17)], for: .highlighted)
        navigationItem.leftBarButtonItem = saveButton
        
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.register(SettingsLargeInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsLargeInputTableViewCell.identifier)
        view.addSubview(tableView)
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadItem), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    @objc private func save(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func update() {
        activeRequest?.cancel()
        activeRequest = Request.shared.updateCartItem(cartItem: self.item!) { result in
            if case .failure(_) = result {
                self.showMessage("Can't update instructions", type: .error, options: [
                    .autoHide(true),
                    .hideOnTap(true)
                ])
            }
        }
        delegate?.didMakeChanges(toCartItem: self.item!)
    }
}

extension InstructionsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if item == nil {
            return 0
        }
        return section == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.instructionsItemCell.rawValue)
                cell.textLabel?.text = item!.item.name
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = Font.gotham(size: 16)
                cell.detailTextLabel?.text = item!.item.price.currencyFormat
                cell.detailTextLabel?.font = Font.gotham(size: 13)
                cell.detailTextLabel?.textColor = .gray
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.pin_setImage(from: item!.item.img) { _ in
                    let itemSize = CGSize(width: 45, height: 45)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image?.draw(in: imageRect)
                    cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                }
                cell.separatorInset = .zero
                cell.selectionStyle = .none
                return cell
            } else if indexPath.row == 1 {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.instructionsReplaceCell.rawValue)
                cell.textLabel?.font = Font.gotham(size: 13)
                cell.textLabel?.textColor = .gray
                cell.textLabel?.text = "If out of stock..."
                cell.detailTextLabel?.font = Font.gotham(size: 16)
                cell.detailTextLabel?.text = item!.replaceOption.description.0
                cell.detailTextLabel?.textColor = item!.replaceOption.description.1
                cell.imageView?.image = item!.replaceOption.image.0.tintable
                cell.imageView?.tintColor = item!.replaceOption.image.1
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
                return cell
            }
            return UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsLargeInputTableViewCell.identifier, for: indexPath) as! SettingsLargeInputTableViewCell
            cell.textView.placeholder = String(repeating: " ", count: 8) + "Specific instructions for your packer"
            cell.textView.text = item!.instructions
            cell.textView.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let alert = UIAlertController(title: "If the item is out of stock", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: CartItem.ReplaceOption.replaceAuto.description.0, style: .default) { _ in
                if case .replaceAuto = self.item!.replaceOption {} else {
                    self.item!.replaceOption = .replaceAuto
                    self.update()
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                }
            })
            alert.addAction(UIAlertAction(title: "Pick replacement", style: .default) { _ in
                let vc = SimilarItemsViewController()
                vc.itemToCompare = self.item!.item
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(UIAlertAction(title: CartItem.ReplaceOption.skip.description.0, style: .destructive) { _ in
                if case .skip = self.item!.replaceOption {} else {
                    self.item!.replaceOption = .skip
                    self.update()
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 {
            let alert = UIAlertController(title: "Specific instructions for your packer", message: "\n\n\n\n\n\n", preferredStyle: .alert)
            let textView = UITextView()
            textView.backgroundColor = .clear
            textView.autocorrectionType = .no
            textView.text = item!.instructions
            alert.view.addSubview(textView)
            textView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(8)
                make.top.bottom.equalToSuperview().inset(64)
                
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.active = false
                self.view.endEditing(true)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.active = false
                self.view.endEditing(true)
                self.item!.instructions = textView.text.isEmpty ? nil : textView.text
                self.update()
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
            })
            active = true
            present(alert, animated: true) {
                textView.becomeFirstResponder()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? [85, 60][indexPath.row] : 165
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.row == 1 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension InstructionsViewController: SimilarItemsViewControllerDelegate {
    func didChoose(item: Item) {
        self.item!.replaceOption = .replaceSpecific(item: item)
        self.update()
        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }
}

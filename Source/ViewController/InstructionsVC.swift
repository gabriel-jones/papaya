//
//  Instructions.swifrt.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/15/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RxSwift

protocol InstructionsViewControllerDelegate {
    func didMakeChanges()
}

//TODO: modular updates, not all in one go - PATCH

class InstructionsViewController: UIViewController {
    
    public var item: CartItem!
    public var delegate: InstructionsViewControllerDelegate?
    
    private var madeChanges = false
    
    private let disposeBag = DisposeBag()
    private var saveButton: UIBarButtonItem!
    private var closeButton: UIBarButtonItem!
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        navigationController?.navigationBar.tintColor = UIColor(named: .green)
        navigationItem.title = "Add Instructions"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        saveButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(save(_:)))
        saveButton.tintColor = UIColor(named: .green)
        saveButton.setTitleTextAttributes([.font: Font.gotham(size: 17)], for: .normal)
        navigationItem.leftBarButtonItem = saveButton
        
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.register(SettingsLargeInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsLargeInputTableViewCell.identifier)
        view.addSubview(tableView)
        

    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func save(_ sender: UIBarButtonItem) {
        if item.instructions!.isEmpty {
            item.instructions = nil
        }
        
        if madeChanges {
            delegate?.didMakeChanges()
            Request.shared.update(cartItem: self.item)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                print(json)
            }, onError: { error in
                print(error.localizedDescription)
            }, onCompleted: {
                print("completed")
                //self.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        }
    }
}

extension InstructionsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.instructionsItemCell.rawValue)
                cell.textLabel?.text = item.item.name
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = Font.gotham(size: 16)
                cell.detailTextLabel?.text = item.item.price.currencyFormat
                cell.detailTextLabel?.font = Font.gotham(size: 13)
                cell.detailTextLabel?.textColor = .gray
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.pin_setImage(from: item.item.img) { _ in
                    cell.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    cell.imageView?.frame.size = CGSize(width: 45, height: 45)
                }
                cell.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                cell.imageView?.frame.size = CGSize(width: 45, height: 45)
                cell.separatorInset = .zero
                cell.selectionStyle = .none
                return cell
            } else if indexPath.row == 1 {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.instructionsReplaceCell.rawValue)
                cell.textLabel?.font = Font.gotham(size: 13)
                cell.textLabel?.textColor = .gray
                cell.textLabel?.text = "If out of stock..."
                cell.detailTextLabel?.font = Font.gotham(size: 16)
                cell.detailTextLabel?.text = item.replaceOption.description.0
                cell.detailTextLabel?.textColor = item.replaceOption.description.1
                cell.imageView?.image = item.replaceOption.image.0.tintable
                cell.imageView?.tintColor = item.replaceOption.image.1
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
                return cell
            }
            return UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsLargeInputTableViewCell.identifier, for: indexPath) as! SettingsLargeInputTableViewCell
            cell.textView.placeholder = String(repeating: " ", count: 8) + "Specific instructions for your packer"
            cell.textView.text = item.instructions
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
                if case .replaceAuto = self.item.replaceOption {} else {
                    self.item.replaceOption = .replaceAuto
                    self.madeChanges = true
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                }
            })
            alert.addAction(UIAlertAction(title: "Pick replacement", style: .default) { _ in
                let vc = SimilarItemsViewController()
                vc.itemToCompare = self.item.item
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(UIAlertAction(title: CartItem.ReplaceOption.skip.description.0, style: .destructive) { _ in
                if case .skip = self.item.replaceOption {} else {
                    self.item.replaceOption = .skip
                    self.madeChanges = true
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
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
        print("did choose \(item.name)")
    }
}

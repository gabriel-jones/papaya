//
//  Instructions.swifrt.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/15/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class InstructionsVC: UIViewController {
    
    var item: CartItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        navigationItem.rightBarButtonItem = done
    }
    
    @objc func done(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension InstructionsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.instructionsItemCell.rawValue, for: indexPath) as! InstructionsItemCell
            cell.nameLabel.text = item.item.name
            cell.priceLabel.text = item.item.price.currencyFormat
            cell.itemImage.pin_setImage(from: URL(string: C.URL.main + "/img/items/\(item.item.id).png")!, placeholderImage: #imageLiteral(resourceName: "Placeholder").withRenderingMode(.alwaysTemplate))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.instructionsReplaceCell.rawValue, for: indexPath) as! InstructionsReplaceCell
            let labelOptions = item.replaceOption.description
            cell.optionLabel.text = labelOptions.0
            cell.optionLabel.textColor = labelOptions.1
            let imageOptions = item.replaceOption.image
            cell.optionImage.image = imageOptions.0
            cell.optionImage.tintColor = imageOptions.1
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select cell: \(indexPath.row)")
        if indexPath.row == 1 {
            let alert = UIAlertController(title: "If the item is out of stock", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: CartItem.ReplaceOption.replaceAuto.description.0, style: .default) { _ in
                //self.item.replaceOption = .replaceAuto
            })
            alert.addAction(UIAlertAction(title: CartItem.ReplaceOption.replaceSpecific(item: nil).description.0, style: .default) { _ in
                print("open replacement items")
            })
            alert.addAction(UIAlertAction(title: CartItem.ReplaceOption.skip.description.0, style: .destructive) { _ in
                //self.item.replaceOption = .skip
            })
        }
    }
}

class InstructionsItemCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
}

class InstructionsReplaceCell: UITableViewCell {
    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
}


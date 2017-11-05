//
//  CheckoutDeliveryVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 11/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class CheckoutDeliveryVC: BaseVC {
    //MARK: - Properties
    var recent: [String] = ["1", "2", "3", "4", "5"]
    var autocomplete = [GMSAutocompletePrediction]()
    public weak var delegate: CheckoutDeliveryDelegate!
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressField: UITextField!
    
    //MARK: - Actions
    
    @IBAction func back(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressField.addTarget(self, action: #selector(textFieldValueDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldValueDidChange(_ textField: UITextField) {
        self._load()
    }
    
    func _load() {
        print("load addresses")
        let q = addressField.text
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "bm"
        GMSPlacesClient.shared().autocompleteQuery(q!, bounds: nil, filter: filter) { results, error in
            guard let results = results, error == nil else {
                print(error ?? "")
                return
            }
            
            self.autocomplete.removeAll()
            for result in results {
                self.autocomplete.append(result)
            }
            print("got results")
            self.tableView.reloadData()
        }
    }
}

extension CheckoutDeliveryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if addressField.text!.isEmpty {
            return section == 0 ? 1 : recent.count
        }
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.frame.size = CGSize(width: self.tableView.frame.width, height: CGFloat(self.autocomplete.count * 44))
        }
        return autocomplete.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return addressField.text!.isEmpty ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var x = ""
        if addressField.text!.isEmpty {
            x = indexPath.section == 0 ? User.current.defaultAddress : recent[indexPath.row]
        } else {
            x = autocomplete[indexPath.row].attributedFullText.string
        }
        cell.textLabel?.text = x
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if addressField.text!.isEmpty {
            return ["Default Address", "Recent"][section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if addressField.text!.isEmpty {
            if indexPath.section == 0 {
                self.delegate.pickedDelivery(location: User.current.defaultLocation, address: User.current.defaultAddress)
            } else {
                //TODO: recent stuff and figure out placeIDS and how theyre gonna work and whatnot
            }
            self.back(self)
            return
        }
        self.load()
        let placeID = autocomplete[indexPath.row].placeID!
        GMSPlacesClient.shared().lookUpPlaceID(placeID) { result, error in
            self.stopLoading()
            guard let result = result, error == nil else {
                print(error?.localizedDescription ?? "Error")
                return
            }
            self.delegate.pickedDelivery(location: result.coordinate, address: result.formattedAddress!)
            self.back(self)
        }
    }
}

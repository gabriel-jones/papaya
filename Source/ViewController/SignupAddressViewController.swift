//
//  SignupAddressViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/10/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class SignupAddressViewController: UIViewController {
    
    private let backButton = UIButton()
    private let logoView = UIView()
    private let logoImage = UIImageView()
    private let logoName = UILabel()
    private let subtitle = UILabel()
    
    private let addressField: JVFloatLabeledTextField = buildTextField()
    private let houseNumberField: JVFloatLabeledTextField = buildTextField()
    private let tableView = UITableView()

    private let nextButton = LoadingButton()
    private let skipButton = UIButton()
    
    var placeID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    @objc private func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func buildViews() {
        view.gradientBackground()
        
        backButton.tintColor = .white
        backButton.setImage(#imageLiteral(resourceName: "Left Arrow").tintable, for: .normal)
        backButton.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        logoImage.image = #imageLiteral(resourceName: "Logo")
        logoView.addSubview(logoImage)
        logoName.text = "Papaya"
        logoName.font = Font.gotham(weight: .bold, size: 25)
        logoName.textColor = .white
        logoView.addSubview(logoName)
        logoView.heroID = "logoView"
        view.addSubview(logoView)
        
        subtitle.text = "Sign up to start shopping"
        subtitle.font = Font.gotham(size: 15)
        subtitle.textColor = .white
        subtitle.textAlignment = .center
        view.addSubview(subtitle)
        
        addressField.placeholder = "Street Address"
        addressField.keyboardType = .default
        addressField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        view.addSubview(addressField)
        
        houseNumberField.placeholder = "House #"
        houseNumberField.keyboardType = .default
        view.addSubview(houseNumberField)
        
        nextButton.backgroundColor = .white
        nextButton.layer.cornerRadius = 10
        nextButton.setTitleColor(UIColor(named: .green), for: .normal)
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = Font.gotham(weight: .bold, size: 16)
        nextButton.tintColor = UIColor(named: .green)
        nextButton.addTarget(self, action: #selector(next(_:)), for: .touchUpInside)
        view.addSubview(nextButton)
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = Font.gotham(size: 15)
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        skipButton.addTarget(self, action: #selector(skip(_:)), for: .touchUpInside)
        view.addSubview(skipButton)
    }
    
    @objc private func next(_ sender: LoadingButton) {

    }
    
    @objc private func skip(_ sender: UIButton) {

    }
    
    private func buildConstraints() {
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.height.width.equalTo(50)
            make.centerY.equalTo(logoView.snp.centerY)
        }
        
        logoImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
            make.height.equalTo(40)
            make.width.equalTo(logoImage.snp.height)
        }
        
        logoName.snp.makeConstraints { make in
            make.top.bottom.centerY.equalToSuperview()
            make.width.equalTo(92)
            make.left.equalTo(logoImage.snp.right).offset(16)
        }
        
        logoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(24)
            make.height.equalTo(50)
            make.width.equalTo(168)
        }
        
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        let t = sender.text
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
            if sender.text == t {
                //self.loadAddresses()
            }
        }
    }
    /*
    func getLatLng(_ completion: @escaping (Bool, GMSPlace?)->()) {
        if placeID.isEmpty { return }
        GMSPlacesClient.shared().lookUpPlaceID(placeID) { result, error in
            guard let result = result, error == nil else {
                completion(false, nil)
                return
            }
            completion(true, result)
        }
    }
    
    var autocomplete: [GMSAutocompletePrediction] = []
    
    func loadAddresses() {
        let q = address.text
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "bm"
        GMSPlacesClient.shared().autocompleteQuery(q!, bounds: nil, filter: filter) { results, error in
            guard let results = results, error == nil else {
                return
            }
            
            self.autocomplete.removeAll()
            for result in results {
                self.autocomplete.append(result)
            }
            
            self.tableView.reloadData()
        }
    }*/
}
//extension SignupAddressViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        UIView.animate(withDuration: 0.3) {
//            //self.containerHeight.constant = self.autocomplete.count == 0 ? 74 : 375
//            self.containerHeight.constant = CGFloat(self.autocomplete.count * 50 + 74)
//            self.view.layoutIfNeeded()
//        }
//        return autocomplete.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryCell", for: indexPath)
//        cell.textLabel?.text = autocomplete[indexPath.row].attributedFullText.string
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let addr = autocomplete[indexPath.row]
//        address.text = addr.attributedFullText.string
//        placeID = addr.placeID!
//        autocomplete.removeAll()
//        tableView.reloadData()
//        houseNumberContainer.isHidden = false
//        view.endEditing(true)
//    }
//}


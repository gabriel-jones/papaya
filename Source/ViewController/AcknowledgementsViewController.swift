//
//  AcknowledgementsViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/26/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation

class AcknowledgementsViewController: UIViewController {
    
    public let acknowledgements =
    """
    Many thanks to all the wonderful people who contributed in some way to this project. We couldn't have done it without you.

    Fireminds:
    - Michael Branco Jr.
    - Michael Branco Sr.
    - Polina Branco
    - Jon Schmok
    - Jonathan Cassidy
    - Nolan Moniz
    - Cooper Simpson
    - Alex White
    - Kitwana Williams

    Miles Market:
    - Will Cox
    - Wayne Balcombe
    - Steve Holloway

    Data Tech Bermuda:
    - John Tester

    Colleagues:
    - Henri Durousseau
    - Rhys Kittleson

    Friends:
    - Leo Harris
    - Ryan Johnston

    Other:
    - icons8.com

    Thanks again,
    Kirk & Gabriel
    """
    
    private let textView = UITextView()
    
    override func viewDidLoad() {
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "Acknowledgements"
        
        textView.font = Font.gotham(size: 15)
        textView.isEditable = false
        textView.text = self.acknowledgements
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.setContentOffset(.zero, animated: false)
        textView.backgroundColor = .clear
        textView.textColor = .darkGray
        view.addSubview(textView)
    }
    
    private func buildConstraints() {
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

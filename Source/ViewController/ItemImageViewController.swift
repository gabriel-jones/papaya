//
//  ItemImageViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/29/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class ItemImageViewController: UIViewController, UIScrollViewDelegate {
    
    public var image: UIImage?
    public var imageId: String?
    
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let closeButton = UIButton()
    
    private var zoomed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        isHeroEnabled = true
        view.backgroundColor = .white
        
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.heroID = self.imageId
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        imageView.center = view.center
        scrollView.addSubview(imageView)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipe.direction = .down
        scrollView.addGestureRecognizer(swipe)
        
        let double = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        double.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(double)
        
        closeButton.tintColor = UIColor(named: .green)
        closeButton.setImage(#imageLiteral(resourceName: "Close").tintable, for: .normal)
        closeButton.layer.zPosition = 1001
        closeButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    private func buildConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(24)
            make.width.height.equalTo(45)
        }
    }

    @objc private func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @objc func doubleTap() {
        self.scrollView.setZoomScale(zoomed ? 1 : 3.0, animated: true)
        zoomed = !zoomed
    }
    
}

//
//  ImageDetailVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/07/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class ImageDetailVC: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var gradientProgress: DSGradientProgressView!
    
    var id: Int!
    var image: UIImage!
    var delegate: DetailDelegate!
    
    @IBOutlet weak var closeButton: LargeButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        
        if image != #imageLiteral(resourceName: "Picture Grey") {
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.image = image
        }
        
        gradientProgress.layer.zPosition = 1000
        closeButton.layer.zPosition = 1001
        closeButton.action = {
            self.close()
        }
        
        scrollView.minimumZoomScale = 0.5
        scrollView.zoomScale = 0.5
        scrollView.maximumZoomScale = 6.0
        scrollView.frame = self.view.frame
        imageView.frame = scrollView.frame
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipe.direction = .down
        self.scrollView.addGestureRecognizer(swipe)
        
        let double = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        double.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(double)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.imageView.removeConstraints(self.imageView.constraints)
        let onData = Network.reachability!.status == .wwan
        let lowDataUsage = UserDefaults.standard.bool(forKey: "useLessData") && onData
        gradientProgress.wait()
        let u = URL(string: C.URL.main + "/scripts/Inventory/get_image.php?res=\(lowDataUsage ? "med" : "high")&id=\(id!)")!
        print(u)
        R.loadImg(img: u) { img in
            DispatchQueue.main.async {
                self.gradientProgress.signal()
                self.image = img
                self.imageView.image = self.image
                self.imageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    var zoomed = false
    
    @objc func doubleTap() {
        self.scrollView.setZoomScale(zoomed ? 0.5 : 3.0, animated: true)
        zoomed = !zoomed
    }
    
    @objc func close() {
        self.delegate.didFinishDetail()
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

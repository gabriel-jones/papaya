//
//  ListFromOCR.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/24/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class ListFromImageVC: UIViewController {
    //Properties
    
    //Methods
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func read(image: UIImage) {
    }
}

extension ListFromImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.read(image: image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  ItemDelegate.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RMPZoomTransitionAnimator

class ItemOpener: UIViewController, UIViewControllerTransitioningDelegate {
    
    var itemCollectionView: UICollectionView!
    var itemIndexPath: IndexPath!
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // minimum implementation for example
        let animator = RMPZoomTransitionAnimator()
        animator.goingForward = true
        animator.sourceTransition = source as? RMPZoomTransitionAnimating & RMPZoomTransitionDelegate
        animator.destinationTransition = presented as? RMPZoomTransitionAnimating & RMPZoomTransitionDelegate
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // minimum implementation for example
        let animator = RMPZoomTransitionAnimator()
        animator.goingForward = false
        animator.sourceTransition = dismissed as? RMPZoomTransitionAnimating & RMPZoomTransitionDelegate
        animator.destinationTransition = self
        return animator
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        transitioningDelegate = self
    }
}

extension ItemOpener: RMPZoomTransitionAnimating, RMPZoomTransitionDelegate {
    func imageViewFrame() -> CGRect {
        if let cell = itemCollectionView.cellForItem(at: itemIndexPath) as? ItemCollectionViewCell,
            let imageView = cell.itemImage {
            let frame = imageView.convert(imageView.frame, from: view.window)
            return frame
        }
        return .zero
    }
    
    func transitionSourceImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFill
        imageView.frame = imageViewFrame()
        
        if let cell = itemCollectionView.cellForItem(at: itemIndexPath) as? ItemCollectionViewCell {
            imageView.image = cell.itemImage.image
        }
        
        return imageView
    }
    
    func transitionSourceBackgroundColor() -> UIColor {
        return .white
    }
    
    func transitionDestinationImageViewFrame() -> CGRect {
        return imageViewFrame()
    }
    
    func zoomTransitionAnimator(_ animator: RMPZoomTransitionAnimator, didCompleteTransition didComplete: Bool, animatingSourceImageView imageView: UIImageView) {
        print("did complete animation")
    }
}

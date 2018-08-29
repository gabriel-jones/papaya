//
//  SemiModalViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/19/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class SemiModalViewController: UIViewController {
    
    private let butterflyHandle = ButterflyHandleView()
    public var scrollView: UIScrollView?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        view.layer.cornerRadius = 5
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        butterflyHandle.direction = .bottom
        butterflyHandle.wingColor = .black
        view.addSubview(butterflyHandle)
        
        butterflyHandle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(-5)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
    }
    
    private struct LayoutInfo {
        /// 角R
        let cornerRadius: CGFloat = 12
        /// 前景の上マージン
        let viewMargin: CGFloat = 60
        /// 背景の上マージン
        let backdropMargin: CGFloat = 16
        /// 背景の最小縮小率
        let backdropScaleNormal: CGFloat = 0.94
        /// 背景の最大拡大率
        let backdropScaleLimit: CGFloat = 0.98
        /// 背景の拡大割合を調整します（大きくするほど拡大しにくい）
        let backdropScalingResolution: CGFloat = 3000
    }
    private let layoutInfo = LayoutInfo()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        
        if let semiModalPresentationController = self.presentationController as? SemiModalPresentationController {
            semiModalPresentationController.performPresentingTransition(
                withFrontMargin: self.layoutInfo.viewMargin,
                backdropMargins: CGPoint(x: 0, y: self.layoutInfo.backdropMargin),
                backdropScale: self.layoutInfo.backdropScaleNormal,
                backdropCornerRadius: self.layoutInfo.cornerRadius,
                animated: animated,
                additionalAnimations: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let semiModalPresentationController = self.presentationController as? SemiModalPresentationController {
            semiModalPresentationController.performDismissingTransition(
                withCustomTransfrom: nil,
                backdropCornerRadius: 0,
                animated: animated,
                additionalAnimations: nil)
        }
    }
    
    private func updateViewTransforms(withScrollOffset y: CGFloat) {
        guard let semiModalPresentationController = self.presentationController as? SemiModalPresentationController else {
            return
        }
        
        // スクロール量に合わせて背景ビューのスケールを変化させる
        let scrollRate = y / self.layoutInfo.backdropScalingResolution
        semiModalPresentationController.updateBackdropTransform(withScrollRate: scrollRate,
                                                                backdropScale: self.layoutInfo.backdropScaleNormal,
                                                                backdropScaleLimit: self.layoutInfo.backdropScaleLimit,
                                                                backdropMargins: CGPoint(x: 0, y: self.layoutInfo.backdropMargin))
        
        let move = min(y, 0)
        self.view.y = self.layoutInfo.viewMargin - move
        //self.contentViewTopConstraint.constant = move
        //self.contentViewHeightConstraint.constant = self.contentHeight - move
    }
    
    private func checkDismissingCondition(withScrollOffset y: CGFloat) {
        guard let scrollView = scrollView else {
            return
        }
        if y < -self.view.height / 6 {
            scrollView.isScrollEnabled = false
            scrollView.setContentOffset(scrollView.contentOffset, animated: false) // 慣性スクロールを強制停止
            scrollView.contentOffset = CGPoint(x: 0, y: y)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension SemiModalViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        updateViewTransforms(withScrollOffset: y)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.butterflyHandle.spread(animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.butterflyHandle.flap(animated: true)
        
        let y = scrollView.contentOffset.y
        checkDismissingCondition(withScrollOffset: y)
    }
    
}

//
//  UIView+.swift
//  Leio
//
//  Created by Daniel Marques on 22/10/16.
//  Copyright © 2016 Daniel Ballester Marques. All rights reserved.
//

import Foundation
import UIKit


extension UIView {

    func animateWithBounceEffect(completion: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let animations = {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        let completion = {
            (_: Bool) in
            completion?()
            return
        }
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.1,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: animations, completion: completion)
    }

    func animateWithFadeOutEffect(completion: (() -> Void)? = nil) {
        let animations = {
            self.alpha = 0
        }
        let completion = {
            (_: Bool) in
            completion?()
            return
        }

        UIView.animate(withDuration: 0.6, delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       animations: animations,
                       completion: completion)
    }

    public func round() {
        let width = bounds.width < bounds.height ? bounds.width : bounds.height
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: CGRect(x: bounds.midX - width / 2,
                                                y: bounds.midY - width / 2,
                                                width: width, height: width)).cgPath
        self.layer.masksToBounds = true
        self.layer.mask = mask
        self.clipsToBounds = true
    }

}

//
//  CircleView.swift
//  Leio
//
//  Created by Daniel Marques on 29/08/16.
//  Copyright © 2016 Daniel Ballester Marques. All rights reserved.
//

import UIKit

@IBDesignable class CircleView: UIView {

    @IBInspectable var circleColor: UIColor = UIColor.black

    // Adds a white circle behind buttons.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        circleColor.setFill()
        path.fill()
    }

}

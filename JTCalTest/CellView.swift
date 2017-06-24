//
//  CellView.swift
//  testApplicationCalendar
//
//  Created by JayT on 2016-03-04.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class CellView: JTAppleCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var dotMarkerView: CircleView!

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedView.layer.cornerRadius = selectedView.frame.width / 2
    }

    func select(completion: (() -> Void)? = nil) {
        selectedView.layer.cornerRadius = selectedView.frame.width / 2
        selectedView.round()
        selectedView.isHidden = false
        selectedView.animateWithBounceEffect { () -> Void in
            completion?()
        }
    }

    func deselect(completion: (() -> Void)? = nil) {
        if selectedView.isHidden == false {
            selectedView.animateWithFadeOutEffect { () -> Void in
                self.selectedView.isHidden = true
                self.selectedView.alpha = 1
                completion?()
            }
        }
    }

}

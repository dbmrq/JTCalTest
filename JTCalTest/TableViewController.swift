//
//  TableViewController.swift
//  JTCalTest
//
//  Created by Daniel Marques on 25/06/17.
//  Copyright © 2017 dbmrq. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    @IBOutlet weak var offsetStepper: UIStepper!
    @IBOutlet weak var slownessStepper: UIStepper!
    @IBOutlet weak var offsetLabel: UILabel!
    @IBOutlet weak var slownessLabel: UILabel!

    var calendarViewController: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        offsetStepper.minimumValue = 1
        offsetStepper.maximumValue = 10
        slownessStepper.minimumValue = 1
        slownessStepper.maximumValue = 10
        updateLabels()
    }

    func updateLabels() {
        offsetLabel.text = "Offset: \(calendarViewController.dateOffset)"
        slownessLabel.text = "Slowness: \(calendarViewController.slowness)"
    }

    @IBAction func offsetChanged(_ sender: Any) {
        calendarViewController.dateOffset = Int(offsetStepper.value)
        updateLabels()
    }

    @IBAction func slownessChanged(_ sender: Any) {
        calendarViewController.slowness = Int(slownessStepper.value)
        updateLabels()
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            parent?.performSegue(withIdentifier: "segue", sender: self)
        }
    }

}

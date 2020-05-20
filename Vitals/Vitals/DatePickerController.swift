//
//  DatePickerController.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/20/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

// MARK: - Constants

let DatePickerControllerId = "DatePickerControllerId"

class DatePickerController: BaseViewController {

    // MARK: - Properties

    @IBOutlet var datePicker: UIDatePicker!

    var vitals: Vitals?

    // MARK: - Init

    static func createControllerFor(vitals: Vitals?) -> DatePickerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: DatePickerControllerId) as! DatePickerController
        controller.vitals = vitals
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nil
        if let date = vitals?.date {
            datePicker.date = date
        } else {
            datePicker.date = Date()
        }
    }

    // MARK: - Actions

    @IBAction func dateChanged(_ sender: AnyObject) {
        vitals?.date = datePicker.date
    }

}

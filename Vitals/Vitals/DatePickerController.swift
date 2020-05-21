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

    @IBOutlet var amPmSegmentedControl: UISegmentedControl!
    @IBOutlet var datePicker: UIDatePicker!

    var vitals: Vitals!

    // MARK: - Init

    static func createControllerFor(vitals: Vitals) -> DatePickerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: DatePickerControllerId) as! DatePickerController
        controller.vitals = vitals
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nil
        datePicker.date = vitals.date
        amPmSegmentedControl.selectedSegmentIndex = vitals.timeOfDay.rawValue
        amPmSegmentedControl.ensureiOS12Style()
    }

    // MARK: - Actions

    @IBAction func dateChanged(_ sender: AnyObject) {
        vitals.date = datePicker.date
    }

    @IBAction func amPmChanged(_ sender: AnyObject) {
        if let timeOfDay = TimeOfDay(rawValue: amPmSegmentedControl.selectedSegmentIndex) {
            vitals.timeOfDay = timeOfDay
        }
    }

}

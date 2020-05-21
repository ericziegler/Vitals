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

// MARK: - Protocols

protocol DatePickerControllerDelegate {
    func dateAndTimeUpdatedFor(controller: DatePickerController, date: Date, timeOfDay: TimeOfDay)
}

class DatePickerController: BaseViewController {

    // MARK: - Properties

    @IBOutlet var amPmSegmentedControl: UISegmentedControl!
    @IBOutlet var datePicker: UIDatePicker!

    var date: Date!
    var timeOfDay: TimeOfDay!
    var delegate: DatePickerControllerDelegate?

    // MARK: - Init

    static func createControllerFor(date: Date, timeOfDay: TimeOfDay, delegate: DatePickerControllerDelegate) -> DatePickerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: DatePickerControllerId) as! DatePickerController
        controller.date = date
        controller.timeOfDay = timeOfDay
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nil
        datePicker.date = date
        amPmSegmentedControl.selectedSegmentIndex = timeOfDay.rawValue
        amPmSegmentedControl.ensureiOS12Style()
    }

    // MARK: - Actions

    @IBAction func dateChanged(_ sender: AnyObject) {
        if let timeOfDay = TimeOfDay(rawValue: amPmSegmentedControl.selectedSegmentIndex) {
            delegate?.dateAndTimeUpdatedFor(controller: self, date: datePicker.date, timeOfDay: timeOfDay)
        }
    }

    @IBAction func amPmChanged(_ sender: AnyObject) {
        if let timeOfDay = TimeOfDay(rawValue: amPmSegmentedControl.selectedSegmentIndex) {
            delegate?.dateAndTimeUpdatedFor(controller: self, date: datePicker.date, timeOfDay: timeOfDay)            
        }
    }

}

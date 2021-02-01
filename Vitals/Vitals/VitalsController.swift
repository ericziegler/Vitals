//
//  VitalsController.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/20/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

// MARK: - Constants

let VitalsControllerId = "VitalsControllerId"

// MARK: - Protocols

protocol VitalsControllerDelegate {
    func vitalsAdded(success: Bool, controller: VitalsController)
    func vitalsUpdated(success: Bool, controller: VitalsController)
}

class VitalsController: BaseViewController, DatePickerControllerDelegate {

    // MARK: - Properties
    
    @IBOutlet var dateLabel: LightLabel!
    @IBOutlet var weightField: UITextField!
    @IBOutlet var temperatureField: UITextField!
    @IBOutlet var systolicField: UITextField!
    @IBOutlet var diastolicField: UITextField!
    @IBOutlet var heartRateField: UITextField!
    @IBOutlet var saveButton: UIButton!

    var initialVitals: Vitals?
    var date: Date!
    var timeOfDay: TimeOfDay!
    var delegate: VitalsControllerDelegate?

    // MARK: - Init

    static func createControllerFor(vitals: Vitals?, delegate: VitalsControllerDelegate?) -> VitalsController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: VitalsControllerId) as! VitalsController
        controller.initialVitals = vitals
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateAndTime()
        updateFieldValues()
        setupNavBar()
        setupFields()        
        saveButton.layer.cornerRadius = 10
    }

    private func setupDateAndTime() {
        if let vitals = initialVitals {
            date = vitals.date
            timeOfDay = vitals.timeOfDay
        } else {
            date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "a"
            if formatter.string(from: date) == "AM" {
                timeOfDay = .am
            } else {
                timeOfDay = .pm
            }
        }
    }

    private func setupNavBar() {
//        let simButton = UIBarButtonItem(title: "_", style: .plain, target: self, action: #selector(simTapped(_:)))
//        self.navigationItem.leftBarButtonItem = simButton

        if let closeImage = UIImage(named: "Close") {
            let closeButton = UIButton(type: .custom)
            closeButton.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
            closeButton.setImage(closeImage, for: .normal)
            closeButton.frame = CGRect(x: 0, y: 0, width: closeImage.size.width, height: closeImage.size.height)
            let closeItem = UIBarButtonItem(customView: closeButton)
            self.navigationItem.rightBarButtonItem = closeItem
        }
    }

    private func setupFields() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneTapped(_:)))
        view.addGestureRecognizer(tapRecognizer)
        let weightItem = weightField.addButtonOnKeyboardWithText(buttonText: "Next")
        weightItem.target = self
        weightItem.tag = 0
        weightItem.action = #selector(nextTapped(_:))
        let temperatureItem = temperatureField.addButtonOnKeyboardWithText(buttonText: "Next")
        temperatureItem.target = self
        temperatureItem.tag = 1
        temperatureItem.action = #selector(nextTapped(_:))
        let systolicItem = systolicField.addButtonOnKeyboardWithText(buttonText: "Next")
        systolicItem.target = self
        systolicItem.tag = 2
        systolicItem.action = #selector(nextTapped(_:))
        let diastolicItem = diastolicField.addButtonOnKeyboardWithText(buttonText: "Next")
        diastolicItem.target = self
        diastolicItem.tag = 3
        diastolicItem.action = #selector(nextTapped(_:))
        let heartRateItem = heartRateField.addButtonOnKeyboardWithText(buttonText: "Done")
        heartRateItem.target = self
        heartRateItem.tag = 4
        heartRateItem.action = #selector(doneTapped(_:))
    }

    // MARK: - Actions

    @IBAction func simTapped(_ sender: AnyObject) {
        simData()
    }

    @IBAction func closeTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func dateTapped(_ sender: AnyObject) {
        let controller = DatePickerController.createControllerFor(date: date, timeOfDay: timeOfDay, delegate: self)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func saveTapped(_ sender: AnyObject) {
        saveVitals()        
    }

    @objc func nextTapped(_ sender: AnyObject) {
        if sender.tag == 0 {
            temperatureField.becomeFirstResponder()
        }
        else if sender.tag == 1 {
            systolicField.becomeFirstResponder()
        }
        else if sender.tag == 2 {
            diastolicField.becomeFirstResponder()
        }
        else if sender.tag == 3 {
            heartRateField.becomeFirstResponder()
        }
    }

    @objc func doneTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }

    // MARK: - Helpers

    private func updateFieldValues() {
        self.title = "\(timeOfDay.displayText) Vitals"
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        dateLabel.text = "\(formatter.string(from: date)) - \(timeOfDay.displayText)"

        if let weight = initialVitals?.weight {
            weightField.text = "\(weight)"
        } else {
            weightField.text = nil
        }
        if let temperature = initialVitals?.temperature {
            temperatureField.text = "\(temperature)"
        } else {
            temperatureField.text = nil
        }
        if let systolic = initialVitals?.systolic, let diastolic = initialVitals?.diastolic {
            systolicField.text = "\(systolic)"
            diastolicField.text = "\(diastolic)"
        } else {
            systolicField.text = nil
            diastolicField.text = nil
        }
        if let pulse = initialVitals?.pulse {
            heartRateField.text = "\(pulse)"
        } else {
            heartRateField.text = nil
        }
    }

    private func saveVitals() {
        DispatchQueue.main.async {
            self.saveButton.isEnabled = false
        }
        let vitals = initialVitals ?? Vitals()
        // update time and date
        if let dateTimeComponents = dateLabel.text?.components(separatedBy: " - ") {
            if let dateComponent = dateTimeComponents.first {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yy"
                vitals.date = formatter.date(from: dateComponent) ?? Date()
            }
            if let timeComponent = dateTimeComponents.last {
                if timeComponent == "AM" {
                    vitals.timeOfDay = .am
                } else {
                    vitals.timeOfDay = .pm
                }
            }
        }
        if let weightText = weightField.text, let weight = Int(weightText) {
            vitals.weight = weight
        }
        if let temperatureText = temperatureField.text, let temperature = Double(temperatureText) {
            vitals.temperature = temperature
        }
        if let systolicText = systolicField.text, let systolic = Int(systolicText) {
            vitals.systolic = systolic
        }
        if let diastolicText = diastolicField.text, let diastolic = Int(diastolicText) {
            vitals.diastolic = diastolic
        }
        if let pulseText = heartRateField.text, let pulse = Int(pulseText) {
            vitals.pulse = pulse
        }
        if initialVitals == nil {
            VitalsLog.shared.add(vitals: vitals) { [unowned self] (error) in
                if let _ = error {
                    self.delegate?.vitalsAdded(success: false, controller: self)
                } else {
                    self.delegate?.vitalsAdded(success: true, controller: self)
                }
                DispatchQueue.main.async {
                    self.saveButton.isEnabled = true
                }
            }
        } else {
            VitalsLog.shared.update(vitals: vitals) { [unowned self] (error) in
                if let _ = error {
                    self.delegate?.vitalsUpdated(success: false, controller: self)
                } else {
                    self.delegate?.vitalsUpdated(success: true, controller: self)
                }
                DispatchQueue.main.async {
                    self.saveButton.isEnabled = true
                }
            }
        }
    }

    private func simData() {
        // get time of day
        var timeOfDay = TimeOfDay.pm

        // update time and date
        if let dateTimeComponents = dateLabel.text?.components(separatedBy: " - ") {
            if let timeComponent = dateTimeComponents.last {
                if timeComponent == "AM" {
                    timeOfDay = .am
                } else {
                    timeOfDay = .pm
                }
            }
        }

        var simSystolic = 0
        var simDiastolic = 0
        let rawTemp = Int.random(in: 959...980)
        let simTemperature: Double = Double(rawTemp) / 10.0
        var simPulse = 0
        var simWeight = 0
        if timeOfDay == .am {
            simWeight = Int.random(in: 220...222)
            simPulse = Int.random(in: 60...72)
            simSystolic = Int.random(in: 120...135)
            simDiastolic = Int.random(in: 80...90)
        } else {
            simPulse = Int.random(in: 64...76)
            simSystolic = Int.random(in: 125...140)
            simDiastolic = Int.random(in: 82...92)
        }

        if simWeight > 0 {
            weightField.text = "\(simWeight)"
        }
        heartRateField.text = "\(simPulse)"
        systolicField.text = "\(simSystolic)"
        diastolicField.text = "\(simDiastolic)"
        temperatureField.text = "\(simTemperature)"
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(self)
    }

    // MARK: - DatePickerControllerDelegate

    func dateAndTimeUpdatedFor(controller: DatePickerController, date: Date, timeOfDay: TimeOfDay) {
        self.date = date
        self.timeOfDay = timeOfDay
        updateFieldValues()
    }

}

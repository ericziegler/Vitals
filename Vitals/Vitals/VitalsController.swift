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

class VitalsController: BaseViewController {

    // MARK: - Properties

    var initialVitals: Vitals?
    var editedVitals = Vitals()

    // MARK: - Init

    static func createControllerFor(vitals: Vitals?) -> VitalsController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: VitalsControllerId) as! VitalsController
        controller.initialVitals = vitals
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createVitalsCopy()
        setupNavBar()
    }

    private func createVitalsCopy() {
        editedVitals = Vitals()
        editedVitals.date = initialVitals?.date
        editedVitals.weight = initialVitals?.weight
        editedVitals.temperature = initialVitals?.temperature
        editedVitals.systolic = initialVitals?.systolic
        editedVitals.diastolic = initialVitals?.diastolic
        editedVitals.pulse = initialVitals?.pulse
    }

    private func setupNavBar() {
        updateNavTitle()
        if let closeImage = UIImage(named: "Close") {
            let closeButton = UIButton(type: .custom)
            closeButton.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
            closeButton.setImage(closeImage, for: .normal)
            closeButton.frame = CGRect(x: 0, y: 0, width: closeImage.size.width, height: closeImage.size.height)
            let closeItem = UIBarButtonItem(customView: closeButton)
            self.navigationItem.rightBarButtonItem = closeItem
        }
    }

    private func updateNavTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        if let date = editedVitals.date {
            self.title = "\(formatter.string(from: date)) Vitals"
        } else {
            self.title = "New Vitals"
        }
    }

    // MARK: - Actions

    @IBAction func closeTapped(_ sender: AnyObject) {
        if checkVitalsChanged() == false {
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Unsaved Changes", message: "Are you sure you would like to exit without saving changes?", preferredStyle: .alert)
            let exitAction = UIAlertAction(title: "Exit", style: .default) { [unowned self] (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(exitAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func saveTapped(_ sender: AnyObject) {
        let vitals = (initialVitals != nil) ? initialVitals! : Vitals()
        vitals.date = editedVitals.date
        vitals.weight = editedVitals.weight
        vitals.temperature = editedVitals.temperature
        vitals.systolic = editedVitals.systolic
        vitals.diastolic = editedVitals.diastolic
        vitals.pulse = editedVitals.pulse
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Helpers

    private func checkVitalsChanged() -> Bool {
        if editedVitals.date != initialVitals?.date {
            return true
        }
        else if editedVitals.weight != initialVitals?.weight {
            return true
        }
        else if editedVitals.temperature != initialVitals?.temperature {
            return true
        }
        else if editedVitals.systolic != initialVitals?.systolic {
            return true
        }
        else if editedVitals.diastolic != initialVitals?.diastolic {
            return true
        }
        else if editedVitals.pulse != initialVitals?.pulse {
            return true
        } else {
            return false
        }
    }

}

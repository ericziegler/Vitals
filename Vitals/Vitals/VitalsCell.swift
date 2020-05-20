//
//  VitalsCell.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

// MARK: - Constants

let VitalsCellId = "VitalsCellId"
let VitalsCellHeight: CGFloat = 115

class VitalsCell: UITableViewCell {

    // MARK: - Properties

    @IBOutlet var bgView: UIView!
    @IBOutlet var dateLabel: BoldLabel!
    @IBOutlet var weightLabel: MediumLabel!
    @IBOutlet var bloodPressureLabel: MediumLabel!
    @IBOutlet var pulseLabel: MediumLabel!
    @IBOutlet var temperatureLabel: MediumLabel!

    // MARK: - Init

    override func prepareForReuse() {
        dateLabel.text = "N/A"
        weightLabel.text = "N/A"
        bloodPressureLabel.text = "N/A"
        pulseLabel.text = "N/A"
        temperatureLabel.text = "N/A"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.appLightGray.cgColor
    }

    // MARK: - Layout

    func layoutFor(vitals: Vitals?) {
        if let vitals = vitals {
            // TODO: Update to handle AM/PM
            if let date = vitals.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yy - a"
                if date.dateAtBeginningOfDay() == Date().dateAtBeginningOfDay() {
                    formatter.dateFormat = "a"
                    dateLabel.text = "Today's \(formatter.string(from: date).uppercased()) Vitals"
                } else {
                    dateLabel.text = "\(formatter.string(from: date).uppercased()) Vitals"
                }
            }
            if let weight = vitals.weight {
                weightLabel.text = "\(weight) lbs."
            }
            if let temperature = vitals.temperature {
                let formattedTemperature = Double(round(10 * temperature) / 10)
                temperatureLabel.text = "\(formattedTemperature)º"
            }
            if let systolic = vitals.systolic, let diastolic = vitals.diastolic {
                bloodPressureLabel.text = "\(systolic) / \(diastolic)"
            }
            if let pulse = vitals.pulse {
                pulseLabel.text = "\(pulse) bpm"
            }
        }
    }

}

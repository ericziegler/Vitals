//
//  ChartCell.swift
//  Vitals
//
//  Created by Eric Ziegler on 6/8/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit
import SpreadsheetView

// MARK: - Constants

let ChartCellId = "ChartCellId"

class ChartCell: Cell {

    // MARK: - Properties

    let dataLabel = RegularLabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        dataLabel.frame = bounds
        dataLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dataLabel.numberOfLines = 0
        dataLabel.lineBreakMode = .byWordWrapping
        dataLabel.textAlignment = .center

        contentView.addSubview(dataLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Layout

    func layoutFor(vitals: Vitals?, type: VitalType) {
        contentView.backgroundColor = UIColor.white
        dataLabel.font = UIFont.applicationFontOfSize(14)
        dataLabel.text = nil
        switch type {
        case .bloodPressure:
            if let systolic = vitals?.systolic, let diastolic = vitals?.diastolic {
                dataLabel.text = "\(systolic) / \(diastolic)"
            }
        case .heartRate:
            if let heartRate = vitals?.pulse {
                dataLabel.text = "\(heartRate)"
            }
        case .temperature:
            if let temperature = vitals?.temperature {
                let formattedTemperature = Double(round(10 * temperature) / 10)
                dataLabel.text = "\(formattedTemperature)"
            }
        case .weight:
            if let weight = vitals?.weight {
                dataLabel.text = "\(weight)"
            }
        }
    }

    func layoutFor(date: Date) {
        contentView.backgroundColor = UIColor(hex: 0xDCCCFF)
        dataLabel.font = UIFont.applicationBoldFontOfSize(14)
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        dataLabel.text = formatter.string(from: date)
    }

    func layoutFor(headerText: String) {
        contentView.backgroundColor = UIColor(hex: 0xDCCCFF)
        dataLabel.font = UIFont.applicationBoldFontOfSize(11)
        dataLabel.text = headerText
    }

}

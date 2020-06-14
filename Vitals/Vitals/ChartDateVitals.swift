//
//  ChartDateVitals.swift
//  Vitals
//
//  Created by Eric Ziegler on 6/8/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import Foundation

class ChartDateVitals {

    // MARK: - Properties

    var date = Date()
    var amVitals: Vitals?
    var pmVitals: Vitals?
    var csvString: String {
        var result = ""
        // date
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        result += formatter.string(from: date)
        result += ","
        // am vitals
        if let am = amVitals {
            // weight
            if let weight = am.weight {
                result += "\(weight)"
            }
            result += ","
            // blood pressure
            if let systolic = am.systolic, let diastolic = am.diastolic {
                result += "\(systolic)/\(diastolic)"
            }
            result += ","
            // pulse
            if let pulse = am.pulse {
                result += "\(pulse)"
            }
            result += ","
            // temperature
            if let temperature = am.temperature {
                let formattedTemperature = Double(round(10 * temperature) / 10)
                result += "\(formattedTemperature)"
            }
            result += ","
        } else {
            result += ",,,,"
        }
        // pm vitals
        if let pm = pmVitals {
            // blood pressure
            if let systolic = pm.systolic, let diastolic = pm.diastolic {
                result += "\(systolic)/\(diastolic)"
            }
            result += ","
            // pulse
            if let pulse = pm.pulse {
                result += "\(pulse)"
            }
            result += ","
            // temperature
            if let temperature = pm.temperature {
                let formattedTemperature = Double(round(10 * temperature) / 10)
                result += "\(formattedTemperature)"
            }
            result += ","
        } else {
            result += ",,,,"
        }
        // glucose placeholders
        result += ",,,"
        return result
    }

}

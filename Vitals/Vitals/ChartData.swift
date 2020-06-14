//
//  ChartData.swift
//  Vitals
//
//  Created by Eric Ziegler on 6/8/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import Foundation

class ChartData {

    // MARK: - Properties

    var vitalsByDate = [Double : ChartDateVitals]()
    var sortedDateKeys = [Double]()
    var vitalsCSV: String {
        var result = ""
        let reverseSortedDateKeys = sortedDateKeys.sorted(by: { $0 < $1 })
        for i in 0 ..< reverseSortedDateKeys.count {
            let curKey = reverseSortedDateKeys[i]
            let curVitals = vitalsByDate[curKey]!
            result += curVitals.csvString
            if i < reverseSortedDateKeys.count {
                result += "\n"
            }
        }
        return result
    }

    init() {
        loadVitals()
    }

    private func loadVitals() {
        for i in 0 ..< VitalsLog.shared.vitalsCount {
            let vitals = VitalsLog.shared.vitalsAt(index: i)!
            if vitalsByDate[vitals.timestamp] == nil {
                let dateVitals = ChartDateVitals()
                dateVitals.date = vitals.date
                if vitals.timeOfDay == .am {
                    dateVitals.amVitals = vitals
                } else {
                    dateVitals.pmVitals = vitals
                }
                vitalsByDate[vitals.timestamp] = dateVitals
                sortedDateKeys.append(vitals.timestamp)
            } else {
                let dateVitals = vitalsByDate[vitals.timestamp]!
                if vitals.timeOfDay == .am {
                    dateVitals.amVitals = vitals
                } else {
                    dateVitals.pmVitals = vitals
                }
            }
        }
        sortedDateKeys = sortedDateKeys.sorted(by: { $0 > $1 })
    }

}

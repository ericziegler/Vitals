//
//  GraphController.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/21/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

// MARK: - Constants

let GraphControllerId = "GraphControllerId"

// MARK: - Enums

enum VitalType {
    case weight
    case temperature
    case bloodPressure
    case heartRate

    var displayText: String {
        switch self {
        case .weight:
            return "Weight"
        case .temperature:
            return "Temperature"
        case .bloodPressure:
            return "Blood Pressure"
        case .heartRate:
            return "Heart Rate"
        }
    }
}

enum TimePeriod {
    case lastWeek
    case lastTwoWeeks
    case lastMonth

    var displayText: String {
        switch self {
        case .lastWeek:
            return "Last Week"
        case .lastTwoWeeks:
            return "Last 2 Weeks"
        case .lastMonth:
            return "Last Month"
        }
    }
}

enum TimeOfDayFilter {
    case amPm
    case amOnly
    case pmOnly

    var displayText: String {
        switch self {
        case .amPm:
            return "AM & PM"
        case .amOnly:
            return "AM Only"
        case .pmOnly:
            return "PM Only"
        }
    }
}

class GraphController: BaseViewController {

    // MARK: - Properties

    @IBOutlet var graphContainer: UIView!
    @IBOutlet var timePeriodView: UIView!
    @IBOutlet var vitalView: UIView!
    @IBOutlet var amPmView: UIView!
    @IBOutlet var timePeriodLabel: MediumLabel!
    @IBOutlet var vitalLabel: MediumLabel!
    @IBOutlet var amPmLabel: MediumLabel!

    var graph = LineChart()
    var type = VitalType.temperature
    var period = TimePeriod.lastWeek
    var timeOfDay = TimeOfDayFilter.amOnly
    var maxDataCount = 0

    // MARK: - Init

    static func createController() -> GraphController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: GraphControllerId) as! GraphController
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History"
        reloadGraph()
        styleUI()
    }

    private func styleUI() {
        vitalView.layer.borderColor = UIColor.appDarkGray.cgColor
        vitalView.layer.borderWidth = 0.5
        timePeriodView.layer.borderColor = vitalView.layer.borderColor
        timePeriodView.layer.borderWidth = vitalView.layer.borderWidth
        amPmView.layer.borderColor = vitalView.layer.borderColor
        amPmView.layer.borderWidth = vitalView.layer.borderWidth

        vitalLabel.text = type.displayText
        timePeriodLabel.text = period.displayText
        amPmLabel.text = timeOfDay.displayText
    }

    private func reloadGraph() {
        graph.removeFromSuperview()
        graph = LineChart()

        let vitalData = calculateVitals()
        maxDataCount = 0
        for curData in vitalData {
            if curData.count > maxDataCount {
                maxDataCount = curData.count
            }
        }
        if type == .temperature {
            graph.overrideMaximumYValue = 105
            graph.overrideMinimumYValue = 90
        }
        else if type == .heartRate {
            graph.overrideMaximumYValue = 115
            graph.overrideMinimumYValue = 45
        }
        else if type == .weight {
            graph.overrideMaximumYValue = 250
            graph.overrideMinimumYValue = 150
        }
        else if type == .bloodPressure {
            graph.overrideMaximumYValue = 175
            graph.overrideMinimumYValue = 65
        }

        let xLabels: [String] = calculateTime()

        graph.animation.enabled = true
        graph.area = false
        graph.x.labels.visible = true
        graph.x.grid.count = CGFloat(xLabels.count)
        graph.y.grid.count = CGFloat(maxDataCount)
        graph.x.labels.values = xLabels
        graph.y.labels.visible = true
        for curData in vitalData {
            graph.addLine(curData)
        }
        graph.fillInParentView(parentView: graphContainer)
    }

    private func calculateVitals() -> [[CGFloat]] {
        var result = [[CGFloat]]()
        var timePeriod = -7
        if period == .lastTwoWeeks {
            timePeriod = -14
        }
        else if period == .lastMonth {
            timePeriod = -28
        }
        var data1 = [CGFloat]()
        var data2 = [CGFloat]()
        for i in 0 ..< VitalsLog.shared.vitalsCount {
            if let vitals = VitalsLog.shared.vitalsAt(index: i) {
                if vitals.date.isBetweenDates(Date().dateByAddingDays(timePeriod)!, endDate: Date()) {
                    var canAdd = true
                    if (timeOfDay == .amOnly && vitals.timeOfDay == .pm) || (timeOfDay == .pmOnly && vitals.timeOfDay == .am) {
                        canAdd = false
                    }
                    if canAdd == true {
                        if type == .temperature {
                            data1.insert(CGFloat(vitals.temperature ?? 0), at: 0)
                        }
                        else if  type == .weight {
                            data1.insert(CGFloat(vitals.weight ?? 0), at: 0)
                        }
                        else if type == .heartRate {
                            data1.insert(CGFloat(vitals.pulse ?? 0), at: 0)
                        }
                        else if type == .bloodPressure {
                            data1.insert(CGFloat(vitals.systolic ?? 0), at: 0)
                            data2.insert(CGFloat(vitals.diastolic ?? 0), at: 0)
                        }
                    }
                }
            }
        }
        result.append(data1)
        if type == .bloodPressure {
            result.append(data2)
        }
        return result
    }

    private func calculateTime() -> [String] {
        var result = [String]()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        var i = 0
        if period == .lastWeek {
            while i > -7 {
                result.insert(formatter.string(from: Date().dateByAddingDays(i)!), at: 0)
                i -= 1
            }
        }
        else if period == .lastTwoWeeks {
            while i > -14 {
                result.insert(formatter.string(from: Date().dateByAddingDays(i)!), at: 0)
                result.append("")
                i -= 2
            }
        } else {
            while i > -28 {
                result.insert(formatter.string(from: Date().dateByAddingDays(i)!), at: 0)
                result.append("")
                result.append("")
                result.append("")
                i -= 4
            }
        }
        return result
    }

    // MARK: - Actions

    @IBAction func vitalTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Choose a Vital", message: nil, preferredStyle: .actionSheet)
        let weightAction = UIAlertAction(title: "Weight", style: .default) { [unowned self] (action) in
            self.type = .weight
            self.vitalLabel.text = self.type.displayText
            self.reloadGraph()
        }
        alert.addAction(weightAction)
        let temperatureAction = UIAlertAction(title: "Temperature", style: .default) { [unowned self] (action) in
            self.type = .temperature
            self.vitalLabel.text = self.type.displayText
            self.reloadGraph()
        }
        alert.addAction(temperatureAction)
        let bloodPressureAction = UIAlertAction(title: "Blood Pressure", style: .default) { [unowned self] (action) in
            self.type = .bloodPressure
            self.vitalLabel.text = self.type.displayText
            self.reloadGraph()
        }
        alert.addAction(bloodPressureAction)
        let heartRateAction = UIAlertAction(title: "Heart Rate", style: .default) { [unowned self] (action) in
            self.type = .heartRate
            self.vitalLabel.text = self.type.displayText
            self.reloadGraph()
        }
        alert.addAction(heartRateAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func timePeriodTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Choose a Time Period", message: nil, preferredStyle: .actionSheet)
        let lastWeekAction = UIAlertAction(title: "Last Week", style: .default) { [unowned self] (action) in
            self.period = .lastWeek
            self.timePeriodLabel.text = self.period.displayText
            self.reloadGraph()
        }
        alert.addAction(lastWeekAction)
        let lastTwoWeeksAction = UIAlertAction(title: "Last 2 Weeks", style: .default) { [unowned self] (action) in
            self.period = .lastTwoWeeks
            self.timePeriodLabel.text = self.period.displayText
            self.reloadGraph()
        }
        alert.addAction(lastTwoWeeksAction)
        let lastMonthAction = UIAlertAction(title: "Last Month", style: .default) { [unowned self] (action) in
            self.period = .lastMonth
            self.timePeriodLabel.text = self.period.displayText
            self.reloadGraph()
        }
        alert.addAction(lastMonthAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func amPmTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Choose a Time of Day", message: nil, preferredStyle: .actionSheet)
        let amPmAction = UIAlertAction(title: "AM & PM", style: .default) { [unowned self] (action) in
            // TODO: Implement
//            self.timeOfDay = .amPm
//            self.amPmLabel.text = self.timeOfDay.displayText
//            self.reloadGraph()
        }
        alert.addAction(amPmAction)
        let amAction = UIAlertAction(title: "AM Only", style: .default) { [unowned self] (action) in
            self.timeOfDay = .amOnly
            self.amPmLabel.text = self.timeOfDay.displayText
            self.reloadGraph()
        }
        alert.addAction(amAction)
        let pmAction = UIAlertAction(title: "PM Only", style: .default) { [unowned self] (action) in
            self.timeOfDay = .pmOnly
            self.amPmLabel.text = self.timeOfDay.displayText
            self.reloadGraph()
        }
        alert.addAction(pmAction)
        self.present(alert, animated: true, completion: nil)
    }

}

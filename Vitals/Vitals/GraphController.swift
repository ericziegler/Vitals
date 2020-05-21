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

class GraphController: BaseViewController, LineChartDelegate {

    // MARK: - Properties

    @IBOutlet var graphContainer: UIView!
    @IBOutlet var timePeriodView: UIView!
    @IBOutlet var vitalView: UIView!
    @IBOutlet var amPmView: UIView!
    @IBOutlet var timePeriodLabel: MediumLabel!
    @IBOutlet var vitalLabel: MediumLabel!
    @IBOutlet var amPmLabel: MediumLabel!

    var graph = LineChart()
    var type = VitalType.weight
    var period = TimePeriod.lastWeek
    var timeOfDay = TimeOfDayFilter.amPm

    // MARK: - Init

    static func createController() -> GraphController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: GraphControllerId) as! GraphController
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History"
        setupGraph()
        styleUI()
    }

    private func styleUI() {
        vitalView.layer.borderColor = UIColor.appDarkGray.cgColor
        vitalView.layer.borderWidth = 0.5
        timePeriodView.layer.borderColor = vitalView.layer.borderColor
        timePeriodView.layer.borderWidth = vitalView.layer.borderWidth
        amPmView.layer.borderColor = vitalView.layer.borderColor
        amPmView.layer.borderWidth = vitalView.layer.borderWidth
        graphContainer.layer.borderColor = vitalView.layer.borderColor
        graphContainer.layer.borderWidth = vitalView.layer.borderWidth
    }

    private func setupGraph() {
        // simple arrays
        let data: [CGFloat] = [3, 4, -2, 11, 13, 15]
        let data2: [CGFloat] = [1, 3, 5, 13, 17, 20]

        // simple line with custom x axis labels
        let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]

        graph = LineChart()
        graph.animation.enabled = true
        graph.area = true
        graph.x.labels.visible = true
        graph.x.grid.count = 5
        graph.y.grid.count = 5
        graph.x.labels.values = xLabels
        graph.y.labels.visible = true
        graph.addLine(data)
        graph.addLine(data2)
        graph.fillInParentView(parentView: graphContainer)
        graph.delegate = self
    }

    private func reloadGraph() {

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
            self.timeOfDay = .amPm
            self.amPmLabel.text = self.timeOfDay.displayText
            self.reloadGraph()
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

    // MARK: - LineChartDelegate

    func didSelectDataPoint(_ x: CGFloat, yValues: [CGFloat]) {
        print("\(x), \(yValues)")
    }

}

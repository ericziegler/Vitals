//
//  ChartController.swift
//  Vitals
//
//  Created by Eric Ziegler on 6/8/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit
import SpreadsheetView
import MessageUI

class ChartController: BaseViewController, SpreadsheetViewDataSource, MFMailComposeViewControllerDelegate {

    // MARK: - Properties

    @IBOutlet var vitalsSheet: SpreadsheetView!

    var chartData = ChartData()

    let headers = ["Date", "Weight", "AM\nTemp", "AM\nBlood Pressure", "AM\nPulse", "PM\nTemp", "PM\nBlood Pressure", "PM\nPulse"]

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Log"
        vitalsSheet.dataSource = self
        vitalsSheet.register(ChartCell.self, forCellWithReuseIdentifier: ChartCellId)
        setupNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chartData = ChartData()
        vitalsSheet.reloadData()
    }

    private func setupNavBar() {
        if let exportImage = UIImage(named: "Export")?.maskedImageWithColor(UIColor.white) {
            let exportButton = UIButton(type: .custom)
            exportButton.setImage(exportImage, for: .normal)
            exportButton.frame = CGRect(x: 0, y: 0, width: exportImage.size.width, height: exportImage.size.height)
            exportButton.addTarget(self, action: #selector(exportTapped(_:)), for: .touchUpInside)
            let exportItem = UIBarButtonItem(customView: exportButton)
            self.navigationItem.rightBarButtonItem = exportItem
        }
    }

    // MARK: - Actions

    @IBAction func exportTapped(_ sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() == true {
            let vitalsData = chartData.vitalsCSV
            let vitalsFileName = "vitals.csv"
            if vitalsData.writeToFile(fileName: vitalsFileName) == true {
                let mailController = MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.setToRecipients(["eric@zigabytes.com"])
                mailController.setSubject("Vitals CSV")
                mailController.setMessageBody("Attached is the Vitals CSV.", isHTML: false)
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent(vitalsFileName)
                    do {
                        let fileData = try Data(contentsOf: fileURL, options: [.alwaysMapped, .uncached])
                        mailController.addAttachmentData(fileData, mimeType: ".csv", fileName: vitalsFileName)
                        DispatchQueue.main.async {
                            self.present(mailController, animated: true, completion: nil)
                        }
                    } catch {
                        print("Failed to attach csv data.")
                    }
                }
            }
        }
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - SpreadsheetViewDataSource

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 8
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return chartData.sortedDateKeys.count + 1
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 90
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if row == 0 {
            return 45
        } else {
            return 35
        }
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ChartCellId, for: indexPath) as! ChartCell
        if indexPath.row == 0 {
            cell.layoutFor(headerText: headers[indexPath.section])
        } else {
            let dateKey = chartData.sortedDateKeys[indexPath.row - 1]
            let dateVitals = chartData.vitalsByDate[dateKey]!
            if indexPath.section == 0 {
                cell.layoutFor(date: dateVitals.date)
            }
            else if indexPath.section == 1 {
                // weight
                cell.layoutFor(vitals: dateVitals.amVitals, type: .weight)
            }
            else if indexPath.section == 2 {
                // am temp
                cell.layoutFor(vitals: dateVitals.amVitals, type: .temperature)
            }
            else if indexPath.section == 3 {
                // am blood pressure
                cell.layoutFor(vitals: dateVitals.amVitals, type: .bloodPressure)
            }
            else if indexPath.section == 4 {
                // am heart rate
                cell.layoutFor(vitals: dateVitals.amVitals, type: .heartRate)
            }
            else if indexPath.section == 5 {
                // pm temp
                cell.layoutFor(vitals: dateVitals.pmVitals, type: .temperature)
            }
            else if indexPath.section == 6 {
                // pm blood pressure
                cell.layoutFor(vitals: dateVitals.pmVitals, type: .bloodPressure)
            }
            else if indexPath.section == 7 {
                // pm heart rate
                cell.layoutFor(vitals: dateVitals.pmVitals, type: .heartRate)
            }
        }
        return cell
    }

}

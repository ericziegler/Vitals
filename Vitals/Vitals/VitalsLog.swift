//
//  VitalsLog.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import Foundation

// MARK: - Constants

let VitalsCacheKey = "VitalsCacheKey"

class VitalsLog {

    // MARK: - Properties

    static let shared = VitalsLog()
    private var allVitals = [Vitals]()
    var vitalsCount: Int {
        return allVitals.count
    }
    private var csvString: String {
        var result = ""
        for i in 0 ..< allVitals.count {
            result += allVitals[i].csvString
            if i < allVitals.count - 1 {
                result += "\n"
            }
        }
        return result
    }

    // MARK: - Init

    init() {
        load()
    }

    // MARK: - Load / Save

    func load() {
        if let data = UserDefaults.standard.data(forKey: VitalsCacheKey) {
            do {
                if let cachedVitals = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Vitals] {
                    allVitals = cachedVitals
                    sortVitals()
                }
            } catch {
                print("Failed to load vitals from user defaults.")
            }
        }
    }

    func loadFromFile() {
        if let dataPath = Bundle.main.path(forResource: "vitalsdata", ofType: "csv") {
            do {
                let csv = try String(contentsOfFile: dataPath, encoding: .utf8)
                parseCSV(csv)
            } catch {
                print("Error loading data")
            }
        }
    }

    func save() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: allVitals, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: VitalsCacheKey)
            UserDefaults.standard.synchronize()
            backupData()
        } catch {
            print ("Failed to save vitals to user defaults.")
        }
    }

    private func backupData() {
        guard let request = API.buildRequestFor(fileName: "update.php", params: ["contents" : csvString]) else {
            return
        }
        let task = URLSession.shared.dataTask(with: request) { [unowned self] (data, response, error) in
            let response = API.buildJSONResponse(data: data, error: error)
            if let error = response.1 {
                print(error.localizedDescription)
            }
            else if let json = response.0 {
                print(json.stringValue)
            } else {
                print("???")
            }
        }
        task.resume()
    }

    // MARK: - Add / Remove

    func add(vitals: Vitals) {
        if vitals.timeOfDay == .am {
            vitals.date = vitals.date.dateAtBeginningOfDay()
        } else {
            vitals.date = vitals.date.dateAtBeginningOfDay().dateByAddingHours(13)!
        }
        allVitals.append(vitals)
        sortVitals()
        save()
    }

    func removeAt(index: Int) {
        allVitals.remove(at: index)
        sortVitals()
        save()
    }

    // MARK: - Helpers

    func vitalsAt(index: Int) -> Vitals? {
        if index > -1 && index < allVitals.count {
            return allVitals[index]
        } else {
            return nil
        }
    }

    func sortVitals() {
        allVitals = allVitals.sorted(by: { $0.date!.timeIntervalSince1970 > $1.date!.timeIntervalSince1970 })
    }

    private func parseCSV(_ csv: String) {
        allVitals.removeAll()
        let components = csv.components(separatedBy: "\n")
        for curComponent in components {
            if curComponent.count > 0 {
                let vitals = Vitals()
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yy"
                let vitalsComponents = curComponent.components(separatedBy: " ")
                vitals.date = formatter.date(from: vitalsComponents[0])
                if vitalsComponents[1] == "0" {
                    vitals.timeOfDay = .am
                } else {
                    vitals.timeOfDay = .pm
                }
                if vitalsComponents[2] != "0" {
                    vitals.weight = Int(vitalsComponents[2])
                }
                if vitalsComponents[3] != "0" {
                    vitals.systolic = Int(vitalsComponents[3])
                }
                if vitalsComponents[4] != "0" {
                    vitals.diastolic = Int(vitalsComponents[4])
                }
                if vitalsComponents[5] != "0" {
                    vitals.pulse = Int(vitalsComponents[5])
                }
                if vitalsComponents[6] != "0" {
                    vitals.temperature = Double(vitalsComponents[6])
                }
                self.add(vitals: vitals)
            }
        }
        self.sortVitals()
        self.save()
    }

}

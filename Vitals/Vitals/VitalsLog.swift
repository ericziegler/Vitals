//
//  VitalsLog.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import Foundation

class VitalsLog {

    // MARK: - Properties

    static let shared = VitalsLog()
    private var allVitals = [Vitals]()
    var vitalsCount: Int {
        return allVitals.count
    }

    // MARK: - Load / Save

    func loadWithCompletion(completion: RequestCompletionBlock?) {
        guard let request = API.buildRequestFor(fileName: "load_vitals.php", params: [:], forceRefresh: true) else {
            completion?(.invalidRequest)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { [unowned self] (data, response, error) in
            let response = API.buildJSONResponse(data: data, error: error)
            if let error = response.1 {
                completion?(APIError.custom(message: error.localizedDescription))
            }
            else if let json = response.0 {
                let status = json.dictionaryValue["status"]!.stringValue
                if status == APISuccessStatus {
                    self.allVitals.removeAll()
                    if let vitalsProps = json.dictionaryValue["vitals"]?.array {
                        for curVitalsProps in vitalsProps {
                            if let curVitalsDict = curVitalsProps.dictionary {
                                let vitals = Vitals(props: curVitalsDict)
                                self.allVitals.append(vitals)
                            }
                        }
                    }
                    self.sortVitals()
                    completion?(nil)
                } else {
                    completion?(APIError.custom(message: status))
                }
            } else {
                completion?(.unknown)
            }
        }
        task.resume()
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

    // MARK: - Add / Remove

    func tempAdd(vitals: Vitals) {
        if vitals.timeOfDay == .am {
            vitals.date = vitals.date.dateAtBeginningOfDay()
        } else {
            vitals.date = vitals.date.dateAtBeginningOfDay().dateByAddingHours(13)!
        }
        allVitals.append(vitals)
        sortVitals()
    }

    func add(vitals: Vitals, completion: RequestCompletionBlock?) {
        if vitals.timeOfDay == .am {
            vitals.date = vitals.date.dateAtBeginningOfDay()
        } else {
            vitals.date = vitals.date.dateAtBeginningOfDay().dateByAddingHours(13)!
        }
        allVitals.append(vitals)
        sortVitals()

        guard let request = API.buildRequestFor(fileName: "add_vitals.php", params: ["id" : vitals.identifier, "timestamp" : "\(vitals.date.timeIntervalSince1970)", "time_of_day" : "\(vitals.timeOfDay.rawValue)", "weight" : "\(vitals.weight ?? 0)", "systolic" : "\(vitals.systolic ?? 0)", "diastolic" : "\(vitals.diastolic ?? 0)", "heart_rate" : "\(vitals.pulse ?? 0)", "temperature" : "\(vitals.temperature ?? 0.0)"]) else {
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let response = API.buildJSONResponse(data: data, error: error)
            if let error = response.1 {
                completion?(APIError.custom(message: error.localizedDescription))
            }
            else if let json = response.0 {
                let status = json.dictionaryValue["status"]!.stringValue
                if status == APISuccessStatus {                    
                    completion?(nil)
                } else {
                    completion?(APIError.custom(message: status))
                }
            } else {
                completion?(.unknown)
            }
        }
        task.resume()
    }

    func update(vitals: Vitals, completion: RequestCompletionBlock?) {
        sortVitals()
        guard let request = API.buildRequestFor(fileName: "update_vitals.php", params: ["id" : vitals.identifier, "timestamp" : "\(vitals.date.timeIntervalSince1970)", "time_of_day" : "\(vitals.timeOfDay.rawValue)", "weight" : "\(vitals.weight ?? 0)", "systolic" : "\(vitals.systolic ?? 0)", "diastolic" : "\(vitals.diastolic ?? 0)", "heart_rate" : "\(vitals.pulse ?? 0)", "temperature" : "\(vitals.temperature ?? 0.0)"]) else {
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let response = API.buildJSONResponse(data: data, error: error)
            if let error = response.1 {
                completion?(APIError.custom(message: error.localizedDescription))
            }
            else if let json = response.0 {
                let status = json.dictionaryValue["status"]!.stringValue
                if status == APISuccessStatus {
                    completion?(nil)
                } else {
                    completion?(APIError.custom(message: status))
                }
            } else {
                completion?(.unknown)
            }
        }
        task.resume()
    }

    func remove(vitals: Vitals?, completion: RequestCompletionBlock?) {
        guard let vitals = vitals, let request = API.buildRequestFor(fileName: "remove_vitals.php", params: ["id" : vitals.identifier]) else {
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let response = API.buildJSONResponse(data: data, error: error)
            if let error = response.1 {
                completion?(APIError.custom(message: error.localizedDescription))
            }
            else if let json = response.0 {
                let status = json.dictionaryValue["status"]!.stringValue
                if status == APISuccessStatus {
                    self.loadWithCompletion(completion: completion)
                } else {
                    completion?(APIError.custom(message: status))
                }
            } else {
                completion?(.unknown)
            }
        }
        task.resume()
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
                self.tempAdd(vitals: vitals)
            }
        }
        self.sortVitals()
    }

}

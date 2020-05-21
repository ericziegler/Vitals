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

    func save() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: allVitals, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: VitalsCacheKey)
            UserDefaults.standard.synchronize()
        } catch {
            print ("Failed to save vitals to user defaults.")
        }
    }

    // MARK: - Add / Remove

    func add(vitals: Vitals) {
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

}

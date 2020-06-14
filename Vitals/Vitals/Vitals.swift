//
//  Vitals.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import Foundation

// MARK: - Enums

enum TimeOfDay: Int {
    case am
    case pm

    var displayText: String {
        if self == .am {
            return "AM"
        } else {
            return "PM"
        }
    }
}

class Vitals {

    // MARK: - Properties

    var identifier: String!
    var timeOfDay: TimeOfDay!
    var date: Date!
    var temperature: Double?
    var weight: Int?
    var systolic: Int?
    var diastolic: Int?
    var pulse: Int?
    var timestamp: Double {
        return date.dateAtBeginningOfDay().timeIntervalSince1970
    }

    // MARK: Init

    init() {
        identifier = String.generateIdentifier()
        date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        let dateString = formatter.string(from: date)
        if dateString == "AM" {
            timeOfDay = .am
        } else {
            timeOfDay = .pm
        }
    }

    init(props: [String : JSON]) {
        identifier = props["id"]!.stringValue
        date = Date(timeIntervalSince1970: props["timestamp"]!.doubleValue)
        timeOfDay = TimeOfDay(rawValue: props["time_of_day"]!.intValue)
        if props["weight"]!.intValue != 0 {
            weight = props["weight"]!.intValue
        }
        if props["systolic"]!.intValue != 0 {
            systolic = props["systolic"]!.intValue
        }
        if props["diastolic"]!.intValue != 0 {
            diastolic = props["diastolic"]!.intValue
        }
        if props["heart_rate"]!.intValue != 0 {
            pulse = props["heart_rate"]!.intValue
        }
        if props["temperature"]!.doubleValue != 0 {
            temperature = props["temperature"]!.doubleValue
        }
    }

}

//
//  Vitals.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import Foundation

// MARK: - Constants

let TimeOfDayCacheKey = "TimeOfDayCacheKey"
let DateCacheKey = "DateCacheKey"
let TemperatureCacheKey = "TemperatureCacheKey"
let WeightCacheKey = "WeightCacheKey"
let SystolicCacheKey = "SystolicCacheKey"
let DiastolicCacheKey = "DiastolicCacheKey"
let PulseCacheKey = "PulseCacheKey"

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

class Vitals: NSObject, NSCoding {

    // MARK: - Properties

    var timeOfDay: TimeOfDay!
    var date: Date!
    var temperature: Double?
    var weight: Int?
    var systolic: Int?
    var diastolic: Int?
    var pulse: Int?

    // MARK: Init + Coding

    override init() {
        super.init()
        date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        let dateString = formatter.string(from: date)
        if dateString == "am" {
            timeOfDay = .am
        } else {
            timeOfDay = .pm
        }
    }

    required init?(coder decoder: NSCoder) {
        if let cachedTimeOfDay = decoder.decodeObject(forKey: TimeOfDayCacheKey) as? NSNumber {
            timeOfDay = TimeOfDay(rawValue: cachedTimeOfDay.intValue)
        }
        if let cachedDate = decoder.decodeObject(forKey: DateCacheKey) as? Date {
            date = cachedDate
        }
        if let cachedTemperature = decoder.decodeObject(forKey: TemperatureCacheKey) as? NSNumber {
            temperature = cachedTemperature.doubleValue
        }
        if let cachedWeight = decoder.decodeObject(forKey: WeightCacheKey) as? NSNumber {
            weight = cachedWeight.intValue
        }
        if let cachedSystolic = decoder.decodeObject(forKey: SystolicCacheKey) as? NSNumber {
            systolic = cachedSystolic.intValue
        }
        if let cachedDiastolic = decoder.decodeObject(forKey: DiastolicCacheKey) as? NSNumber {
            diastolic = cachedDiastolic.intValue
        }
        if let cachedPulse = decoder.decodeObject(forKey: PulseCacheKey) as? NSNumber {
            pulse = cachedPulse.intValue
        }
    }

    func encode(with encoder: NSCoder) {
        if let timeOfDayToCache = timeOfDay {
            encoder.encode(NSNumber(integerLiteral: timeOfDayToCache.rawValue), forKey: TimeOfDayCacheKey)
        } else {
            encoder.encode(nil, forKey: TimeOfDayCacheKey)
        }
        if let dateToCache = date {
            encoder.encode(dateToCache, forKey: DateCacheKey)
        } else {
            encoder.encode(nil, forKey: DateCacheKey)
        }
        if let tempToCache = temperature {
            encoder.encode(NSNumber(value: tempToCache), forKey: TemperatureCacheKey)
        } else {
            encoder.encode(nil, forKey: TemperatureCacheKey)
        }
        if let weightToCache = weight {
            encoder.encode(NSNumber(integerLiteral: weightToCache), forKey: WeightCacheKey)
        } else {
            encoder.encode(nil, forKey: WeightCacheKey)
        }
        if let systolicToCache = systolic {
            encoder.encode(NSNumber(integerLiteral: systolicToCache), forKey: SystolicCacheKey)
        } else {
            encoder.encode(nil, forKey: SystolicCacheKey)
        }
        if let diastolicToCache = diastolic {
            encoder.encode(NSNumber(integerLiteral: diastolicToCache), forKey: DiastolicCacheKey)
        } else {
            encoder.encode(nil, forKey: DiastolicCacheKey)
        }
        if let pulseToCache = pulse {
            encoder.encode(NSNumber(integerLiteral: pulseToCache), forKey: PulseCacheKey)
        } else {
            encoder.encode(nil, forKey: PulseCacheKey)
        }
    }

}

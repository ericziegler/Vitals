//
//  FoundationExtensions.swift
//

import Foundation

// MARK: - Constants

let kOneDayTimeInterval: Double = 86400

// MARK: - NSRange

extension NSRange {

    func toRange(_ string: String) -> Range<String.Index> {
        let start = string.index(string.startIndex, offsetBy: self.location)
        let end = string.index(start, offsetBy: self.length)
        return start..<end
    }

}

// MARK: - String

extension String {

    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    static func formatPhoneNumber(source: String) -> String? {

        // Remove any character that is not a number
        let numbersOnly = source.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")

        // Check for supported phone number length
        guard length == 7 || (length == 10 && !hasLeadingOne) || (length == 11 && hasLeadingOne) else {
            return nil
        }

        let hasAreaCode = (length >= 10)
        var sourceIndex = 0

        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }

        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }

        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength

        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }

        return leadingOne + areaCode + prefix + "-" + suffix
    }

    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }

        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }

        return String(self[substringStartIndex ..< substringEndIndex])
    }

    func formattedPhone() -> String {
        var result = self.lowercased()

        result = result.replacingOccurrences(of: "a", with: "2")
        result = result.replacingOccurrences(of: "b", with: "2")
        result = result.replacingOccurrences(of: "c", with: "2")

        result = result.replacingOccurrences(of: "d", with: "3")
        result = result.replacingOccurrences(of: "e", with: "3")
        result = result.replacingOccurrences(of: "f", with: "3")

        result = result.replacingOccurrences(of: "g", with: "4")
        result = result.replacingOccurrences(of: "h", with: "4")
        result = result.replacingOccurrences(of: "i", with: "4")

        result = result.replacingOccurrences(of: "j", with: "5")
        result = result.replacingOccurrences(of: "k", with: "5")
        result = result.replacingOccurrences(of: "l", with: "5")

        result = result.replacingOccurrences(of: "m", with: "6")
        result = result.replacingOccurrences(of: "n", with: "6")
        result = result.replacingOccurrences(of: "o", with: "6")

        result = result.replacingOccurrences(of: "p", with: "7")
        result = result.replacingOccurrences(of: "q", with: "7")
        result = result.replacingOccurrences(of: "r", with: "7")
        result = result.replacingOccurrences(of: "s", with: "7")

        result = result.replacingOccurrences(of: "t", with: "8")
        result = result.replacingOccurrences(of: "u", with: "8")
        result = result.replacingOccurrences(of: "v", with: "8")

        result = result.replacingOccurrences(of: "w", with: "9")
        result = result.replacingOccurrences(of: "x", with: "9")
        result = result.replacingOccurrences(of: "z", with: "9")
        result = result.replacingOccurrences(of: "z", with: "9")

        let range = NSMakeRange(0, result.count)
        result = result.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: range.toRange(result))

        return result
    }

    func strippingHTML() -> String {
        var result = self.replacingOccurrences(of: "<br />", with: "\n")

        result = result.replacingOccurrences(of: "<br/>", with: "\n")
        result = result.replacingOccurrences(of: "<br></br>", with: "\n")
        result = result.replacingOccurrences(of: "<br>", with: "\n")
        result = result.replacingOccurrences(of: "<p />", with: "\n\n")
        result = result.replacingOccurrences(of: "<b/>", with: "\n\n")
        result = result.replacingOccurrences(of: "<p>", with: "\n\n")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        result = result.replacingOccurrences(of: "&#34;", with: "\"")
        result = result.replacingOccurrences(of: "&amp;#39;", with: "'")
        result = result.replacingOccurrences(of: "&amp;#34;", with: "\"")

        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        return result
    }

    static func generateIdentifier() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    func writeToFile(fileName: String) -> Bool {
        var status = true

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                try self.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                status = false
            }
        } else {
            status = false
        }

        return status
    }

}

// MARK: - MutableCollection

extension MutableCollection {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: numericCast(arc4random_uniform(numericCast(diff))))
            swapAt(i, j)
        }
    }
}

// MARK: - NSDate

extension Date {

    // sunday = 1. saturday = 7
    var dayOfWeekIndex: Int {
        let calendar: Calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var week: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }

    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    var hours: Int {
        return Calendar.current.component(.hour, from: self)
    }

    var minutes: Int {
        return Calendar.current.component(.minute, from: self)
    }

    var seconds: Int {
        return Calendar.current.component(.second, from: self)
    }

    func dateAtBeginningOfDay() -> Date {
        let calendar: Calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }

    func dateAtEndOfDay() -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: self)!
        let tomorrowMidnight = calendar.startOfDay(for: tomorrow)
        return calendar.date(byAdding: .second, value: -1, to: tomorrowMidnight)!
    }

    func dateAtBeginningOfHour() -> Date? {
        var components: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = self.hours
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)
    }

    func dateWithZeroSeconds() -> Date {
        let time: TimeInterval = floor(self.timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: time)
    }

    func debugString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }

    // Returns date formatted as countdown:
    //
    // >= 1 day == time in day(s) rounded up
    // >= 1 hour == time in hour(s) rounded up
    // >= 5 minutes == time in minutes rounded up
    // < 5 minutes == time in minutes, seconds rounded up

    func countdownTimeStringUntilDate(targetDate: Date, noRounding : Bool = false) -> String {
        let nextReminderSecondsLeft:Int = Int(self.timeIntervalSince(targetDate))
        var days : Int = nextReminderSecondsLeft / Int(kOneDayTimeInterval)
        var hours : Int = nextReminderSecondsLeft % Int(kOneDayTimeInterval) / 3600
        var minutes : Int = (nextReminderSecondsLeft % 3600) / 60
        let seconds : Int = (nextReminderSecondsLeft % 3600) % 60
        var countdownString: String = ""

        if (noRounding) {
            hours = nextReminderSecondsLeft / 3600
            if (hours > 0) {
                countdownString = String(format: NSLocalizedString("%d:%02d:%02d", comment:"hours:minutes:seconds left in reminder"),hours,minutes,seconds)
            } else if (minutes > 0) {
                countdownString = String(format: NSLocalizedString("%d:%02d", comment:"minutes:seconds left in reminder"),minutes,seconds)
            } else {
                countdownString = String(format: NSLocalizedString("%d", comment:"seconds left in reminder"),seconds)
            }
        } else {
            if days >= 1 {
                if hours > 0 || minutes > 0 || seconds > 0 {
                    days += 1
                }
                if days == 1 {
                    countdownString = String(format: NSLocalizedString("%d Day", comment: "number of days left in reminder (singular)"), days)
                } else {
                    countdownString = String(format: NSLocalizedString("%d Days", comment: "number of days left in reminder (plural)"), days)
                }
            } else if hours >= 1 {
                if minutes > 0 || seconds > 0 {
                    hours += 1
                }
                if hours == 1 {
                    countdownString = String(format: NSLocalizedString("%d Hour", comment: "number of hours left in reminder (singular)"), hours)
                } else {
                    countdownString = String(format: NSLocalizedString("%d Hours", comment: "number of hours left in reminder (plural)"), hours)
                }
            } else if minutes >= 5 {
                if seconds > 0 {
                    minutes += 1
                }
                if minutes == 1 {
                    countdownString = String(format: NSLocalizedString("%d Min", comment: "number of minutes left in reminder (singular)"), minutes)
                } else {
                    countdownString = String(format: NSLocalizedString("%d Mins", comment: "number of minutes left in reminder (plural)"), minutes)
                }
            } else {
                countdownString = String(format: NSLocalizedString("%d:%02d", comment: "number of minutes and seconds left in reminder"), minutes, seconds)
            }
        }
        return countdownString
    }

    // Returns date formatted as:
    //
    // Today, 10:15 PM
    // Friday, 12:13 AM

    func getRelativeTimeString() -> String {

        let formatter: DateFormatter = DateFormatter()

        let fireTimeAtMidnight: Date = self.dateAtBeginningOfDay()
        let todayAtMidnight: Date = Date().dateAtBeginningOfDay()

        var dayString: String = NSLocalizedString("Today", comment:"")

        if (todayAtMidnight.isEarlierThan(date: fireTimeAtMidnight)) {
            formatter.dateFormat = "EEEE"
            dayString = formatter.string(from: self)
        }

        formatter.dateFormat = "h:mm a"

        return dayString + ", " + formatter.string(from: self)
    }

    func getReminderAlarmString() -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    func isBetweenDates(startDate: Date, endDate: Date) -> Bool {
        if (self.isEarlierThan(date: startDate)) {
            return false
        }
        if (self.isLaterThan(date: endDate)) {
            return false
        }
        return true
    }

    func isEarlierThan(date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }

    func isLaterThan(date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }

    func isToday() -> Bool
    {
        let today = Date()
        return self.year == today.year && self.month == today.month && self.day == today.day
    }

    func roundToMinutes(interval: Int) -> Date {
        let time: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
        let minutes: Int = time.minute!
        let remain = minutes % interval
        return self.addingTimeInterval(TimeInterval(60 * (interval - remain))).dateWithZeroSeconds()
    }

    func dateByAddingDayIndexFromToday(dayIndex: Int) -> Date? {
        let calendar = Calendar.current
        let dateComponents: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        var tomorrowComponents: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.addingTimeInterval(kOneDayTimeInterval))

        tomorrowComponents.hour = dateComponents.hour
        tomorrowComponents.minute = dateComponents.minute
        tomorrowComponents.second = dateComponents.second

        let tomorrow = calendar.date(from: tomorrowComponents)

        return calendar.date(byAdding: .day, value: dayIndex, to: tomorrow!)
    }

    func hasTimePassed() -> Bool {
        let calendar = Calendar.current
        var dateComponents: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        let todayComponents: DateComponents = calendar.dateComponents([.year, .month, .day], from: Date())

        dateComponents.day = todayComponents.day
        dateComponents.month = todayComponents.month
        dateComponents.year = todayComponents.year

        let timeOnly = calendar.date(from: dateComponents)

        if (timeOnly!.timeIntervalSince(Date()) < 0.0) {
            return true
        } else {
            return false
        }
    }

    func numberOfDaysUntilDate(date: Date) -> Int {
        let calendar: Calendar = Calendar.current
        let components: DateComponents = calendar.dateComponents([.day], from: self, to: date)
        return components.day!
    }

    func dateByAddingYears(numberOfYears: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: numberOfYears, to: self)
    }

    func dateByAddingMonths(numberOfMonths: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
    }

    func dateByAddingDays(numberOfDays: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: numberOfDays, to: self)
    }

    func dateByAddingHours(numberOfHours: Int) -> Date? {
         return Calendar.current.date(byAdding: .hour, value: numberOfHours, to: self)
    }

    func dateByAddingMinutes(numberOfMinutes: Int) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: numberOfMinutes, to: self)
    }

    func dateByAddingSeconds(numberOfSeconds: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: numberOfSeconds, to: self)
    }

    static func deviceIs24Hours() -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let dateString: NSString = formatter.string(from: Date()) as NSString
        let amRange = dateString.range(of: formatter.amSymbol)
        let pmRange = dateString.range(of: formatter.pmSymbol)
        return (amRange.location == NSNotFound && pmRange.location == NSNotFound)
    }

    func sunHasRisen() -> Bool {
        var result = false

        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        if let hour = Int(formatter.string(from: Date())) {
            if hour > 7 && hour < 21 {
                result = true
            }
        }

        return result
    }

    func numeralFormattedStringForTimeZone(_ timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZZZ"
        return formatter.string(from: self).replacingOccurrences(of: " ", with: "T", options: .literal, range: nil)
    }

    func numeraFactoryFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self).replacingOccurrences(of: " ", with: "T", options: .literal, range: nil) + "Z"
    }

    static func middleDateBetweenDates(_ startDate: Date, endDate: Date) -> Date
    {
        var date1 = startDate
        var date2 = endDate
        if (endDate.isEarlierThan(startDate))
        {
            date1 = endDate
            date2 = startDate
        }
        let timeDiff = date2.timeIntervalSince(date1)
        return Date(timeInterval: (timeDiff / 2.0), since: date1)
    }

    func isBetweenDates(_ startDate: Date, endDate: Date) -> Bool {
        if (self.isEarlierThan(startDate)) {
            return false
        }
        if (self.isLaterThan(endDate)) {
            return false
        }
        return true
    }

    func isBetweenDatesInclusive(_ startDate: Date, endDate: Date) -> Bool
    {
        var result = self.isBetweenDates(startDate, endDate: endDate)
        if (!result)
        {
            if ((self == startDate) || (self == endDate))
            {
                result = true
            }
        }
        return result
    }

    func isEarlierThan(_ date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }

    func isLaterThan(_ date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }

    func roundToMinutes(_ interval: Int) -> Date {
        let time: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
        let minutes: Int = time.minute!
        let remain = minutes % interval;
        return self.addingTimeInterval(TimeInterval(60 * (interval - remain))).dateWithZeroSeconds()
    }

    func numberOfDaysUntilDate(_ date: Date) -> Int {
        let calendar: Calendar = Calendar.current
        let components: DateComponents = calendar.dateComponents([.day], from: self, to: date)
        return components.day!
    }

    func dateByAddingYears(_ numberOfYears: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: numberOfYears, to: self)
    }

    func dateByAddingMonths(_ numberOfMonths: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
    }

    func dateByAddingDays(_ numberOfDays: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: numberOfDays, to: self)
    }

    func dateByAddingHours(_ numberOfHours: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: numberOfHours, to: self)
    }

    func dateByAddingMinutes(_ numberOfMinutes: Int) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: numberOfMinutes, to: self)
    }

    func dateByAddingSeconds(_ numberOfSeconds: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: numberOfSeconds, to: self)
    }

}

// MARK: - File Handling

func openTextFileNamed(name: String, fileExtension: String) -> String? {
    var result: String?
    if let filePath = Bundle.main.path(forResource: name, ofType: fileExtension) {
        do {
            let contents = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            result = contents
        } catch {
            debugPrint(error)
        }
    }
    return result
}

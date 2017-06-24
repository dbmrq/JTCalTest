import Foundation

// Acknowlegements in Date+Utilities.swift

// Operators to compare whole days {{{1

infix operator =~: ComparisonPrecedence // If you have already defined these operators somewhere
infix operator !~: ComparisonPrecedence // somewhere else, comment them out here.
infix operator >~: ComparisonPrecedence
infix operator <~: ComparisonPrecedence
infix operator >=~: ComparisonPrecedence
infix operator <=~: ComparisonPrecedence

func =~ (left: Date?, right: Date?) -> Bool {
    if left == nil && right == nil { return true }
    guard let left = left, let right = right else { return false }
    return Date.sameDate(left, right)
}

func !~ (left: Date?, right: Date?) -> Bool {
    if left == nil && right == nil { return false }
    guard let left = left, let right = right else { return true }
    return !Date.sameDate(left, right)
}

func >~ (left: Date?, right: Date?) -> Bool {
    guard let left = left else { return false }
    guard let right = right else { return true }
    return left.startOfDay > right.startOfDay
}

func <~ (left: Date?, right: Date?) -> Bool {
    guard let right = right else { return false }
    guard let left = left else { return true }
    return left.startOfDay < right.startOfDay
}

func >=~ (left: Date?, right: Date?) -> Bool {
    if left == nil && right == nil { return true }
    guard let right = right else { return true }
    guard let left = left else { return false }
    return left.startOfDay >= right.startOfDay
}

func <=~ (left: Date?, right: Date?) -> Bool {
    if left == nil && right == nil { return true }
    guard let right = right else { return false }
    guard let left = left else { return true }
    return left.startOfDay <= right.startOfDay
}

// }}}1

/// Standard interval reference
/// Not meant to replace `offset(_: Calendar.Component, _: Int)` to offset dates
public extension Date {// {{{1
    /// Returns number of seconds per second
    public static let second: TimeInterval = 1
    /// Returns number of seconds per minute
    public static let minute: TimeInterval = 60
    /// Returns number of seconds per hour
    public static let hour: TimeInterval = 3600
    /// Returns number of seconds per 24-hour day
    public static let day: TimeInterval = 86400
    /// Returns number of seconds per standard week
    public static let week: TimeInterval = 604800
}// }}}1

/// Utility for interval math
/// Not meant to replace `offset(_: Calendar.Component, _: Int)` to offset dates
public extension Int {// {{{1
    /// Returns number of seconds in n seconds
    public var seconds: TimeInterval { return TimeInterval(self) * Date.second }
    public var second: TimeInterval { return TimeInterval(self) * Date.second }
    /// Returns number of seconds in n minutes
    public var minutes: TimeInterval { return TimeInterval(self) * Date.minute }
    public var minute: TimeInterval { return TimeInterval(self) * Date.minute }
    /// Returns number of seconds in n hours
    public var hours: TimeInterval { return TimeInterval(self) * Date.hour }
    public var hour: TimeInterval { return TimeInterval(self) * Date.hour }
    /// Returns number of seconds in n 24-hour days
    public var days: TimeInterval { return TimeInterval(self) * Date.day }
    public var day: TimeInterval { return TimeInterval(self) * Date.day }
    /// Returns number of seconds in n standard weeks
    public var weeks: TimeInterval { return TimeInterval(self) * Date.week }
    public var week: TimeInterval { return TimeInterval(self) * Date.week }
}// }}}1

/// Calendar component offsets
extension Date {// {{{1
    /// Performs calendar math using date components as alternative
    /// to `offset(_: Calendar.Component, _: Int)`
    /// e.g.
    /// ```swift
    /// print((Date() + DateComponents.days(3) + DateComponents.hours(1)).fullString)
    /// ```
    public static func + (lhs: Date, rhs: DateComponents) -> Date {
        return Date.sharedCalendar.date(byAdding: rhs, to: lhs)! // yes force unwrap. sue me.
    }

    public static func - (lhs: Date, rhs: DateComponents) -> Date {
        let rhs = DateComponents(from: 0 - rhs.timeInterval)
        return Date.sharedCalendar.date(byAdding: rhs, to: lhs)! // yes force unwrap. sue me.
    }

    public static func - (date: Date, otherDate: Date) -> TimeInterval {
        return date.timeIntervalSince(otherDate)
    }
}// }}}1

/// Component Math
extension DateComponents {// {{{1

    /// Add two date components together
    public static func + (lhs: DateComponents, rhs: DateComponents) -> DateComponents {
        var copy = DateComponents()
        for component in lhs.members.union(rhs.members) {
            var sum = 0
            // Error workaround where instead of returning nil
            // the values return Int.max
            if let value = lhs.value(for: component),
                value != Int.max, value != Int.min
            { sum = sum + value }
            if let value = rhs.value(for: component),
                value != Int.max, value != Int.min
            { sum = sum + value }
            copy.setValue(sum, for: component)
        }
        return copy
    }

    /// Subtract date components
    public static func - (lhs: DateComponents, rhs: DateComponents) -> DateComponents {
        var copy = DateComponents()
        for component in lhs.members.union(rhs.members) {
            var result = 0
            // Error workaround where instead of returning nil
            // the values return Int.max
            if let value = lhs.value(for: component),
                value != Int.max, value != Int.min
            { result = result + value }
            if let value = rhs.value(for: component),
                value != Int.max, value != Int.min
            { result = result - value }
            copy.setValue(result, for: component)
        }
        return copy
    }
}// }}}1


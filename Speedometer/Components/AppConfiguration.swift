import Foundation

struct AppConfiguration {
    static let appStartCounterKey = "app_start_counter"
    static let currentSpeedLimitDefaultsKey = "speed"
    static let currentUnitDefaultsKey = "unit"
    static let minimumHorizontalAccuracy = 60
    static let speedStringFormat = "%.0f"
    static let defaultUnit = Locale.current.usesMetricSystem ? Unit.kilometersPerHour.rawValue : Unit.milesPerHour.rawValue
}

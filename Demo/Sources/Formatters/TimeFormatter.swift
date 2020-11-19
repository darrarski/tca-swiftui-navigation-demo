import SwiftUI

struct TimeFormatter {
  var dateFormatter = DateFormatter()

  func string(for date: Date) -> String {
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .medium
    return dateFormatter.string(from: date)
  }
}

extension TimeFormatter {
  static var preview: Self {
    let formatter = TimeFormatter()
    formatter.dateFormatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormatter.locale = Locale(identifier: "en_US")
    formatter.dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }
}

extension EnvironmentValues {
  struct TimeFormatterKey: EnvironmentKey {
    static var defaultValue = TimeFormatter()
  }

  var timeFormatter: TimeFormatter {
    get { self[TimeFormatterKey.self] }
    set { self[TimeFormatterKey.self] = newValue }
  }
}

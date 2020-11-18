import SwiftUI

struct TimeFormatter {
  var dateFormatter = DateFormatter()

  func string(for date: Date) -> String {
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .medium
    return dateFormatter.string(from: date)
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

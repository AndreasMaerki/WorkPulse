import Foundation

extension Date {
  func formattedForTimeSegment() -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(self) {
      return "Today"
    } else if calendar.isDateInYesterday(self) {
      return "Yesterday"
    } else {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      return formatter.string(from: self)
    }
  }
}

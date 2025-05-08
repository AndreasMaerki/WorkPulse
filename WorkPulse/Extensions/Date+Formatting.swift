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

  var monthYearString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL yyyy"
    return formatter.string(from: self)
  }

  var todayString: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter.string(from: self)
  }
}

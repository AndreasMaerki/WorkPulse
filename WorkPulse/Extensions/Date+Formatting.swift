import Foundation

extension Date {
  func formattedForTimeSegment() -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(self) {
      return "Today"
    } else if calendar.isDateInYesterday(self) {
      return "Yesterday"
    } else {
      return formatted(date: .abbreviated, time: .omitted)
    }
  }

  var monthYearString: String {
    formatted(.dateTime.month(.wide).year())
  }

  var todayString: String {
    formatted(date: .complete, time: .omitted)
  }

  var shortTimeString: String {
    formatted(date: .omitted, time: .shortened)
  }

  var shortDateTimeString: String {
    formatted(date: .numeric, time: .shortened)
  }

  var hourMinuteString: String {
    formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
  }
}

import Foundation

@Observable
class CalendarViewModel {
  var currentDate = Date()
  var events: [CalendarEvent]
  private let calendar = Calendar.current

  init(events: [CalendarEvent]) {
    self.events = events
  }

  func eventsForCurrentDate() -> [CalendarEvent] {
    let calendar = Calendar.current
    return events.filter { event in
      calendar.isDate(event.startTime, inSameDayAs: currentDate)
    }
  }

  var startOfWeek: Date {
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
    return calendar.date(from: components) ?? currentDate
  }

  var endOfWeek: Date {
    calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
  }

  func goToNextDay() {
    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
  }

  func goToPreviousDay() {
    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
  }

  func goToNextWeek() {
    currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
  }

  func goToPreviousWeek() {
    currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
  }
}

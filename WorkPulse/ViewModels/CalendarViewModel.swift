import Foundation

@Observable
class CalendarViewModel {
  var selectedDate = Date()
  var events: [CalendarEvent]
  private let calendar = Calendar.current

  init(events: [CalendarEvent]) {
    self.events = events
  }

  func eventsForCurrentDate() -> [CalendarEvent] {
    events.filter { event in
      calendar.isDate(event.startTime, inSameDayAs: selectedDate)
    }
  }

  var startOfWeek: Date {
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
    return calendar.date(from: components) ?? selectedDate
  }

  var endOfWeek: Date {
    calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
  }

  func goToNextDay() {
    selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
  }

  func goToPreviousDay() {
    selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
  }

  func goToNextWeek() {
    selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
  }

  func goToPreviousWeek() {
    selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
  }
}

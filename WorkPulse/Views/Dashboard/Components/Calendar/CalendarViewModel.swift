import Foundation

@Observable
class CalendarViewModel {
  var currentDate = Date()
  var events: [CalendarEvent]

  init(events: [CalendarEvent]) {
    self.events = events
  }

  func eventsForCurrentDate() -> [CalendarEvent] {
    let calendar = Calendar.current
    return events.filter { event in
      calendar.isDate(event.startTime, inSameDayAs: currentDate)
    }
  }

  func goToNextDay() {
    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
  }

  func goToPreviousDay() {
    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
  }
}

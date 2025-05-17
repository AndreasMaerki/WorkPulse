import SwiftUI

struct CalendarLayoutProvider {
  let slotHeight: CGFloat
  let calendar: Calendar

  init(slotHeight: CGFloat, calendar: Calendar = .current) {
    self.slotHeight = slotHeight
    self.calendar = calendar
  }

  func calculateEventYPosition(_ event: CalendarEvent) -> CGFloat {
    let startOfDay = calendar.startOfDay(for: event.startTime)
    let secondsSinceStartOfDay = event.startTime.timeIntervalSince(startOfDay)
    let offset = 0.5
    let hoursSinceStartOfDay = secondsSinceStartOfDay / 3600.0 + offset
    return CGFloat(hoursSinceStartOfDay) * slotHeight
  }

  func calculateEventHeight(_ event: CalendarEvent) -> CGFloat {
    let durationInSeconds = event.endTime.timeIntervalSince(event.startTime)
    let durationInHours = durationInSeconds / 3600.0
    return CGFloat(durationInHours) * slotHeight
  }

  func eventsForDate(_ date: Date, from events: [CalendarEvent]) -> [CalendarEvent] {
    events.filter { event in
      calendar.isDate(event.startTime, inSameDayAs: date)
    }
  }
}

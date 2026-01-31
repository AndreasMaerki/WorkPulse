import SwiftUI

struct CalendarEvent: Identifiable {
  let id = UUID()
  let title: String
  let startTime: Date
  let endTime: Date
  let color: Color

  init(title: String, startTime: Date, endTime: Date, color: Color) {
    self.title = title
    self.startTime = startTime
    self.endTime = endTime
    self.color = color
  }

  init(segment: TimeSegment, clock: Clock, refTime: Date) {
    title = clock.name
    startTime = segment.startTime
    endTime = segment.effectiveEndTime(refTime: refTime)
    color = clock.color
  }
}

extension CalendarEvent {
  static var mockEvents: [CalendarEvent] {
    [
      .init(
        title: "Work Meeting",
        startTime: Date(),
        endTime: Date(
          timeIntervalSinceNow: 3600
        ),
        color: .red
      ),
      .init(
        title: "Grocery Shopping",
        startTime: Date(
          timeIntervalSinceNow: 3600
        ),
        endTime: Date(
          timeIntervalSinceNow: 7200
        ),
        color: .yellow
      ),
      .init(
        title: "Dinner with Family",
        startTime: Date(
          timeIntervalSinceNow: 7200
        ),
        endTime: Date(
          timeIntervalSinceNow: 10800
        ),
        color: .purple
      ),
    ]
  }
}

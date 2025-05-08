import SwiftUI

struct TimeSegmentCalendarView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @Environment(\.dismiss) private var dismiss
  @State private var selectedDate = Date()

  private var calendar: Calendar {
    var calendar = Calendar.current
    calendar.firstWeekday = 2 // Start week on Monday
    return calendar
  }

  private var weekDates: [Date] {
    let today = calendar.startOfDay(for: selectedDate)
    let weekday = calendar.component(.weekday, from: today)
    let daysToSubtract = (weekday + 5) % 7 // Adjust for Monday start
    return (0 ..< 7).map { day in
      calendar.date(byAdding: .day, value: day - daysToSubtract, to: today)!
    }
  }

  private func segmentsForDate(_ date: Date) -> [TimeSegment] {
    let startOfDay = calendar.startOfDay(for: date)
    return viewModel.clocks.flatMap { clock in
      clock.timeSegments.filter { segment in
        let segmentStart = calendar.startOfDay(for: segment.startTime)
        let segmentEnd = segment.endTime ?? Date()
        let duration = segmentEnd.timeIntervalSince(segment.startTime)
        return segmentStart == startOfDay && duration >= 60 // Filter segments less than 1 minute
      }
    }.sorted { $0.startTime < $1.startTime }
  }

  private var selectedDaySegments: [TimeSegment] {
    segmentsForDate(selectedDate)
  }

  private var monthYearString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL yyyy"
    return formatter.string(from: selectedDate)
  }

  private var todayString: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter.string(from: selectedDate)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      CalendarHeaderView(
        monthYear: monthYearString,
        onPrev: { moveWeek(by: -1) },
        onNext: { moveWeek(by: 1) }
      )
      CalendarWeekdayRow(
        weekDates: weekDates,
        selectedDate: selectedDate,
        calendar: calendar,
        onSelect: { selectedDate = $0 }
      )
      CalendarDayHeader(
        dateString: todayString,
        segmentCount: selectedDaySegments.count
      )
      CalendarTimelineView(
        segments: selectedDaySegments,
        calendar: calendar
      )
      Spacer()
    }
    .frame(width: 420, height: 600)
    .cornerRadius(24)
    .shadow(radius: 16)
    .overlay(
      Button(action: { dismiss() }) {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .foregroundColor(.secondary)
          .padding(12)
      }, alignment: .topTrailing
    )
  }

  private func moveWeek(by value: Int) {
    if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
      selectedDate = newDate
    }
  }
}

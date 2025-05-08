import SwiftUI

struct TimelineSegmentLayout: Identifiable {
  let id: UUID
  let segment: TimeSegment
  let yStart: CGFloat
  let height: CGFloat
}

struct CalendarTimelineView: View {
  let segments: [TimeSegment]
  let calendar: Calendar
  let hourHeight: CGFloat
  let dayStart: Date

  init(segments: [TimeSegment], calendar: Calendar, hourHeight: CGFloat = 32) {
    self.segments = segments
    self.calendar = calendar
    self.hourHeight = hourHeight
    dayStart = segments.first.map { Calendar.current.startOfDay(for: $0.startTime) } ?? Date()
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      ScrollView(.vertical, showsIndicators: true) {
        HStack(alignment: .top, spacing: 0) {
          VStack(alignment: .trailing, spacing: hourHeight) {
            ForEach(0 ..< 24) { hour in
              Text("\(hour == 0 ? 12 : hour > 12 ? hour - 12 : hour):00\(hour < 12 ? " AM" : " PM")")
                .font(.caption2)
                .frame(width: 48, alignment: .trailing)
                .foregroundStyle(.secondary)
            }
          }
          .padding(.top, 16)

          TimelineSegmentCardsColumn(
            segments: segments,
            dayStart: dayStart,
            hourHeight: hourHeight,
            calendar: calendar
          )
        }
      }
    }
    .background(Color.gray.opacity(0.1))
    .cornerRadius(16)
    .padding(.horizontal)
    .padding(.bottom)
  }
}

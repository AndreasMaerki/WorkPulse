import SwiftUI

struct TimelineSegmentCardsColumn: View {
  let segments: [TimeSegment]
  let dayStart: Date
  let hourHeight: CGFloat
  let calendar: Calendar

  var body: some View {
    ZStack(alignment: .topLeading) {
      ForEach(segments) { segment in
        TimeSegmentCard(
          segment: segment,
          dayStart: dayStart,
          hourHeight: hourHeight,
          calendar: calendar
        )
      }
    }
    .frame(width: 280, height: hourHeight * 24)
  }
}

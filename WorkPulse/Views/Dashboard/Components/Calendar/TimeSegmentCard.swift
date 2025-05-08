import SwiftUI

struct TimeSegmentCard: View {
  let segment: TimeSegment
  let dayStart: Date
  let hourHeight: CGFloat
  let calendar: Calendar

  private var height: CGFloat
  private var yStart: CGFloat

  init(segment: TimeSegment, dayStart: Date, hourHeight: CGFloat = 32, calendar: Calendar) {
    self.segment = segment
    self.dayStart = dayStart
    self.hourHeight = hourHeight
    self.calendar = calendar

    let startInterval = segment.startTime.timeIntervalSince(dayStart)
    let endInterval = (segment.endTime ?? segment.startTime.addingTimeInterval(60)).timeIntervalSince(dayStart)
    let startHours = startInterval / 3600
    let endHours = endInterval / 3600
    yStart = CGFloat(startHours) * hourHeight
    let yEnd = CGFloat(endHours) * hourHeight
    let rawHeight = yEnd - yStart
    height = rawHeight > 0 ? rawHeight : hourHeight
  }

  var body: some View {
    RoundedRectangle(cornerRadius: 12)
      .fill((segment.clock?.color ?? .accentColor).opacity(0.18))
      .frame(width: 260, height: height)
      .overlay(
        Group {
          if height > 10 {
            VStack(alignment: .leading, spacing: 4) {
              Text(segment.clock?.name ?? "Segment")
                .font(.headline)
                .foregroundColor(segment.clock?.color ?? .accentColor)
              if let note = segment.note {
                Text(note)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
              }
              HStack(spacing: 8) {
                Text(segment.startTime.formatted(date: .omitted, time: .shortened))
                Text("-")
                Text((segment.isRunning ? "Running" : segment.endTime?.formatted(date: .omitted, time: .shortened) ?? ""))
                Spacer()
                Text(segment.elapsedTime(refTime: Date()).formattedHHMMSS())
                  .monospacedDigit()
                  .foregroundColor(segment.clock?.color ?? .accentColor)
              }
              .font(.caption2)
              .foregroundStyle(.secondary)
            }
            .padding(10)
          }
        }
      )
      .padding(.leading, 8)
      .offset(y: yStart)
  }
}

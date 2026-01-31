import Foundation
import SwiftData
import SwiftUI

@Model
final class TimeSegment {
  var id: UUID
  var startTime: Date
  var endTime: Date?
  var isRunning: Bool
  var note: String?
  @Relationship var clock: Clock?

  init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, clock: Clock? = nil, note: String? = nil) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    isRunning = false
    self.clock = clock
    self.note = note
  }

  func elapsedTime(refTime: Date) -> TimeInterval {
    max(0, effectiveEndTime(refTime: refTime).timeIntervalSince(startTime))
  }

  func effectiveEndTime(refTime: Date) -> Date {
    endTime ?? refTime
  }

  func isValidRange(endTime: Date) -> Bool {
    endTime > startTime
  }
}

extension TimeSegment {
  static func mockSegments(for clock: Clock) -> [TimeSegment] {
    [
      TimeSegment(
        startTime: Date().addingTimeInterval(-3 * 60 * 60),
        endTime: Date().addingTimeInterval(-2 * 60 * 60),
        clock: clock,
        note: "Architecture review"
      ),
      TimeSegment(
        startTime: Date().addingTimeInterval(-90 * 60),
        endTime: Date().addingTimeInterval(-30 * 60),
        clock: clock
      ),
    ]
  }
}
